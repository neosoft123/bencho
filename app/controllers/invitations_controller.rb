class InvitationsController < ApplicationController
  
  include MobilisedController
  
  skip_filter :login_required, :only => [:accept_invitation]
  skip_filter :store_location, :only => [:accept_invitation, :create_for_kontact]
  skip_filter :setup_chat
  
  def new
    unless @p.wallet.provided_for_service?(Service.FriendInviteService) || flash[:error]
      flash.now[:error] = render_to_string :partial => "insufficient_funds", :locals => { :kontact => nil, :inv => nil }
    end
    respond_to do |format|
      format.mobile do
        @kontacts = @p.kontacts.paginate(:page => params[:page], :per_page => 10, :include => :kontact_information, 
          :order => 'kontact_informations.display_name')
      end
    end
  end
  
  def adhoc_invitation
    name = params[:name]
    mobile = params[:mobile]
    if mobile == @p.mobile
      flash[:error] = "<h3>That is your mobile number</h3>Please try with someone else's :)"
      redirect_to new_profile_invitation_url(@p)
    else
      k = Kontact.find_by_mobile_number(@p, mobile)
      if k.empty?
        RAILS_DEFAULT_LOGGER.debug "CREATING NEW KONTACT"
        Kontact.transaction do
          ki = KontactInformation.new(:owner => @p, :should_validate => false)
          ki.display_name = name
          ki.save(false)
          ki.mobile = mobile
          k = @p.kontacts.create(
            :status => Kontact::CONTACT,
            :parent => @p,
            :kontact_information => ki
          )
          RAILS_DEFAULT_LOGGER.debug k.inspect
        end
      end
    
      k = k.instance_of?(Array) ? k.first : k
      redirect_to create_kontact_invitation_path(@p, k)
    end
  end
    
  def accept_invitation
    invitation = Invitation.find_by_code(params[:code])
    
    if invitation
      if current_user
        @user = User.find_by_id(current_user)
        @user.profile.request_friendship(invitation.profile)
        begin
          invitation.profile.confirm_friendship(@user.profile)
        rescue DRb::DRbConnError => e
          flash[:error] = "Invitation accepted but there was an error friending #{invitation.profile.f}. Please try again later."
        end
        invitation.destroy
        flash[:notice] = "Friend request with #{invitation.profile.f} accepted"
        redirect_to profile_path(@user.profile)
      else
        @code = params[:code]
        @inviter = invitation.profile
        @kontact = invitation.kontact
        @mobile = @kontact.kontact_information.phone_numbers.mobile.primary.first
        @user = User.new
      end
    else
      flash[:error] = "<h3>Invitation not found</h3>Please ask the person who invited you to do so again"
      redirect_to login_path
    end
  end
  
  def create_for_kontact
    kontact = @profile.kontacts.find(params[:kontact_id])
    if kontact.ki.primary_phone_number.value == @p.mobile
      flash[:error] = "<h3>That is your mobile number</h3>Please try with someone else's :)"
      redirect_to [@p, kontact]
    else
      # check for existing member
      profile = Profile.first(:conditions => { :mobile => kontact.ki.primary_phone_number.value })
      if profile && profile.user.settings.show_in_public_searches?
        flash[:notice] = render_to_string :partial => 'invite_flash', :locals => { :kontact => kontact }
        redirect_to profile
      else
        redirect_to force_kontact_invitation_path(@p, kontact)
      end
    end
  end
  
  def force_invitation
    kontact = @profile.kontacts.find(params[:kontact_id])
    inv = @profile.invitations.new(:kontact => kontact)

    # TODO: Transaction
    respond_to do |format|
      if inv.save
        begin
          inv.send_invite
          flash[:notice] = 'Invitation successfully sent'
        rescue TextMessage::NoPhoneNumber => e
          flash[:error] = 'No valid mobile number to send invitation to'
          inv.destroy
        rescue Wallet::InsufficientFunds => funds
          flash[:error] = render_to_string :partial => "insufficient_funds", :locals => { :kontact => kontact, :inv => inv }
          inv.destroy
        end
      else
        flash[:error] = 'Invitation could not be sent'
      end
      format.mobile { redirect_to profile_kontact_path(@profile, kontact) }
    end
  end
  
  protected
  
  def allow_to
    super :non_user, :only => [:accept_invitation]
    super :user, :only => [:accept_invitation, :new]
    super :owner, :only => [:create_for_kontact, :force_invitation, :adhoc_invitation]
  end
  
end
