require 'uri'

class ProfilesController < ApplicationController
      
  include ApplicationHelper
  include MobilisedController
  include LocationisedController
  
  before_filter :preload_feed_item_models, :only => [:show]
  
  before_filter :setup, :except => [:index, :search , :set_phone_number_value , :set_profile_location , :set_profile_email , 
                                    :delete_email , :delete_number  ]
  before_filter :create_friends_map, :only => [:show]
  before_filter :search_results, :only => [:search]
  before_filter :set_location_map , :only => [ :edit , :wizard ]

  skip_filter :find_parent, :only => [ :set_phone_number_value , :set_profile_location , :set_profile_email , 
                                              :delete_email , :delete_number , :reload_public ]
  
  skip_filter :store_location, :only => [
    :messengerjs, :chatjs, :conversation_refresh_js, :conversation_refresh,
    :chat_send, :provision_proc, :chat_login, :chat_login_proc, :unread_messages, :chat_xmpp,
    :chat_invite, :follow, :stop_following, :update, :destroy, :create, :create_business_card
  ]
  
  # in_place_edit_for :profile , :mobile
  # in_place_edit_for :profile , :location
  # in_place_edit_for :profile , :email
  
  helper_method :private_view?
  
  skip_filter :setup_chat, :only => [ :unread_messages, :chat_login, :chat_login_proc, :chat_refresh, 
    :messengerjs, :chatjs, :conversation_refresh, :conversation_refresh_js, :create_business_card ]
    
  skip_filter :set_mobile_format, :only => [ :unread_messages ]
    
  def business_card_sync_settings
    ids = params[:sync].map{|id|id.to_i} rescue []
    BusinessCardProfile.set_sync_settings(ids)
    redirect_to business_cards_profile_path(@p)
  end
    
  def create_business_card
    @p.create_business_card
    flash[:notice] = "<h3>Business card created from profile</h3>You can now share your auto-updated business card contact details with friends"
    redirect_to @p
  end
  
  def request_business_card
    @p.request_business_card_for(@profile)
    body = render_to_string :partial => 'business_card_message'
    Message.send_message(@p, @profile, "Business Card Request", body)
    flash[:notice] = "<h3>Business card request sent</h3>#{@profile.f} will be notified of your request"
    redirect_back_or_default(@profile)
  end
  
  def accept_share_business_card
    if @p.share_business_card_with(@profile)
      flash[:notice] = "<h3>Business card shared</h3>You have shared your contact details with #{@profile.f}"
    else
      flash[:error] = "Business card request already processed"
    end
    redirect_back_or_default(welcome_path)
  end
  
  def decline_share_business_card
    if @p.decline_to_share_business_card_with(@profile)
      flash[:notice] = "<h3>Business card NOT shared</h3>You have declined to shared your contact details with #{@profile.f}"
    else
      flash[:error] = "Business card request already processed"
    end      
    redirect_back_or_default(welcome_path)
  end
  
  def business_cards
    @cards = @p.business_card_profiles.paginate(:page => params[:page], :per_page => 10)
  end
  
  def business_card
    @card = @profile.business_card
  end
    
  def chatjs
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def messengerjs
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  def chat_login
   # flash[:error] = "<h3>Please enter your password</h3>For security reasons please provide your password in order to be connected to chat." unless flash[:error]
  end
  
  def chat_login_proc
    if User.authenticate(@u.login, params[:password])
      @u.signon(params[:password])
      #loop { break if @u.ready_for_chat?; sleep 1; }
       if @u.admin_account == true
	 redirect_to admin_path
      else
        redirect_to(:controller => "messages", :action => "welcome_message", :id => @u.id)
      end
    else
      flash[:error] = "Password incorrect, please try again"
      redirect_to chat_login_profile_path(@p)
    end
  end
  
  def chat_invite
    unless @profile.user.online?
      begin
        TextMessage.create_chat_invite(@p, @profile)
        flash[:notice] = "<h3>Chat invitation sent</h3>#{@profile.f} is offline right now and has been sent a text message"
        redirect_to profile_chatter_path(@profile)
      rescue TextMessage::NoPhoneNumber => e
        flash[:error] = 'No valid mobile number to send invitation to'
        redirect_to @profile
      rescue Wallet::InsufficientFunds => funds
        flash[:error] = render_to_string :partial => "invitations/insufficient_funds", :locals => { :kontact => nil, :inv => nil }
        redirect_to @profile
      end
    else
      ChatInvitation.create!(:from => @p, :to => @profile)
      flash[:notice] = "<h3>Chat invitation sent</h3>#{@profile.f} is online right now and will receive a message"
      redirect_to profile_chatter_path(@profile)
    end
  end
  
  def chat_refresh
    expires_now
    respond_to do |format|
      format.mobile do
        @messages = @u.jabber_messages.unread.from_profile(@profile)
        @messages.each { |msg| msg.update_attribute(:read, true) }
        render :partial => 'chat_messages'
      end
    end
  end
  
  def conversation_refresh_js
    respond_to do |format|
      format.js do
        render :layout => false
      end
    end
  end
  
  def conversation_refresh
    @messages = @u.conversations.with(@profile.user).latest #.paginate(:page => params[:page], :per_page => 10)
    @messages.each { |msg| msg.update_attribute(:read, true) unless msg.read? }    
    respond_to do |format|
      format.mobile do
        render :partial => 'chat_messages'
      end
    end
  end
  
  def unread_messages
    expires_now
    respond_to do |format|
      format.mobile do
        get_friends
        render :partial => 'messenger', :layout => false
      end
    end
  end
  
  def chat_xmpp
    respond_to do |format|
      format.mobile do
        @messages = @u.jabber_messages.unread.from_profile(@profile)
        @messages.each { |msg| msg.update_attribute(:read, true) }
      end
    end
  end
  
  def chat
    respond_to do |format|
      format.mobile do
        @messages = @u.conversations.with(@profile.user).latest.paginate(:page => params[:page], :per_page => 10)
        @messages.each { |msg| msg.update_attribute(:read, true) }
      end
    end
  end
  
  def send_chat_message
    respond_to do |format|
      format.mobile do
        
      end
    end
  end
  
  def chat_send
    expires_now
    respond_to do |format|
      format.mobile do
        message =  URI.unescape(params[:message]) rescue nil
        unless message.blank?
          # @u.send_message(@profile.user, URI.unescape(params[:message])) unless params[:message].blank?
          JabberMessage.transaction do
            JabberMessage.create!(:owner => @u, :from => @u, :to => @profile.user, :message =>  message)
            JabberMessage.create!(:owner => @profile.user, :from => @u, :to => @profile.user, :message => message)
          end
        end
        #redirect_to profile_chatter_path(@profile)
        @messages = @u.conversations.with(@profile.user).latest #.paginate(:page => params[:page], :per_page => 10)
        @messages.each { |msg| msg.update_attribute(:read, true) unless msg.read? }    
        render :action => :chat
      end
    end
  end
  
  def subscribe
    @p.subscribe(@profile)
    flash[:notice] = "You'll receive SMS notifications for this user's updates. Please note that these updates require Smartbucks and will be deducted from your balance."
    
    respond_to do |format|
      format.mobile { redirect_to profile_path(@profile)}
      format.html { redirect_to profile_path(@profile)}
    end
  end
  
  def unsubscribe
    @p.unsubscribe(@profile)
    flash[:notice] = "You'll no longer receive SMS notifications for this user's updates."
    
    respond_to do |format|
      format.mobile { redirect_to profile_path(@profile)}
      format.html { redirect_to profile_path(@profile)}
    end
  end
  
  def subscriptions
    @friends = @p.friends
    @subscriptions = @p.follower_ships.subscribed_to.collect { |follow| follow.followed }
    respond_to do |format|
      format.mobile
    end    
  end
  
  def subscriptions_do
    params[:subscribe_to].each do |id|
      p = Profile.find(id)
      @p.subscribe(p)
    end
    respond_to do |format|
      format.mobile { redirect_to subscriptions_profile_path(@p) }
    end
  end

  def index
    respond_to do |format|
      format.html do 
        render :action => :search
      end
      format.xml do
        if @u and @u.is_admin?
          render :xml => Profile.find(:all) 
        else
          render :xml => @p.friends
        end
      end
    end
  end
  
  def friend
    other_profile = get_profile_from_login(params[:other_profile_id])    
    
    if params[:ignore] && params[:ignore] == 'yes'
      f = Friendship.first(:conditions => { :friendee_id => @p.id, :friender_id => other_profile.id })
      @p.feed_items.find(:first, :conditions => { :item_type => 'Friendship', :item_id => f.id } ).destroy
      f.destroy
      redirect_to(@p)
      return
    end
    
    @p.make_friends(other_profile)
     
    begin
      @text_message = @p.text_messages.create!(
        :recipient => other_profile,
        :to => other_profile.mobile,
        :billable => true,
        :billed_to => @p, 
        :service => Service.FriendInviteService,
        :href => profile_url(@p), 
        :message => render_to_string(:partial => 'sms/friend_invite'))
	if(!Service.FriendInviteService.nil?)
        Delayed::Job.enqueue(WapLinkJob.new(@text_message.id)) if @p.wallet.provided_for_service?(Service.FriendInviteService)
	end
    rescue Wallet::InsufficientFunds => funds
      # do nothing - right now we just won't send the sms
    end
          
    flash[:notice] = "Friend Request Sent"
    redirect_to(other_profile)
  end
  
  def follow
    other_profile = get_profile_from_login(params[:other_profile_id])
    @p.follow(other_profile) unless @p.following?(other_profile)
    redirect_to(other_profile)
  end
  
  def stop_following
    other_profile = get_profile_from_login(params[:other_profile_id])
    @p.stop_following(other_profile)# if @p.following?(other_profile)
    redirect_to(other_profile)
  end
  
  def provision
  end
  
  def provision_proc
      prov = Provisioner.new(current_user)
      prov.build_xml(params[:password])
      prov.send_provisioning(params[:mobile])
      flash[:notice] = "<h3>Settings are on their way!</h3>A provisioning message has been sent to your phone."
    # rescue => e
    #   flash[:error] = "Could not send a provisioning message. Please contact support."
    #   RAILS_DEFAULT_LOGGER.debug e.inspect
    # ensure
      respond_to do |format|
        format.html { redirect_to :action => :show }
        format.mobile { redirect_to sync_help_profile_mobile_path(@p) }
      end
  end
  
  def show
    respond_to do |format|
      format.html do
        @feed_items = (me?) ? @profile.feed_items.all(:order => 'created_at desc', :limit => 8) :
          @profile.feed_items.public.all(:order => 'created_at desc', :limit => 8)
        render :layout => 'new_application'
      end
      format.xml  { render :xml => @profile }
      format.rss do
        @feed_items = (me?) ? @profile.feed_items : @profile.feed_items.public
        render :layout => false
      end
      format.js do
        @feed_items = (me?) ? @profile.feed_items.paginate(:page => params[:page], :per_page => 8) :
          @profile.feed_items.public.all(:order => 'created_at desc', :limit => 8)
#        render :partial => 'bio', :layout => false
      end
      format.mobile do
        flash.now[:notice] = "<h3>#{@profile.f} is online!</h3>You can chat to this user right now by " + 
          "clicking the chat link below" if (@profile.user.online? and not me? and @profile.friend_of?(@p)) unless flash[:notice]
        # NOTE disabled as per request from janene
        # if me?
        #   unless @profile.is_complete?
        #     flash.now[:error] = "<h3>Your profile is incomplete!</h3>Complete your profile and earn five free Smartbucks!"
        #   end
        # end
        @location = @profile.location
        @status = @profile.profile_statuses.current.text rescue nil
        @active = me? ? :my_stream : :profile_stream
        # @feed_items = []
        # @feed_items = if me?
        #   @profile.feed_items.paginate(:all, :order => 'created_at desc', :page => params[:page], :per_page => 20)
        # else
        #   if @p.following?(@profile) or @p.friend_of?(@profile) or me?
        #     key = "#{@profile.id}-feed-items"
        #     items = Rails.cache.fetch(key, :expires_in => 5.minutes) do
        #       FeedItem.find_for_profile(@profile)
        #     end
        #     @feed_items = items.paginate(:page => params[:per_page], :per_page => 20)
        #   end
        # end
        @feed_items = @profile.feed_items.paginate(:all, :conditions => {:state=>'public'}, :order => 'created_at desc', :page => params[:page], :per_page => 20)
      @photos = @profile.photos.paginate(:all, :conditions=>"profile_id = '#{@profile.id}' ", :page => @page, :per_page => 1)
      end
    end
  end
  
  def cache_key(wtf)
    "blah--#{wtf}"
  end
  
  def edit
    @context = "existing"
    render
  end
  
  def update
    respond_to do |format|
      case params[:switch]
      when 'password'
        if @user.change_password(params[:verify_password], params[:new_password], params[:confirm_password])
          flash[:notice] = "Password has been changed."
          format.html do
            redirect_to edit_profile_url(@profile)
          end
        else
          format.html do 
            flash.now[:error] = @user.errors
            render :action=> :edit
          end
        end
      else
        phone_number = PhoneNumber.new(:value => params[:profile][:mobile].strip) if params[:profile][:mobile]
	if(params[:profile][:interest] && params[:profile][:gender] && params[:profile][:relation_status] && params[:profile][:display_name])
        if phone_number && phone_number.valid? && @profile.update_attributes(params[:profile])
          flash[:notice] = "Your profile has been updated"
          format.html do
           # redirect_to edit_profile_url(@profile)
	   redirect_to settings_path
          end
          format.mobile do
            # NOTE disabled as per request from janene
            # if @profile.is_complete? && !@profile.completion_bonus_awarded?
            #   @profile.give_completion_bonus!
            #   flash[:notice] = "<h3>You have completed your profile!</h3>Congratulations, you have been awarded 5 free Smartbucks!"
            # end
           
	   # redirect_to profile_path(@profile)
            redirect_to settings_path
	  end
          format.js do 
            render :update do |page|
              page["messages"].replace_html :partial => 'shared/flashes'
              page["messages"].focus()
              page["map_spinner"].hide()
            end
          end
        else
          phone_number.errors.each do |e|
            @profile.errors.add('', e[1])
          end unless phone_number.errors.empty?
          flash.now[:error] = @profile.errors.collect { |e| [e[0].capitalize ,e[1]].join(" ") }.join("<br>")
          @profile.mobile = phone_number.value
          format.html do 
            render :action => :edit
          end
          format.mobile do
            render :action => :edit
          end
          format.js do 
            render :update do |page|
              page["messages"].replace_html :partial => 'shared/flashes'
              page["messages"].focus()
              page["map_spinner"].hide()
            end
          end
	  
        end
	else
	   format.mobile do
	     flash.now[:error] = @user.errors
	     #flash[:notice] = "Please enter requested fields"
	     render :action => :edit
	   end

	   format.html do
	     flash.now[:error] = @user.errors
	    # flash[:notice] = "Please enter requested fields"
	     render :action => :edit
	    end
	  end
      end
    end
  end
  
  def destroy
    redirect_to home_path
    # respond_to do |wants|
    #   @user.destroy
    #   cookies[:auth_token] = {:expires => Time.now-1.day, :value => ""}
    #   session[:user] = nil
    #   wants.js do
    #     render :update do |page| 
    #       page.alert('Your user account, and all data, have been deleted.')
    #       page << 'location.href = "/";'
    #     end
    #   end
    # end
  end

  def basic_search
    respond_to do |format|
      format.mobile
    end
  end
  
 
 def basic_search_do
    respond_to do |format|
      format.mobile do
        @q = params[:q]
        if @q.blank?
          flash.now[:error] = "Please enter something to search for.."
          render :action => :basic_search
        else
         @results = Profile.find(:all, :joins=>"INNER JOIN users ON users.id = profiles.user_id", 
		 :conditions=>["profiles.given_name like :q or profiles.family_name like :q or users.login like :q", {:q => "%#{@q}%"}]).paginate(:page => params[:page], :per_page => 20)      
	  @kontacts = @p.kontacts.find(:all, :include => :kontact_information, :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)			
	end
      end
    end
  end
  
  def newprofile_search 
     @locations = Location.find(:all, :select => 'title').collect(&:title).flatten.uniq	     
     respond_to do |format|
      format.mobile
     end
  end


  def newprofile_search_do
    respond_to do |format|
      format.mobile do
       
	@months = params[:months]
	@location = params[:location]
	@gender = params[:gender]

	if(@months == "1" )
	 @date_today = Date.today - (7*1)
	elsif(@months == "2")
	 @date_today = Date.today - (7*2)
	elsif(@months == "3")
	 @date_today = Date.today - (15*2)
	else
	 @date_today = Date.today - (7*1)
	end 
	
	 
	if(@location == "Select" && @gender == "Select")  	    
        #  @results = Profile.find_by_sql([sql])
          @results = Profile.find(:all, :conditions => ['profiles.created_at > :today', {:today => "#{@date_today}"}]).paginate(:page => params[:page], :per_page => 20)
	  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
	
	
	 elsif(@location != "Select" && @gender == "Select")         
        # @results = Profile.find_by_sql([sql])
          @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.created_at > :today and locations.title like :loc', {:today => "#{@date_today}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)	  
	  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)


	 elsif(@location == "Select" && @gender != "Select")	   
          #@results = Profile.find_by_sql([sql])
          @results = Profile.find(:all, :conditions => ['profiles.created_at > :today and profiles.gender = :gen', {:today => "#{@date_today}", :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)
	  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)       
	 
	 

	 elsif(@location != "Select" && @gender != "Select")	    
          #@results = Profile.find_by_sql([sql])
          @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.created_at > :today and locations.title like :loc and profiles.gender = :gen', {:today => "#{@date_today}", :loc => params[:location], :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)
	  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20) 
	 
	 end 	 
      end
    end    
  end


  def online_search 
     @locations = Location.find(:all, :select => 'title').collect(&:title).flatten.uniq	     
     respond_to do |format|
      format.mobile
     end
  end

def online_results
    respond_to do |format|
    format.mobile do      	
       @pro = Profile.online_users
	@d = 1
	@frnd_srch = []
	@pro.each do |@pr| 
	if @pr.user.online? 
	
	  if(@d == 1)
	     @frnd_srch << @pr.id 	
	   else
	     @frnd_srch  << '"'
	     @frnd_srch  << @pr.id 
	   end
	 @frnd_srch  << '"'
	 @frnd_srch  << ","
	 @d += 1 
	 
	end
	end 
	@frnd_srch << '"'
	 if @d == 1
	 @frnd_srch << '"'
	 end
	   
            @results = Profile.find(:all, :conditions => {:id => @frnd_srch}).paginate(:page => params[:page], :per_page => 10)
            @online_users = Profile.find(:all, :conditions => {:id => @frnd_srch})
          #@results = Profile.find_by_sql([sql]).paginate(:page => params[:page], :per_page => 10)
          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', 
              { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
      end	
    end

 end


def online_search_do
     respond_to do |format|
      format.mobile do
      
        @agefrom = params[:agefrom]
	@ageto = params[:ageto]
	@location = params[:location]
	@gender = params[:gender]
	@friend_search = params[:friends]
	@today = Date.today.strftime("%Y")
	@d = 1 
	if(@friend_search == "Yes")
	@pro=@p.friends
	else
	 @pro = Profile.online_users 
	end
	@frnd_srch = []
	@frnd_srch << '"'
	@pro.each do |@pr| 
	if @pr.user.online? 
	if (@pr != @p)
	  if(@d == 1)
	     @frnd_srch << @pr.id 	
	   else
	     @frnd_srch  << '"'
	     @frnd_srch  << @pr.id 
	   end
	 @frnd_srch  << '"'
	 @frnd_srch  << ","
	 @d += 1 
	end 
	end
	end 
	@frnd_srch << '"'
	 if @d == 1
	 @frnd_srch << '"'
	 end
	  
	  
	if(@agefrom == "Select" && @location == "Select" && @gender == "Select")
	   
          @results = Profile.find(:all, :conditions => ['profiles.id in (:frnd_srch)', {:frnd_srch => @frnd_srch} ]).paginate(:page => params[:page], :per_page => 20)
          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)	  
          
	 
	elsif(@agefrom != "Select" && @ageto != "Select" && @location != "Select" && @gender != "Select" )
           
          @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and :ageto and locations.title like :loc and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :ageto => "#{@ageto}", :loc => params[:location], :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)

          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)  	
	
	 elsif(@age == "Select" && @location != "Select" && @gender != "Select")
           
          @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and locations.title like :loc and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :today => "#{@today}", :loc => params[:location], :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)

          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
	  
	  elsif(@agefrom == "Select" && @location != "Select" && @gender == "Select")
           @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and locations.title like :loc', {:frnd_srch => @frnd_srch, :today => "#{@today}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)

          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)

	   
	 
	 elsif(@agefrom == "Select" && @location == "Select" && @gender != "Select")
           
          @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)
          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)

	 
	 elsif(@agefrom != "Select" && @location == "Select" && @gender != "Select")
		   if(@ageto == "Select")             
		    
			@results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and "100" and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)
			
			 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
			 
		  else   
		    
			 @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and :ageto and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :ageto => "#{@ageto}", :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)

			 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q',  { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
		 end
		 
	 elsif(@agefrom != "Select" && @location != "Select" && @gender == "Select")
		   if(@ageto == "Select")
		     
			 @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and 100 and locations.title like :loc', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)
			 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
		  else
		   	   
			  @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and :ageto and locations.title like :loc', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :ageto => "#{@ageto}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)
			  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
			  end 	
	    
	
	elsif(@agefrom != "Select" && @location == "Select" && @gender == "Select")
		   if(@ageto == "Select")
		     
			 @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and "100"', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)
			 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
		  else
		   	   
			  @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and :ageto ', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :ageto => "#{@ageto}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)
			  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
			  end 	
	    

	   end

	 
	#end
      end
    end
  end


  
  def friend_search
     @locations = Location.find(:all, :select => 'title').collect(&:title).flatten.uniq	     
     respond_to do |format|
      format.mobile
     end
  end

  def friend_search_do
     respond_to do |format|
      format.mobile do
        
	@frnd_srch = []
	@friends_search = @p.friends 
	@c = 1
	@friends_search.each do |fs|
	if(@c == 1)
	 @frnd_srch  << fs.id
	else
	 @frnd_srch  << '"'
	 @frnd_srch  << fs.id
	end
	 @frnd_srch  << '"'
	 @frnd_srch  << ","
	 @c += 1 
	end
	 @frnd_srch << '"'
	  if @c == 1
	 @frnd_srch << '"'
	 end

        @q = params[:q]
        if @q.blank?
          flash.now[:error] = "Please enter something to search for.."
          render :action => :friend_search
        else
          sql = <<-EOV
            select profiles.* from profiles, users, settings
            where profiles.user_id = users.id
            and users.id = settings.user_id
            and settings.show_in_public_searches = true
	    and profiles.id in ("#{@frnd_srch}")
            and ((profiles.given_name like :q or profiles.family_name like :q) or (users.login like :q))
            order by users.login
	  EOV
          @results = Profile.find_by_sql([sql, { :q => "%#{@q}%" }])
          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', 
              { :q => "%#{@q}%" }])#.paginate(:page => params[:page], :per_page => 5)
        end
      end
    end
  end



  def all_search
  @locations = Location.find(:all, :select => 'title').collect(&:title).flatten.uniq
     respond_to do |format|
      format.mobile
     end
  end



def all_search_do
  	
    respond_to do |format|
      format.mobile do     
       	begin
	@q = params[:commit]
	@location = params[:location]
	@gender = params[:gender]
	@friend_search = params[:friends]
	@agefrom = params[:agefrom]
	@ageto = params[:ageto]    	
	@today = Date.today.strftime("%Y") 
	@online = params[:available]
	

	
	@q = params[:commit]
	
        if @q.blank?
          flash.now[:error] = "Please enter something to search for.."
          render :action => :all_search
        else
          if(@q == 'Search')
	  @d = 1 	   	   
	   if(@friend_search == "Yes")
		
		@pro=@p.friends
	   else
		@pro=Profile.find(:all)
	   end
	      @frnd_srch = []
	      @frnd_srch  << '"'   
	   @pro.each do |@pr| 
	      if (@pr != @p)
		 
		if(@online == "Online")
		  if @pr.user.online? 		  
		     if(@d == 1)
		        @frnd_srch << @pr.id 	
	             else
		        @frnd_srch  << '"'
		        @frnd_srch  << @pr.id 
		     end
		        @frnd_srch  << '"'
		        @frnd_srch  << ","
		        @d += 1 
		  end 
	        elsif(@online == "Offline")
		  
		   if !@pr.user.online?
		      if(@d == 1)
		         @frnd_srch << @pr.id 	
	              else
		         @frnd_srch  << '"'
		         @frnd_srch  << @pr.id 
		       end
		         @frnd_srch  << '"'
		         @frnd_srch  << ","
		         @d += 1 
		   end 
		 else
		     if(@d == 1)
		        @frnd_srch << @pr.id 	
	             else
		        @frnd_srch  << '"'
		        @frnd_srch  << @pr.id 
		      end
		        @frnd_srch  << '"'
		        @frnd_srch  << ","
		        @d += 1 
		  end
	        end
	      end
	    
		@frnd_srch << '"'
		   if @d == 1
		      @frnd_srch << '"'
		   end
		  	
				  
	    #if no filter is selected
	  if(@agefrom == "Select" && @location == "Select" && @gender == "Select")
				 
		 @results = Profile.find(:all, :conditions => ['profiles.id in (:frnd_srch)', {:frnd_srch => @frnd_srch}]).paginate(:page => params[:page], :per_page => 20) 
		 
		 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
		    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20) 
		

	  elsif(@agefrom != "Select" && @ageto != "Select" && @location != "Select" && @gender != "Select" )
	             
		    #@results = Profile.find_by_sql([sql])
		     @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and :ageto and locations.title like :loc and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :ageto => "#{@ageto}", :loc => params[:location], :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)

		    @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
		    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)       
		      
	  
	  
	  elsif(@age == "Select" && @location != "Select" && @gender != "Select")	    	    	  
		
		 #@results = Profile.find_by_sql([sql])
		 @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and locations.title like :loc and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :today => "#{@today}", :loc => params[:location], :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)

		 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
		    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
		    
	  elsif(@agefrom == "Select" && @location != "Select" && @gender == "Select")
          	
		 @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and locations.title like :loc', {:frnd_srch => @frnd_srch, :today => "#{@today}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)

		 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
		    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)

	 
	 elsif(@agefrom == "Select" && @location == "Select" && @gender != "Select")
           
		  @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)
		 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
		    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)

		   
	elsif(@agefrom != "Select" && @location == "Select" && @gender != "Select")
		   if(@ageto == "Select")             
		    
			    @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and "100" and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)
			 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
			 
		  else   
		    
			 @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and :ageto and profiles.gender = :gen', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :ageto => "#{@ageto}", :gen => params[:gender] }]).paginate(:page => params[:page], :per_page => 20)

			 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q',  { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
		 end
		 
	 elsif(@agefrom != "Select" && @location != "Select" && @gender == "Select")
		   if(@ageto == "Select")
		     
			 @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and 100 and locations.title like :loc', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)
			 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
		  else
		   	   
			  @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and :ageto and locations.title like :loc', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :ageto => "#{@ageto}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)
			  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
			  end 	
	    
	
	elsif(@agefrom != "Select" && @location == "Select" && @gender == "Select")
		   if(@ageto == "Select")
		     
			 @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and "100"', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)
			 @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
		  else
		   	   
			  @results =  Profile.find(:all, :include => :locations, :conditions => ['profiles.id in (:frnd_srch) and :today - profiles.birthyear between  :agefrom and :ageto ', {:frnd_srch => @frnd_srch, :today => "#{@today}", :agefrom => "#{@agefrom}", :ageto => "#{@ageto}", :loc => params[:location] }]).paginate(:page => params[:page], :per_page => 20)
			  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
			    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
			  end 	
	    

	   end

	  elsif(@q== "All")      

		  @results = Profile.paginate(:all, :page => params[:page], :per_page => 20)
		  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
		    :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
		   

	  else		  
		 # @results =  Profile.find(:all, :include => :user, :conditions => ['profiles.given_name like :q or profiles.family_name like :q  or users.login like :q', {:q => "#{@q}"} ] ).paginate(:page => params[:page], :per_page => 20)
	          
		  @results = Profile.find(:all, :joins=>"INNER JOIN users ON users.id = profiles.user_id", 
		 :conditions=>["profiles.given_name like :q or profiles.family_name like :q or users.login like :q", {:q => "%#{@q}%"}]).paginate(:page => params[:page], :per_page => 20)
 

		  @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
		  :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', { :q => "%#{@q}%" }]).paginate(:page => params[:page], :per_page => 20)
	      
	  end
	end
      	rescue
        end
      end
    end
  end


 def profile_search
     @locations = Location.find(:all, :select => 'title').collect(&:title).flatten.uniq
     respond_to do |format|
      format.mobile
     end
  end

  def profile_search_do
    respond_to do |format|
      format.mobile do
        @agefrom = params[:agefrom]
	@ageto = params[:ageto]    	
	@gender = params[:gender]
	@today = Date.today.strftime("%Y")
	if(@agefrom == "Select" && @gender == "Select")
           sql = <<-EOV
            select profiles.* from profiles, users, settings
            where profiles.user_id = users.id
            and users.id = settings.user_id
            and settings.show_in_public_searches = true
            
          EOV
          @results = Profile.find_by_sql([sql, { :q => "%#{@q}%" }])
          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', 
              { :q => "%#{@q}%" }])
	
	
	elsif(@agefrom != "Select" && @gender != "Select")
           if(@ageto == "Select")
	    sql = <<-EOV
            select profiles.* from profiles, users, settings, locations
            where profiles.user_id = users.id
            and users.id = settings.user_id
	    and profiles.id = locations.profile_id
            and settings.show_in_public_searches = true		    
	    and (profiles.gender like "#{@gender}")
	    and "#{@today}" - profiles.birthyear between "#{@agefrom}" and "100"
	   EOV

	   else
	   sql = <<-EOV
            select profiles.* from profiles, users, settings, locations
            where profiles.user_id = users.id
            and users.id = settings.user_id
	    and profiles.id = locations.profile_id
            and settings.show_in_public_searches = true		    
	    and (profiles.gender like "#{@gender}") 
	    and "#{@today}" - profiles.birthyear between "#{@agefrom}" and "#{@ageto}"
            
          EOV

	  end
          @results = Profile.find_by_sql([sql])
          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', 
              { :q => "%#{@q}%" }])  	
	
	 elsif(@agefrom == "Select" && @gender != "Select")
           sql = <<-EOV
            select profiles.* from profiles, users, settings, locations
            where profiles.id = locations.profile_id              
	    and (profiles.gender like "#{@gender}")
            
          EOV
          
	  @results = Profile.find_by_sql([sql])
          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', 
              { :q => "%#{@q}%" }])
	  
	  
	  elsif(@agefrom != "Select"  && @gender == "Select")
           sql = <<-EOV
            select profiles.* from profiles, locations
            where profiles.id = locations.profile_id
            and (locations.title like "#{@location}")
	                
          EOV

          @results = Profile.find_by_sql([sql])
          @kontacts = @p.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', 
              { :q => "%#{@q}%" }])

	 end
      end
    end
  end

  def search
    render
  end

  def wizard
    @context = "new"
    @phone_number = @p.mobile
    render
  end
  
  def set_phone_number_value
    pn = PhoneNumber.find(params[:id]) 
    value = pn.value
    pn.value = params[:value]
    
    if pn.save && ( value != params[:value] )
      changed_sms( pn ) 
    end
    # It should render a text 
    render :text => pn.value
  end

  def set_privacy
    respond_to do |format|
      format.js do
        @kontact_information.privacy_setting = { :type => params[:setting] , :value => params[:privacy] }
        render :update do |page|
          page.replace_html "demo_profile" , :partial => "demo_public_profile"
          page.hide("#{ params[:setting]}_privacy_spinner")
        end
      end
    end
  end
  
  def set_location
    respond_to do |format|
      format.js do
        if session[:map_location]
          @profile.update_attributes( build_location_attributes )
        else
          unless params[:edit_profile]
            @profile.attributes = params[:profile]
            @profile.save(false)
          end
        end
        
        render :update do |page| 
          unless params[:edit_profile]
            page.hide('profile_location_container')
            page.show('profile_main_container')
            page.hide('profile_spinner')
          else
            page.hide('map_spinner')
            page.replace_html "inline_location" , :partial => "inline_location"
          end
        end
      end
    end
  end
  
  def set_mobile
    respond_to do |format|
      format.js do
        #kontact_information.mobile = params[:mobile]
        @profile.mobile = params[:mobile]
        send_welcome_sms(@profile)

        render :update do |page| 
          page.replace_html "profile_mobile_container" , :partial => "mobile"
          page.hide('profile_spinner')
        end
      end
    end
  end
  
  def set_details
    # kontact_information = @profile.kontact_information
    # kontact_information.attributes = params[:kontact_information]
    @profile.update_attribute(:gender , params[:gender]) if params[:gender]
    @profile.update_attribute(:email , params[:email]) if params[:email]
    redirect_to profile_kontacts_path(@profile)
  end
  
  def add_number
    respond_to do |format|
      format.js do
        kontact = params[:kontact_id] ? Kontact.find(params[:kontact_id]) : nil
        @kontact_information = kontact ? kontact.kontact_information : @profile.kontact_information 
        @kontact_information.phone_numbers.create( { :field_type => params[:number_type],
            :value => params[:phone_number] ,
            :primary => false } )
        @kontact_information.touch
        @phone_numbers = @kontact_information.reload.phone_numbers.secondary
        render :update do |page|
          page.hide "newphone"
          page.replace_html "phone_numbers" , :partial => "phone_number" , :collection => @phone_numbers
        end
      end
    end
  end
 
  def add_email
    respond_to do |format|
      format.js do
        kontact = params[:kontact_id] ? Kontact.find(params[:kontact_id]) : nil
        @kontact_information = kontact ? kontact.kontact_information : @profile.kontact_information
        @kontact_information.emails.create( { :field_type => params[:email_type],
            :value => params[:email] ,
            :primary => false } )
        @kontact_information.touch
        @emails = @kontact_information.reload.emails.secondary
        render :update do |page|
          page.hide "newemail"
          page.replace_html "emails" , :partial => "email" , :collection => @emails
        end
      end
    end
  end
 
  def delete_email
    respond_to do |format|
      format.js do
        email = Email.find(params[:email_id])
        email.kontact_information.touch
        email.destroy
        render :update do |page|
          page.remove("email_#{ email.id }")
        end
      end
    end
  end  
    
  def delete_number
    respond_to do |format|
      format.js do
        pn = PhoneNumber.find(params[:number_id])
        pn.kontact_information.touch
        pn.destroy
        render :update do |page|
          page.remove("number_#{ pn.id }")
        end
      end
    end
  end

  def change_avatar
    respond_to do |format|
      format.mobile
    end
  end

  def upload_icon
    @profile.attributes = params[:profile]
    @profile.save(false)
    respond_to do |format|
      format.html { redirect_to edit_profile_path(@profile) }
      format.mobile { redirect_to @profile }
    end
  rescue => e
    flash.now[:error] = "There was a problem changing your profile picture. Please try again."
    render :action => :change_avatar
  end

  def delete_icon
    respond_to do |wants|
      @profile.update_attribute :icon, nil
      wants.js {render :update do |page| page.visual_effect 'Puff', 'profile_icon_picture' end  }
    end      
  end
  
  def reload_public
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html "demo_profile" , :partial => "demo_public_profile"
        end
      end
    end
  end
  
  def check_in
    lat, lng = params[:lat], params[:lng]
    @profile.update_attributes(:lat => lat, :lng => lng, :last_checkin => DateTime.now)
    respond_to do |format|
      format.mobile do
        flash.now[:notice] = "Location Updated"
        render :update do |page|
          page.replace_html :message_holder, :partial => 'shared/flashes'
        end
      end
    end
  end
  
  def remote_resend_mobile
    respond_to do |format|
      format.js do
        if session[:resend_confirm_code] &&  ( session[:resend_confirm_code] < 5.minutes.ago )
          session[:resend_confirm_code] = Time.now
          send_sms( @profile.mobile , resend_confirmation_sms(@profile) )
        else
          unless session[:resend_confirm_code]
            session[:resend_confirm_code] = Time.now
            send_sms( @profile.mobile , resend_confirmation_sms(@profile) ) 
          end
        end
        render :update do |page|
          page.hide 'profile_spinner'
        end
      end
    end
  end
  
  def followers
    @results = @profile.followers.paginate(:page => params[:page], :per_page => 20)
    begin
    @user_settings = User.find(@profile.user_id)
    @twitter_followers = @user_settings.settings.getfollowers.paginate(:page => params[:page], :per_page => 20)
    rescue
    end
    respond_to do |format|
      format.mobile
    end
  end
  
  def following
    @results = @profile.followed.paginate(:page => params[:page], :per_page => 20)
    begin
    @user_settings = User.find(@profile.user_id)
    @twitter_followers = @user_settings.settings.getfollowing.paginate(:page => params[:page], :per_page => 20)
    rescue
    end
    respond_to do |format|
      format.mobile
    end
  end
  
  protected
    
  def allow_to
    super :owner, :all => true
    super :user, :only => [:show, :search, :basic_search, :basic_search_proc, :friend, :subscriptions]
    super :friend, :only => [:business_card, :accept_share_business_card, :decline_share_business_card, :chat, :send_chat_message, :conversation_refresh_js, :conversation_refresh, :chat_refresh, :chat_send, :chat_invite, :request_business_card, :subscribe, :unsubscribe]
    super :follower, :only => [:subscribe, :unsubscribe, :followers, :following]
    super :all, :only => [:show, :search, :basic_search, :basic_search_proc, :friend, :subscriptions]
  end
     
  def setup
    @user = @profile.user if @profile
  end
  
  def search_results
    if params[:search]
      p = params[:search].dup
    else
      p = []
    end
    @results = Profile.search((p.delete(:q) || ''), p).paginate(:page => @page, :per_page => @per_page)
  end

    
end
