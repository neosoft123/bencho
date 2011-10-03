class UsersController < ApplicationController
  
  skip_filter :load_online_friends
  before_filter :get_all_online
  
  include MobilisedController
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge , :confirm , :confirm_mobile]
  before_filter :login_required, :only => [ :destroy, :change_password, :change_password_do ]
  skip_filter :store_location, :except => [:change_password]

  layout 'plain'
  
  def change_password
    
  end
  
  def change_password_do
    if @u.change_password(params[:old_password], params[:new_password], params[:new_password])
      flash[:notice] = "<h3>Password changed!</h3>Your password has been changed. You will receive your new "+
        "sync settings shortly"
      prov = Provisioner.new(@u)
      prov.build_xml
  #    prov.send_provisioning
      redirect_to settings_path
    else
      message = "<h3>Password not changed!</h3>"
      @u.errors.each {|k,v|message+="#{v}<br/>"}
      flash[:error] = message
      redirect_to change_password_user_path(@u)
    end
  end

  # render new.rhtml
  def new
#    flash.now[:error] = render_to_string :partial => 'shared/alpha_message'
    
    check_phone_number
    
    @user = User.new
    respond_to do |format|
      format.mobile
      format.html
    end
  end

 def showuser
  render :layout => 'admins'
  @user_all = User.all
 end
 
 def admin_login
  check_phone_number

    @user = User.new
    respond_to do |format|
      format.mobile
      format.html
    end

  
 end

 # TODO Move code to Models where appropriate.
 # This code feel incredibly sloppy to me. Breaks the slim controller fat model approach.
  def create
    logout_keeping_session!
    
    User.transaction do
      
      @user = User.new(params[:user])
      #@user.password_confirmation = @user.password
      # @user.register! if @user && @user.valid?
      phone_number = PhoneNumber.new(:value => params[:phone_number].strip) if params[:phone_number]
      if phone_number && phone_number.valid? && @user.save
        @user.register!
        @user.activate
        if params[:user][:admin_account]
         @user.admin_account=1
       end

        self.current_user = @user
        @user.profile.mobile = phone_number.value
        @user.profile.save!
        
        # if this is an invitation we want to friend the inviter
        if params[:code]
          invitation = Invitation.find_by_code(params[:code])
          @user.profile.request_friendship(invitation.profile)
          invitation.profile.confirm_friendship(@user.profile)
          invitation.destroy     
        end
        
        # build the provisioning xml while we have the password
        prov = Provisioner.new(@user)
        prov.build_xml
        # prov.send_provisioning
              
        new_cookie_flag = (params[:remember_me] == "1")
        handle_remember_cookie! new_cookie_flag
                
        # Send the activation link to the users profile
        # send_sms(phone_number.value , welcome_sms(@user.profile))

        self.current_user = @user
        
        begin
          @user.signon(params[:user][:password])
        rescue DRb::DRbConnError => e
          flash[:error] = "Everything not cricket with the chat server. Please check back soon."
        end

        set_profile

        # is_mobile_device? ? ( redirect_to login_path ) : ( redirect_to wizard_profile_path(:id => @user.profile) )
       	@user.update_attribute('login_count', 1)
	flash[:notice] = "Thank you for registering on 7.am."
        if @user.admin_account == true
         redirect_to admin_path
       else
         redirect_to welcome_path
       end
      else
        @user.valid?
        phone_number.errors.each do |e|
          @user.errors.add('Mobile Number', e[1])
        end unless phone_number.errors.empty? unless phone_number.nil?
        @user.errors.add("Mobile Number") unless phone_number.valid?
        flash[:error]  = @user.errors.collect { |e| [e[0].capitalize ,e[1]].join(" ") }.join("<br>")
        @user.mobile_number = phone_number.value unless phone_number.nil?
        # @idc = phone_number.international_dialing_code
        #render :action => 'new'
        is_mobile_device? ? ( render :action => :new ) : ( render :template => 'home/index' )
        #render :template => 'home/index', :layout => 'home'
      end
      
    end


    # help = User.find_by_login("help")
    # #help = User.create_help_user unless help
    # if help
    #   help.profile.force_friendship(@user.profile) unless @user.profile.friend_of?(help.profile)
    # end
      
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
  
  # update phone number
  def confirm_mobile
    respond_to do |format|
      format.js do
        if @user.mobile_activation_code == params[:mobile_activation_code].downcase
          @user.confirm_mobile
            render :update do |page|
              page.hide('profile_mobile_container')
              page.hide('activate_mobile')
              page.show('profile_main_container')
              page.hide('profile_spinner')
            end
        else
          # TODO warning message
          render :update do |page|
            page.hide('profile_spinner')
          end
        end
     
      end
    end
  end
  
  # register
  def confirm
    if @user.mobile_activation_code == params[:code]
      @user.confirm_mobile
      self.current_user = @user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      flash[:notice] = "Thanks, your mobile number has been confirmed."
      redirect_to provisioning_profile_mobile_url(@user.profile)
    else
      flash[:error] = "Activation code not valid."
      redirect_to signup_path     
    end
  end
  
  def remind_me_to_sync_later
    current_user.remind_to_sync_date = DateTime.now + 2.weeks
    current_user.save!
    flash[:notice] = '<h3>Settings updated</h3>'
    redirect_back_or_default(welcome_path) 
  end
  
  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

  protected
  def find_user
    @user = User.find(params[:id])
  end
  
  def build_kontact_information
     ki =  @user.profile.kontact_information
     ki.primary_phone_number = params[:phone_number]
     ki.display_name = params[:user][:login]
     ki
  end
  
  def check_phone_number
    @phone_number = params[:phone_number]
    if @phone_number
      @phone_number = Msisdn.new(@phone_number).to_national
    end
    check_msisdn_pass_through
  end
  
  def check_msisdn_pass_through
    @phone_number = request.headers["HTTP_X_UP_CALLING_LINE_ID"]
    if @phone_number
      @phone_number = Msisdn.new(@phone_number).to_national
    end
  end

  
  def allow_to
    super :owner, :all => true
    super :all, :all => true
  end
end
