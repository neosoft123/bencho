namespace :kontact do
  
  task :setup_standard_services => :environment do
    puts "Setting up Standard Services"
    
    Service.delete_all('price_in_cents is null and active = 0')
    chat_invite = Service.create!(:title => "ChatInvite", :description => "Chat Invite", :debit => 1)
    friend_invite = Service.create!(:title => "FriendInvite", :description => "Friend Invite", :debit => 1)
    group_invite = Service.create!(:title => "GroupInvite", :description => "Group Invite", :debit => 1)
    feed_item = Service.create!(:title => "FeedNotification", :description => "Feed Notification", :debit => 1)
    
    mini = Service.create!(:title => "Mini-Messenger", :description => "Mini-Messenger gives you 5 messages for R2", 
      :credit => 5, :price_in_cents => 200, :sts_service_id => 'b66d78e3-08c9-4db6-8334-b3749b9a43a6')
    
    midi = Service.create!(:title => "Midi-Messenger", :description => "Midi-Messenger gives you 12 messages for R5", 
        :credit => 12, :price_in_cents => 500, :sts_service_id => '238c8501-00cb-41e3-97b4-a7353f253e6c')
        
    maxi = Service.create!(:title => 'Maxi-Messenger', :description => 'Maxi-Messenger gives you 25 messages for R10',
        :credit => 25, :price_in_cents => 1000, :sts_service_id => 'baa19904-03fb-4c67-96c0-e43bec11edbd')
  end
  
end
