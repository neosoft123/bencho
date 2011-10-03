class JabberMessage < ActiveRecord::Base

  belongs_to :owner, :class_name => 'User'
  belongs_to :from, :class_name => 'User'
  belongs_to :to, :class_name => 'User'
  
  after_create :check_offline
  
  named_scope :unread, :conditions => { :read => false }
  named_scope :from_profile, 
    proc { |from_profile|
      {
        :conditions => { :from_id => from_profile.user.id }
      }
    } 
  named_scope :from_user, 
    proc { |from_user|
      {
        :conditions => { :from_id => from_user.id }
      }
    } 

    named_scope :with,
     proc { |with|
       {
         :conditions => ["((from_id = :with_id or from_id = :with_id)) or ((to_id = :with_id or to_id = :with_id))", {
           :with_id => with.id }]
       }
     }
       
   named_scope :latest, :order => 'created_at desc', :limit => 10
   
   private 
   
   def check_offline
      return if to.online?
      puts "Cannot deliver message, user is offline: #{to.login}"
      return if ChatReminderMessage.exists?(
          :receiver_id => to.profile.id,
          :receiver_type => 'Profile',
          :sender_id => from.profile.id,
          :sender_type => 'Profile',
          :read => false
        )
        puts "User does not have an existing reminder"
      ChatReminderMessage.create!(
        :subject => "Chat messages from #{from.profile.f}",
        :body => "The body of this message will be generated at render time",
        :receiver => to.profile,
        :sender => from.profile
      )
      puts "Reminder created"
    rescue => e
      puts "ERROR: #{e.inspect}"
   end
    
end
