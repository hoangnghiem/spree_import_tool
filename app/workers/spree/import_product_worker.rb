module Spree
  class ImportProductWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker
    sidekiq_options retry: false

    HEADER_ROW = 1
    DATA_START_ROW = 2

    def perform(source_id)
      source = Spree::Import::Source.find(source_id)
      mappers = source.mappers.inject ({}) { |h, m| h[m.user_field] = m.system_field; h }
      spreadsheet = source.open_source_file
      header = spreadsheet.row(HEADER_ROW)
      (DATA_START_ROW..spreadsheet.last_row).each do |i|
        row_hash = Hash[[header, normalise_row(spreadsheet.row(i))].transpose]
        import(source, row_hash, mappers)
      end
    end

    # strip spaces if data is String
    def normalise_row(row)
      row.map { |cell| cell.kind_of?(String) ? cell.try(:strip) : cell }
    end

    def import(source, row_hash, mappers)
      begin
        ActiveRecord::Base.transaction do
          product = make_product(row_hash, mappers)
          taxons = make_taxons(row_hash, mappers)
          taxons.each do |taxon|
            unless taxon.products.include?(product)
              taxon.products << product
            end
          end
        end
      rescue Exception => e
        # TODO: logging here
        puts e.message
      end
    end

    # return taxons list which product belongs to
    def make_taxons(row_hash, mappers)
      taxons = []
      get_value(row_hash, mappers, 'Category').split('|').each do |taxon_group|
        if taxon_group.include?('->')
          parent, child = taxon_group.strip.split('->').map(&:strip)
          taxonomy = Spree::Taxonomy.find_or_create_by!(name: parent)
          taxon = Spree::Taxon.find_by(name: child)
          if taxon
            taxons << taxon
          else
            taxon = taxonomy.root.children.create!(name: child, taxonomy_id: taxonomy.id)
          end
          taxons << taxon
        else
          raise "Invalid category format."
        end
      end
      taxons
    end

    def make_product(row_hash, mappers)
      puts "================================="
      puts "make_product #{row_hash}"
      puts Spree::Config[:currency]
      product = Spree::Product.joins(:master).where("spree_variants.sku = ?", get_value(row_hash, mappers, 'Product SKU')).first
      unless product
        product = Spree::Product.create!( name: get_value(row_hash, mappers, 'Product Name'),
                                          sku: get_value(row_hash, mappers, 'Product SKU'),
                                          price: get_value(row_hash, mappers, 'Product Price').to_f,
                                          description: get_value(row_hash, mappers, 'Product Description'),
                                          available_on: Time.zone.now - 2.days,
                                          shipping_category_id: Spree::ShippingCategory.first.id )
      end

      # make property
      get_value(row_hash, mappers, 'Product Property', true).each do |property_name, property_value|
        product.set_property(property_name, property_value.split('|').map(&:strip).join("\n"))
      end

      # make variants
      options = []
      option_values = []
      get_value(row_hash, mappers, 'Product Option', true).each do |option_name, option_value|
        value = option_value.kind_of?(Numeric) ? option_value.to_i.to_s : option_value.strip
        options << {name: option_name, value: value}

        option_type = Spree::OptionType.where(name: option_name).first_or_initialize do |o|
          o.presentation = option_name
          o.save!
        end

        option_value = Spree::OptionValue.where(option_type_id: option_type.id, name: value).first_or_initialize do |o|
          o.presentation = value
          o.save!
        end

        option_values << option_value
      end

      # puts "options = #{options}"
      # puts "product_has_options = #{product_has_options?(product, options)}"
      unless product_has_options?(product, options)
        variant = product.variants.build( price: get_value(row_hash, mappers, 'Product Price').to_f,
                                          weight: get_value(row_hash, mappers, 'Product Weight'),
                                          height: get_value(row_hash, mappers, 'Product Height'),
                                          width: get_value(row_hash, mappers, 'Product Width'),
                                          depth: get_value(row_hash, mappers, 'Product Depth'))
        variant.options = options # trigger save!
      end

      product
    end

    # if single, return value for the given name
    # if multiple, return hash for the given name
    def get_value(row_hash, mappers, mapping_name, multiple=false)
      return row_hash[mappers.key(mapping_name)] unless multiple

      matched_names = mappers.map {|k, v| k if v == mapping_name}.compact
      row_hash.slice(*matched_names)
    end

    def product_has_options?(product, option_values)
      # return false unless product.has_variants?

      product.variants.each do |variant|
        if (variant.option_values - option_values).size == 0
          return true
        end
      end

      # scoped = Spree::Product.where(id: product.id)
      # options.each do |option|
      #   scoped = scoped.with_option_value(option[:name], option[:value])
      # end
      # puts "SQL = #{scoped.to_sql}"
      # scoped.any?
    end
  end
end