class TestMailer < ApplicationMailer
  def test_email(recipient)
    mail(
      to: recipient,
      subject: 'Test Email from Rails App',
      body: 'This is a test email to verify that email delivery is working.'
    )
  end
end