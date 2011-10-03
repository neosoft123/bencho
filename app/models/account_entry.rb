class AccountEntry < ActiveRecord::Base

  belongs_to :wallet
  belongs_to :service
  has_many :billing_entries

  money :debit, :cents => :debit
  money :credit, :cents => :credit
  
  include AASM
  
  named_scope :recent, :order => 'created_at desc', :limit => 10

  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :processed
  aasm_state :denied
  aasm_state :error

  def success
    credit_debit()
    processed!
  end

  aasm_event :processed do
    transitions :to => :processed, :from => [:pending, :error]
  end

  aasm_event :denied do
    transitions :to => :denied, :from => [:pending, :error]
  end
  
  aasm_event :error do
    transitions :to => :error, :from => [:pending]
  end
   
  def formatted_amount
    return credit.format if credit
    "-#{debit.format}"
  end
  
  public
  def credit_debit
    self.wallet.debit(debit) if debit
    self.wallet.credit(credit) if credit
  end
  
end
