class CreateSpreeImportMappers < ActiveRecord::Migration
  def change
    create_table :spree_import_mappers do |t|
      t.references :source, index: true
      t.string :user_field
      t.string :system_field
      t.string :sample

      t.timestamps null: false
    end
  end
end
