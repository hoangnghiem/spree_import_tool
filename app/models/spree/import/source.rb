require 'roo'

class Spree::Import::Source < ActiveRecord::Base
  has_many :mappers, :class_name => "Spree::Import::Mapper", :foreign_key => "source_id", :dependent => :destroy
  accepts_nested_attributes_for :mappers

  has_attached_file :file,
                    url: '/spree/import/source/:id/:basename.:extension',
                    path: ':rails_root/public/spree/import/source/:id/:basename.:extension'

  validates_attachment :file,
                       :presence => true,
                       :content_type => {
                          :content_type => %w(application/vnd.ms-office application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet),
                          :message => "Invalid file type. Only EXCEL file is accepted."
                        }

  def mapping_preview
    spreadsheet = open_source_file
    header = spreadsheet.row(1).inject ([]) {|arr, h| arr << h.try(:strip) }
    Hash[[header, spreadsheet.row(2)].transpose]
  end

  def open_source_file
    case File.extname(file_file_name)
    when ".csv" then ::Roo::Csv.new(file.path)
    when ".xls" then ::Roo::Excel.new(file.path)
    when ".xlsx" then ::Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

end
