class SubscriptionBillingEntry < ActiveRecord::Base
  
  belongs_to :profile
  belongs_to :service
  
  include AASM
  
  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :processed
  aasm_state :denied
  aasm_state :error
  
  aasm_event :processed do
    transitions :to => :processed, :from => [:pending, :error]
  end

  aasm_event :denied do
    transitions :to => :denied, :from => [:pending, :error]
  end
  
  aasm_event :error do
    transitions :to => :error, :from => [:pending]
  end
  
end
