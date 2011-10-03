class Wallet < ActiveRecord::Base

  class InsufficientFunds < StandardError; end
  
  money :balance, :cents => :balance
  money :reserve, :cents => :reserve
  money :available, :cents => :available
  
  belongs_to :profile
  has_many :account_entries
  
  def pay_dating_subscription!
    Delayed::Job.enqueue(DatingSubscriptionJob.new(self.profile.id))
  end
  
  def buy_smartbucks(service, free_service=false)
    account_entry = self.account_entries.build(:service => service, :credit => service.credit)
    account_entry.save!
    Delayed::Job.enqueue(BillingJob.new(account_entry.id)) unless free_service
    account_entry
  end
  
  def spend_smartbucks(service)
    account_entry = self.account_entries.build(:service => service, :debit => service.debit)
    account_entry.save!
    
    unless provided_for?(service.debit) 
      account_entry.reason = "Not enough SmartBucks to deliver #{service.title}"
      account_entry.error_code = b.response.code
      account_entry.denied!
      raise InsufficientFunds.new
    end
    
    account_entry.success 
  end 

  def charge_for_text_message(text_message)
    transaction do
      account_entry = self.account_entries.create(:service => text_message.service, :debit => text_message.cost)    
      unreserve_funds(text_message.cost)
      unless provided_for?(text_message.cost) 
        account_entry.reason = "Not enough SmartBucks to deliver #{service.title}"
        account_entry.error_code = b.response.code
        account_entry.denied!
        raise InsufficientFunds.new
      end
      account_entry.success
    end
  end 
  
  def credit(value)
    self.balance = self.balance + value
    self.save!
  end
  
  def debit(value)
    self.balance = self.balance - value
    self.save!
  end
  
  def available
    self.balance - self.reserve
  end
  
  def provided_for_service?(service)
    provided_for? service.debit
  end
  
  def provided_for?(value)
    (self.balance - self.reserve - value) >= Money.empty
  end
  
  def reserve_funds(value)
    update_attribute(:reserve, self.reserve + value)
  end
  
  def unreserve_funds(value)
    update_attribute(:reserve, self.reserve - value)
  end
  
end
