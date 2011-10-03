class FeedbackMailer < ActionMailer::Base

  def send_feedback(user, subject, message)
    @message        = message
    @user           = user
    @subject        = "7.am Feedback: #{subject}"
    @recipients     = ['craigp@agilisto.com', 'armanddp@agilisto.com']
    @from           = MAILER_FROM_ADDRESS
    @headers        = {}
  end
  
end