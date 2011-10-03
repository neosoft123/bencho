module WelcomeHelper
  
  def build_menu_items
    @menu_items = [
      ['Privacy Settings', privacy_settings_path],
      ['Gallery Pics'],
      ['Gallery Videos'],
      ['Sync  My Phone'],
      ['My Contacts'],
      ['Business Cards '],
      ['My Groups'],
      ['MY diary'],
     # ["My Location", profile_locations_url(@p)],
     # ["My Status", profile_profile_statuses_url(@p)],
     # ["My Photos", profile_photos_url(@p)],
     # ["My Mailbox (#{@p.unread_messages.length})", profile_messages_url(@p)],
     # ["My Subscriptions", subscriptions_profile_url(@p)],
      ["Invite a Friend", new_profile_invitation_url(@p)],
      #["Chat (#{pluralize(@p.online_friends.length, "friend")} online)", my_online_friends_path(@p)],
     # ["Search", basic_search_profile_path(@p)],
     # ["Friends & Followers", profile_friends_url(@p)],
      # ["People You Might Know", might_be_friends_path(@p)],
      # ["Group Contacts (#{@p.shared_contacts_count})", profile_shared_contacts_url(@p)],
      
    ]
    
    unless @p.dating_profile
      @menu_items.insert(1, ["Create Dating Profile", notice_new_profile_dating_profile_url(@p)])
    else
      @menu_items.insert(1, ["My Dating Profile", profile_dating_profile_url(@p)])
    end
    
    @menu_items.unshift ["Advert Management", adverts_path] if @u.is_admin?
    @menu_items.unshift ["Global Feed Items", global_feed_items_path] if @u.is_admin?
    @menu_items.unshift ["Current Users: #{@user_count}", "#"] if @u.is_admin?    
  end
  
  def caption_text(active)
    return "My Twitter Stream" if active == :twitter
    return "My Facebook Stream" if active == :facebook
    return "Public Stream" if active == :public_stream
    return "My Stream" if active == :my_stream
    return "7am Stream" if active == :seven_stream
    return "Public Stream" if active == :preview
    return "Profile Stream" if active == :profile_stream 
  
  end

  
  def caption_class(active, icon)
    return "big_caption" if active == icon
    "small_caption"
  end
  
end
