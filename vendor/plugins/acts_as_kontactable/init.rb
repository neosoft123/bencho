require 'acts_as_kontactable'
# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
ActiveRecord::Base.class_eval do
  include Agilisto::Acts::Kontactable
end

