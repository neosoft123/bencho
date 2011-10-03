ActionController::Routing::Routes.draw do |map|
  map.resources :homes

  map.resources :admin_sessions

  map.resources :admins
     
  
  map.admin "admin/index", :controller=>'admins', :action=>'index'   
  map.showuser "users/showuser", :controller => 'users', :action =>'showuser' 
  map.twitter_feed 'twitter/:username', :controller => 'twitter', :action => 'feed'
  map.twitter_follow 'twitter/:username/follow', :controller => 'twitter', :action => 'follow'
  map.twitter_followers 'twitter/:username/followers', :controller => 'twitter', :action => 'followers'
  map.twitter_following 'twitter/:username/following', :controller => 'twitter', :action => 'following'
 
  map.facebook_profile 'facebook/:username', :controller => 'facebook', :action => 'getprofile'
  
  
  map.resources :global_feed_items
  map.resources :billing_entries

  map.resources :devices do |device|
    device.resources :device_attributes
  end
  
  map.report_content_create '/report-content/create', :controller => 'content_reporting', :action => 'create', :method => :post
  
  map.hide_help '/help/hide', :controller => 'help', :action => 'hide'
  map.show_help '/help/show', :controller => 'help', :action => 'show'
  
  # messages
  # map.destroy_all_sent_messages 'messages/destroy_all_sent', :controller => 'messages', :action => 'destroy_all_sent'
  map.destroy_all_received_messages 'profiles/:profile_id/messages/destroy_all_received', :controller => 'messages', :action => 'destroy_all_received'
  map.destroy_some_messages '/messages/destroy_some_received', :controller => 'messages', :action => 'destroy_some_received'
  map.new_recipient '/messages/new_recipient', :controller => 'messages', :action => 'new_recipient'
  map.add_recipient '/messages/add_recipient', :controller => 'messages', :action => 'add_recipient', :method => :post
  map.new_multi_message '/messages/new_multi_message', :controller => 'messages', :action => 'new_multi_message'
  map.bulk_message '/messages/bulk_message', :controller => 'messages', :action => 'bulk_message'
  map.create_multi_message '/messages/create_multi_message', :controller => 'messages', :action => 'create_multi_message', :method => :post
  map.create_bulk_message '/messages/create_bulk_message', :controller => 'messages', :action => 'create_bulk_message', :method => :post
  map.message_sendto 'profile/:profile_id/messages/sendto/:id', :controller => 'messages', :action => 'sendto'
  map.message_profile_reply 'profile/:profile_id/messages/:id/reply', :controller => 'messages', :action => 'reply'
  map.message_group_reply 'groups/:group_id/messages/:id/reply', :controller => 'messages', :action => 'reply'
  map.new_message '/messages/new_message', :controller => 'messages', :action => 'new_message'
  map.save_message '/messages/save_message', :controller => 'messages', :action => 'save_message'
  map.save_comment '/messages/save_comment', :controller => 'messages', :action => 'save_comment'
  map.welcome_message '/messages/welcome_message', :controller => 'messages', :action => 'welcome_message'

  # feedback (email)
  map.feedback 'feedback', :controller => 'messages', :action => 'feedback'
  map.feedback_send 'feedback/send', :controller => 'messages', :action => 'feedback_send'
  
  # group shared contacts
  map.profile_shared_contacts_add 'profile/:profile_id/contacts/shared/add', :controller => 'kontacts', :action => 'add_shared_contacts'
  map.profile_shared_contacts 'profile/:profile_id/contacts/shared', :controller => 'kontacts', :action => 'shared_contacts'
  map.unshare_group_contact 'groups/:id/unshare/:kontact_id', :controller => 'groups', :action => 'unshare_contact'
  
  # group invitations
  map.group_invite 'groups/:group_id/invitation/:id', 
    :controller => 'groups', :action => 'invitation'
  map.group_invite_accept 'groups/:group_id/invitation/:id/accept', 
    :controller => 'groups', :action => 'invite_accept'
  map.group_invite_decline 'groups/:group_id/invitation/:id/decline', 
    :controller => 'groups', :action => 'invite_decline'

  # chat
  map.profile_chatter_refresh 'profiles/:profile_id/chat/refresh', :controller => 'profiles', :action => 'chat_refresh'
  map.profile_chatter 'profiles/:profile_id/chat', :controller => 'profiles', :action => 'chat'
  map.profile_chatter_send 'profiles/:profile_id/chat/send', :controller => 'profiles', :action => 'chat_send'
  map.profile_unread_messages 'profiles/:profile_id/unread_messages', :controller => 'profiles', :action => 'unread_messages'
  map.send_chat_message 'profiles/:profile_id/chat/send-message', :controller => 'profiles', :action => 'send_chat_message'
 # map.online_results 'profiles/online_results', :controller => 'profiles', :action => 'online_results'

  # invitations
  map.adhoc_invitation 'profiles/:profile_id/invitations/adhoc', :controller => 'invitations', :action => 'adhoc_invitation'
  map.process_invitation 'invitation/:code/accept', :controller => 'users', :action => 'create'
  map.invitation 'invitation/:code', :controller => 'invitations', :action => 'accept_invitation'
  map.create_kontact_invitation 'profiles/:profile_id/invitations/create/:kontact_id',
    :controller => 'invitations', :action => 'create_for_kontact'
  map.force_kontact_invitation 'profiles/:profile_id/invitations/create/force/:kontact_id',
    :controller => 'invitations', :action => 'force_invitation'

  # friends/followers
  map.friend 'profiles/:profile_id/friend/:other_profile_id', :controller => 'profiles', :action => 'friend'
  map.follow 'profiles/:profile_id/follow/:other_profile_id', :controller => 'profiles', :action => 'follow'
  map.stop_following 'profiles/:profile_id/follow/:other_profile_id/stop', :controller => 'profiles', :action => 'stop_following'

  map.my_online_friends 'profiles/:profile_id/friends/online', :controller => 'friends', :action => 'online_friends'
  map.my_friends 'profiles/:profile_id/friends/friends', :controller => 'friends', :action => 'friends'
  map.my_active_chat 'profiles/:profile_id/friends/active_chat', :controller => 'friends', :action => 'active_chat'
  map.my_friend_requests 'profiles/:profile_id/friends/requests', :controller => 'friends', :action => 'requests'
  map.my_followings 'profiles/:profile_id/friends/following', :controller => 'friends', :action => 'followings'
  map.my_followers 'profiles/:profile_id/friends/followers', :controller => 'friends', :action => 'followers'
  
  # All online users
  map.everyone_online 'profiles/:profile_id/everyone/online', :controller => 'friends', :action => 'everyone_online'
  
  # facebook
  map.facebookauth 'facebookauth', :controller => 'settings', :action => 'facebookauth'
  map.facebooksend 'profiles/:profile_id/profile_statuses/:id/facebook', :controller => 'profile_statuses', :action => 'facebook_send'
 # map.facebookstatus 'profiles/:profile_id/profile_statuses/:id/facebook', :controller => 'profile_statuses', :action => 'facebookpost'
  map.facebook_photo_upload 'profiles/:profile_id/photos/:id/upload/facebook', :controller => 'photos', :action => 'facebook_upload'
  map.facebook_key 'facebook_key', :controller => 'settings', :action => 'facebook_key'
  map.facebook_autho 'facebook_autho', :controller => 'settings', :action => 'facebook_autho'
  map.resource  :settings, :collection => {:facebook_oauth_callback => :get}
 

  # twitter
  map.twittersend 'profiles/:profile_id/profile_statuses/:id/twitter', :controller => 'profile_statuses', :action => 'twitter_send'
  map.twitterstatus 'profiles/:profile_id/profile_statuses/:id/twitterpost', :controller => 'profile_statuses', :action => 'twitterpost'
  map.twitter_requestauth 'twitter/requestauth', :controller => 'settings', :action => 'twitter_requestauth'
  map.twitterauth 'twitterauth', :controller => 'settings', :action => 'twitterauth'
  map.twitter_key 'twitter_key', :controller => 'settings', :action => 'twitter_key'
  
  # kontacts
  map.kontacts_by_letter 'profiles/:profile_id/kontacts/letter/:letter', :controller => 'kontacts', :action => 'by_letter'
  map.kontacts_sort_first_last 'profiles/:profile_id/kontacts/sort-first-last', :controller => 'kontacts', :action => 'sort_first_last'
  map.kontacts_sort_last_first 'profiles/:profile_id/kontacts/sort-last-first', :controller => 'kontacts', :action => 'sort_last_first'
  map.might_be_friends 'profiles/:profile_id/people-you-may-know', :controller => 'kontacts', :action => 'might_be_friends'

   map.flickr_photo_upload 'profiles/:profile_id/photos/:id/upload/flickr', :controller => 'photos', :action => 'flickr_upload'

  # location
  map.set_location 'profiles/:id/locations/set/:location', :controller => 'locations', :action => 'set'
    
  # business cards
  map.business_card_sync_settings 'profiles/:profile_id/business-card-sync-settings', :controller => 'profiles', :action => 'business_card_sync_settings'
  map.accept_share_business_card 'profiles/:profile_id/share-business-card-accept', 
    :controller => 'profiles', :action => 'accept_share_business_card'
  map.decline_share_business_card 'profiles/:profile_id/share-business-card-decline', 
    :controller => 'profiles', :action => 'decline_share_business_card'

  # wallets
  map.resources :wallets
  map.resources :services
  
  map.resources :adverts
  map.advert_clickthru 'adverts/:id/clickthru', :controller => 'adverts', :action => 'clickthru'

  map.resources :kontacts , :member => { 
    :upload_icon => :post ,
    :set_phone_number_value => :post,
    :set_email_value => :post
  }

  map.confirm "/c/:id/:code" , :controller => 'users' , :action => 'confirm'
  map.resources :users, :member => { 
    :suspend   => :put,
    :unsuspend => :put,
    :purge     => :delete,
    :change_password => :get,
    :change_password_do => :post
  }
  
  map.resource :session

  map.resources :applications
  
  # map.resources :locations
  map.resources :oauth_clients
  map.resources :chats

  map.namespace :admin do |a|
    a.resources :users, :collection => {:search => :post}
    a.resources :device_contents
    a.resources :help
    a.root      :controller => :home
  end
  
  map.resource :settings, :member => {
    :twitterauth => :get,
    :twitter => :get,
    :twitter_options => :get,
    :twitter_do => :post,
    :twitter_off => :get,
    :fireeagle => :get,
    :fireeagle_off => :get,
    :fireeagle_activate => :get,
    :fireeagle_callback => :get,
    :facebook => :get,
    :facebook_off => :get,   
    :facebook_options => :get,
    :facebook_do => :post,
    :facebook_extended_auth => :get,
    :facebook_extended_read_auth => :get,
    :privacy => :get,
    :privacy_do => :post
  }

  # REVIEW: What resource does this relate to? Profile? 
  map.basic_privacy_profile '/set_basic_privacy' , :controller => 'profiles' , 
    :action => 'set_privacy' , :setting => "search"
  map.contact_privacy_profile '/set_contact_privacy' , :controller => 'profiles', 
    :action => 'set_privacy' , :setting => "contact"
  map.additional_privacy_profile '/set_additional_privacy' , :controller => 'profiles', 
    :action => 'set_privacy' , :setting => "additional"

  # map.resources :locations, :member => {:geocode => :get}
  map.resource :script
  map.resource :mobile
  
  map.resources :groups, :has_many => [:messages, :group_invitations], :member => {
    :invite => :get,
    :send_invites => :post,
    :share_contacts => :get,
    :shared_contacts => :get,
    :share_contacts_do => :post,
    :leave => :get,
    :members => :get,
    :join => :get
  } do |group|
    group.resources :kontacts
  end
  
  map.browse_public_groups 'public-groups', :controller => 'groups', :action => 'browse_public'
    
  map.resources :profiles, 
    :member => { 
      :provision_number => :get,
      :provision => :get,
      :provision_proc => :post,
      :delete_icon => :post, 
      :check_in => :post ,
      :upload_icon => :post,
      :set_location => :post ,
      :reload_public => :post,
      :add_email => :post,
      :delete_email => :delete,
      :delete_number => :delete,
      :add_number => :post,
      :set_mobile => :post,
      :set_details => :post,
      :set_profile_email => :post,
      :set_profile_location => :post,
      :set_phone_number_value => :post,
      :wizard => :get,
      :remote_resend_mobile => :get,
      :chatjs => :get,
      :messengerjs => :get,
      :chat_invite => :get,
      :conversation_refresh_js => :get,
      :conversation_refresh => :get,
      :chat_login => :get,
      :chat_login_proc => :post,
      :online_friends => :get,
      :create_business_card => :get,
      :business_cards => :get,
      :request_business_card => :get,
      :business_card => :get,
      :change_avatar => :get,
      :basic_search => :get,
      :basic_search_do => [:get, :post],
      :profile_search => :get,
      :profile_search_do => :post,
      :friend_search => :get,
      :friend_search_do => :post, 
      :online_search => :get,
      :online_search_do => [:get, :post],
      :newprofile_search => :get,
      :newprofile_search_do => [:get, :post],
      :all_search => :get,
      :all_search_do => [:get, :post],
      :subscribe => :get,
      :unsubscribe => :get,
      :subscriptions => :get,
      :subscriptions_do => :post,
      :followers => :get,
      :following => :get,
      :online_results => [:get, :post]
    },
    :has_many=>[:friends, :comments, :feed_items, :messages, :kontacts, :invitations, :text_messages] do |profile|
      profile.resource :dating_profile, 
        :member => { :matches => :get, :pay => :get, :transaction_history => :get }, 
        :new => { :notice => :get }
      profile.resources :kontacts, :collection => {:sync => :post} do |kontact|
        kontact.resource :kontact_information do |ki|
          ki.resources :phone_numbers
          ki.resources :emails
          ki.resources :plural_fields # Editing email and phone numbers on mobile
          ki.resource :avatar
        end
      end
      profile.resource :wallet do |wallet|
        wallet.resources :account_entries
      end
      profile.resource :script, :member => {:xmpp => :get}
      profile.resources :profile_statuses do |profile_status|
        profile_status.resources :comments
      end
      profile.resources :photos, :member => {:download => :get} do |photo|
        photo.resources :comments
      end
      profile.resources :blogs do |blog|
        blog.resources :comments
      end
      profile.resources :global_feed_items do |gfi|
        gfi.resources :comments
      end
      profile.resource :mobile, :member => {
        :intro => :get,
        :provisioning => :get,
        :sync_help => :get
      }
      
      profile.resources :chats, :member => {:send_message => :post, 
        :chatjs => :get,
        :start_chat => :post,
        :converse => :post }
      profile.resources :locations, :member => {:stream => :get} do |location|
        location.resources :comments
#        location.resources :feed_items # This is hi-jacking the feed_items controller a bit but since it's not used for anything else...
      end
  end    
  
 

  map.sony_ericsson '/sync-instructions/sony-ericsson' , :controller => 'mobiles' , :action => 'sony_ericsson'
  map.nokia_e_series '/sync-instructions/nokia-e-series' , :controller => 'mobiles' , :action => 'nokia_e_series'
  map.nokia_n_series '/sync-instructions/nokia-n-series' , :controller => 'mobiles' , :action => 'nokia_n_series'
  map.nokia_6630 '/sync-instructions/nokia-6630' , :controller => 'mobiles' , :action => 'nokia_6630'
  map.nokia_6230 '/sync-instructions/nokia-6230' , :controller => 'mobiles' , :action => 'nokia_6230'
  map.nokia_6300 '/sync-instructions/nokia-6300' , :controller => 'mobiles' , :action => 'nokia_6300'
  
  # profile search
  # map.basic_profile_search_proc 'profiles/search/basic/proc', :controller => 'profiles', :action => 'basic_search_proc'
  # map.basic_profile_search 'profiles/search/basic', :controller => 'profiles', :action => 'basic_search'
  map.profile_search 'profiles/search/*specs', :controller => 'profiles', :action => 'search'

  # kontact search
  map.basic_kontact_search 'profile/:profile_id/kontacts/search/basic', :controller => 'kontacts', :action => 'basic_search'
  map.basic_kontact_search_proc 'profile/:profile_id/kontacts/search/basic/proc', :controller => 'kontacts', :action => 'basic_search_proc'

  # comments
  map.create_comment '/create_comment', :controller => 'comments', :action => 'create_comment'
  map.more_profile_status_comments '/more_profile_status_comments/:profile_status_id', :controller => 'comments', :action => 'more_profile_status_comments'

  map.resources :messages, :collection => {:sent => :get}
  
  map.resources :forums, :collection => {:update_positions => :post} do |forum|
    forum.resources :topics, :controller => :forum_topics do |topic|
      topic.resources :posts, :controller => :forum_posts
    end
  end
  
  # RESTful Authentication
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.signup_with_number '/signup/:phone_number', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot-password', :controller => 'sessions', :action => 'forgot_password'
  map.send_reset_password '/send-reset-password', :controller => 'sessions', :action => 'send_reset_password'
  map.reset_password '/reset-password/:code', :controller => 'sessions', :action => 'reset_password'
  map.reset_password_do '/reset-password-do/:user_id', :controller => 'sessions', :action => 'reset_password_do'
  
  map.remind_me_to_sync_later '/remind-me-to-sync-later', :controller => 'users', :action => 'remind_me_to_sync_later', :method => :put
  
  map.preview 'preview', :controller => "sessions", :action => "preview"
  map.admin_login 'admin_login', :controller => "users", :action => "admin_login"
  # Application Framework OAuth
  map.oauth '/oauth',:controller=>'oauth',:action=>'index'
  map.authorize '/oauth/authorize',:controller=>'oauth',:action=>'authorize'
  map.request_token '/oauth/request_token',:controller=>'oauth',:action=>'request_token'
  map.access_token '/oauth/access_token',:controller=>'oauth',:action=>'access_token'
  map.test_request '/oauth/test_request',:controller=>'oauth',:action=>'test_request'
  
  map.with_options(:controller => 'home') do |home|
    home.latest_comments '/latest_comments.rss', :action => 'latest_comments', :format=>'rss'
    home.newest_members '/newest_members.rss', :action => 'newest_members', :format=>'rss'
    home.tos '/tos', :action => 'terms'
    home.contact '/contact', :action => 'contact'
    home.anon '/home', :action =>'index'
  end

  map.mark_map_location '/mark_map_location' , :controller => 'sessions' , :action => 'mark_map_location'
  map.confirm_mobile '/confirm_mobile' , :controller => 'users' , :action => 'confirm_mobile'
  map.public_stream 'welcome/public', :controller => 'welcome', :action => 'public'
  map.seven_stream 'welcome/seven_stream', :controller => 'welcome', :action => 'seven_stream'
  map.welcome '/welcome/index', :controller => 'welcome', :action => 'index'
  map.twitter '/welcome/twitter', :controller => 'welcome', :action => 'twitter'
  map.facebook '/welcome/facebook', :controller => 'welcome', :action => 'facebook'
  map.main_menu 'welcome/main-menu', :controller => 'welcome', :action => 'main_menu'
  map.home '/', :controller => 'home', :action => 'index'
  map.check '/check', :controller => 'home', :action => 'check'
  map.usercheck '/usercheck', :controller => 'home', :action => 'users'
  map.device_check 'device-check', :controller => 'home', :action => 'device_check'
  map.terms '/terms_and_conditions', :controller => 'users', :action => 'tnc'
  
  map.make_short 'make_short', :controller => 'shortlinks', :action => 'make'
  map.made_short 'made_short', :controller => 'shortlinks', :action => 'made'
  map.linky ':href_code', :controller => 'shortlinks', :action => 'handle', :href_code => /(\w+|\d+)/
  
  map.connect '*path', :controller => 'application', :action => 'rescue_404'# unless ::ActionController::Base.consider_all_requests_local
end
