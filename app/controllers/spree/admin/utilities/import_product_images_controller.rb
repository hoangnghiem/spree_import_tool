class Spree::Admin::Utilities::ImportProductImagesController < Spree::Admin::BaseController

  def index

  end

  def create
    filename = params[:file].original_filename
    sku = File.basename(filename, File.extname(filename)).split('__')[0]
    # extract sku from filename
    master = Spree::Variant.find_by(is_master: true, sku: sku)

    if master
      image = Spree::Image.new(attachment: params[:file], viewable_type: 'Spree::Variant', viewable_id: master.id)
      if image.save
        render :text => 'OK'
      else
        render json: {error: "Failed to upload image due to: #{image.errors.full_messages}"}, status: 422
      end
    else
      render json: {error: "Failed to upload image due to: No product with SKU #{sku}"}, status: 422
    end
  end

end