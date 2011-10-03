class GroupsController < ApplicationController
  
  before_filter :find_group
  append_before_filter :member_of_group, :except => [:invitation, :invite_accept, :invite_decline]
  skip_filter :store_location, :only => [:create, :share_contacts_do, :member_of_group, :send_invites,
    :invite_accept, :invite_decline, :unshare_contact]
    
  def index
    #@owned_groups = @profile.owned_groups
    @groups = @u.profile.groups
  end
  
  def browse_public
    sql = <<-EOV
      select groups.* from groups
      where groups.is_public = true
      and groups.id not in
      (select group_id from groups_profiles where profile_id = ?)
    EOV
    @groups = Group.find_by_sql([sql, @p.id])
  end
  
  def new
    @group = Group.new(:is_public => true)
    @friends = @p.friends
  end
  
  def create
    @group = Group.new(params[:group].merge({:owner_id => @p.id}))
    if @group.save
      @group.members << @p
      if params[:friends] && params[:friends].length > 0
        friends = Profile.find(params[:friends])
        @group.invite_friends(@p, friends)
        friends.each { |f| send_invite_message(f) }
      end
      redirect_to group_path(@group)
    else
      flash[:error] = "There was a problem creating your group"
      @friends = @p.friends
      render :action => :new
    end
  end
  
  def show
    @messages = @group.messages.paginate(:page => params[:page], :per_page => 10)
    @member_count = @group.members.count
    @members = @group.members.all(:limit=>Group::DISPLAY_LIMIT)
  end
  
  def members
    respond_to do |format|
      format.mobile { @members = @group.members.paginate(:page => params[:page], :per_page => 10) }
      format.xml { render :xml => @group.members, :status => 200, :location => members_group_path(@group) }
    end      
  end
  
  def invite
  end
  
  def send_invites
    friends = Profile.find(params[:friends])
    @group.invite_friends(@p, friends)
    friends.each { |f| send_invite_message(f) }
    flash[:notice] = "Invitations have been sent"
    redirect_to group_path(@group)
  end
  
  def send_invite_message(friend)
    invite = GroupInvitation.first(:conditions => {:inviter_id => @p.id, :invitee_id => friend.id, :group_id => @group.id})
    Message.create!(:sender => @p, :receiver => friend, 
      :subject => "Group invitation: #{@group.name}",
      :body => "You have been invited to join the group <strong>#{@group.name}</strong> by <strong>#{@p.f}</strong>.<br/><br/>" + 
        "Please <a href=\"#{group_invite_path(@group, invite)}\">click here</a> to accept or decline the invitation."
    )
  end
  
  def invitation
    @invite = GroupInvitation.find(params[:id], :include => [:group, :inviter])
  end
  
  def invite_accept
    invite = GroupInvitation.find(params[:id], :include => [:group, :invitee])
    invite.accept
    flash[:notice] = "You have joined the group \"#{invite.group.name}\""
    redirect_to invite.group
  end
  
  def invite_decline
    invite = GroupInvitation.find(params[:id], :include => [:group, :invitee])
    invite.decline
    flash[:notice] = "You have declined the invitation to join the group \"#{invite.group.name}\""
    redirect_to groups_path
  end
  
  def shared_contacts
    @members = @group.members.all(:limit=>Group::DISPLAY_LIMIT)
    @contacts = @group.kontacts.paginate(:page => params[:page], :per_page => 10)
  end
  
  def share_contacts
    page = params[:page] ? params[:page].to_i : 1
    @contacts = @group.sharable_contacts(@p, page)
  end
  
  def share_contacts_do
    @group.share_contacts(KontactInformation.find(params[:contacts]))
    redirect_to shared_contacts_group_path(@group)
  end
  
  def unshare_contact
    k = Kontact.find(params[:kontact_id])
    @group.unshare_contacts(k)
    flash[:notice] = "Contact no longer shared with the group"
    redirect_to @group
  end
  
  def join
    @group.join @p
    flash[:notice] = "<h3>Welcome to #{@group.name}</h3>You have successfully joined this group"
    redirect_to @group
  end
  
  def leave
    @group.leave(@p)
    flash[:notice] = "You are no longer a member of the group \"#{@group.name}\""
    redirect_to groups_path
  end
  
  private
  
  def find_group
    @group = Group.find params[:id] if params[:id] rescue nil
  end
  
  def member_of_group
    if @group
      unless @group.is_member?(@p) || @group.is_public?
        flash[:error] = "You are not a member of that group"
        redirect_back_or_default groups_path
      end
    end
  end
  
  def allow_to
    super :user, :all => true
  end
  
end
