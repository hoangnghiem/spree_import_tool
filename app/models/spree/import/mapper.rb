class Spree::Import::Mapper < ActiveRecord::Base

  belongs_to :source, class_name: 'Spree::Import::Source'
  validates :user_field, presence: true, uniqueness: {scope: :source_id}
  validates :system_field, presence: true

  SYSTEM_FIELD_OPTIONS = [
    'Category',
    'Product Name',
    'Product SKU',
    'Product Description',
    'Product Price',
    'Product Sale Price',
    'Product Cost Price',
    'Product Weight',
    'Product Height',
    'Product Width',
    'Product Depth',
    'Product In Stock Count',
    'Product Option',
    'Product Property',
  ]
end