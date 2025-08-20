class TestEmailWorker
  @queue = :test_emails
  
  def self.perform(recipient)
    puts "TestEmailWorker: Sending test email to #{recipient}"
    TestMailer.test_email(recipient).deliver_now
    puts "TestEmailWorker: Email sent to #{recipient}"
  end
end