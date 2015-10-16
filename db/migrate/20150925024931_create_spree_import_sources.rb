class CreateSpreeImportSources < ActiveRecord::Migration
  def change
    create_table :spree_import_sources do |t|
      t.string :importer
      t.attachment :file
      t.string :identifier_field

      t.timestamps null: false
    end
  end
end
