class ChatInvitation < ActiveRecord::Base
  
  belongs_to :from, :class_name => 'Profile'
  belongs_to :to, :class_name => 'Profile'
  
end
