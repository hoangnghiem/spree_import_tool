class Spree::Admin::Utilities::MappingsController < Spree::Admin::BaseController

  before_action :find_source

  def show
    @source.mapping_preview.each do |header, data|
      mapper = @source.mappers.find_or_initialize_by(user_field: header)
      mapper.sample = data.kind_of?(String) ? data.try { truncate(50) } : data
    end
  end

  def create
    if @source.update_attributes(source_params)
      flash[:success] = 'System started import processing.'
      redirect_to run_admin_utilities_source_path(@source)
    else
      render :show
    end
  end

  private

  def source_params
    params.require(:source).permit(:identifier_field, mappers_attributes: [:id, :user_field, :system_field, :identifier, :sample])
  end

  def find_source
    @source = Spree::Import::Source.find(params[:source_id])
  end

end