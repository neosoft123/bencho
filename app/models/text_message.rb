include ActionController::UrlWriter

class TextMessage < ActiveRecord::Base
  
  # Errors
  class NoPhoneNumber < StandardError; end
    
  belongs_to :profile
  belongs_to :recipient, :class_name => 'Profile'
  belongs_to :billed_to, :class_name => 'Profile'
  belongs_to :service
  #before_save :bill
# before_create :check_provided_for, :if => :billable?
  
  money :cost, :cents => :cost
  
  def self.create_chat_invite(from, to)
    # TODO: Refactor into seperate models. e.g. ChatInvite < TextMessage
    service = Service.find_by_title(Service::CHAT_INVITE_SERVICE)
    raise StandardError.new('Chat Invite Service not found. Please run rake task') unless service
    raise StandardError.new('No mobile number for recipient') unless to.mobile
    builder = SmsBuilder.new(:partial => "sms/chat_invite")
    href = Shortlink.shortlinkify(profile_chatter_url(from))

    message = builder.render_to_string(binding)
    
    text_message = from.text_messages.create(
        :recipient => to,
        :billed_to => from,
        :to => to.mobile, :message => message,
        :billable => true,
        :service => service
        )
        
    Delayed::Job.enqueue(SmsJob.new(text_message.id))
  end
  
  # Text Message Billing
  def billable?
    billable == true
  end
  
  def bill!
    self.billed_to.wallet.charge_for_text_message(self) if self.billed_to && billable?
  end
    
  protected
  def check_provided_for
    
    RAILS_DEFAULT_LOGGER.debug "Checking account balances"
    
    if billed_to and service
      unless billed_to.wallet.provided_for?(service.debit)
        RAILS_DEFAULT_LOGGER.debug "Account #{billed_to.id} has insufficient funds (#{billed_to.wallet.balance.format})"
        raise Wallet::InsufficientFunds.new()
      else
        self.cost = service.debit
        billed_to.wallet.reserve_funds(self.cost)
      end
      RAILS_DEFAULT_LOGGER.debug "Account #{billed_to.id} has sufficient funds (#{billed_to.wallet.balance.format})"
    end
    true
  end
  
end
