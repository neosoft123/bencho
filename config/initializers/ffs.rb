require RAILS_ROOT + '/lib/has_business_card'

ActiveRecord::Base.class_eval do
  include HasBusinessCard
end
