class BillingEntry < ActiveRecord::Base
  belongs_to :account_entry
end
