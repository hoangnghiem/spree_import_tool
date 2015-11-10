class Spree::Admin::Utilities::TestBackgroundJobsController < Spree::Admin::BaseController

  def show

  end

  def create
    Spree::TestBackgroundJobWorker.perform_async(params[:test_background_job][:email])
    flash[:success] = 'Email sending job is added to background job for processing. Please check email in 5 minutes.'
    redirect_to admin_utilities_test_background_job_url
  end
end