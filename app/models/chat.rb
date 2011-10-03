class Chat < ActiveRecord::Base
  belongs_to :profile
    
  # can_has_chat  :user_attribute => :jabber_username,
  #               :log_chats => false,
  #               :namespace => "7am_muc"

  def jabber_username
    profile.user.login
  end
    
end