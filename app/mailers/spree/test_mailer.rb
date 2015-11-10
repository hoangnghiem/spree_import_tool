class Spree::TestMailer < Spree::BaseMailer

  def send_test_background_job_email(email)
    mail(to: email, subject: 'Background Job is working!')
  end
end