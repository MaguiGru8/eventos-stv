class TestEmailsController < ApplicationController
  def send_test
    recipient = params[:email] || 'your-email@example.com'
    
    # Try direct delivery first
    TestMailer.test_email(recipient).deliver_now
    
    # Then try with Resque
    Resque.enqueue(TestEmailWorker, recipient)
    
    render plain: "Test emails sent directly and via Resque to #{recipient}. Check your inbox and server logs."
  end
end