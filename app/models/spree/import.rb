module Spree::Import
  def self.table_name_prefix
    'spree_import_'
  end

  def self.use_relative_model_naming?
    true
  end
end
