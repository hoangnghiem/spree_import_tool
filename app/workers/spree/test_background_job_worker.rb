module Spree
  class TestBackgroundJobWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker
    sidekiq_options retry: false

    def perform(email)
      ::Spree::TestMailer.send_test_background_job_email(email).deliver_now
    end
  end
end