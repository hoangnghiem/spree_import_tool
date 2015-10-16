class Spree::Admin::Utilities::SourcesController < Spree::Admin::BaseController

  def index
    @source = Spree::Import::Source.new
  end

  def create
    @source = Spree::Import::Source.new(source_params)

    if @source.save
      redirect_to admin_utilities_source_mapping_path(@source), notice: 'File upload successfully.'
    else
      render :index
    end
  end

  def run
    @source = Spree::Import::Source.find(params[:id])
  end

  private

  def source_params
    params.fetch(:source, {}).permit(:file)
  end

end