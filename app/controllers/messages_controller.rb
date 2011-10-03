class MessagesController < ApplicationController
  
  before_filter :can_send, :only => :create
  before_filter :load_parent, :except => [ :feedback, :feedback_send, :new_recipient, :new_message, :save_comment, :destroy_some_received, :save_message, :add_recipient, :new_multi_message, :create_multi_message, :bulk_message, :create_bulk_message, :welcome_message ]
  
  def feedback
    flash[:error] = "<h3>We appreciate your feedback</h3>If you are reporting a problem, please provide as much detail as you can"
  end
  
  def feedback_send
    FeedbackMailer.deliver_send_feedback(@u, params[:subject], params[:message])
    flash[:notice] = "<h3>Your feedback has been sent</h3>Your feedback is appreciated and has been sent to the 7.am team"
    redirect_to welcome_path
  rescue => e
    RAILS_DEFAULT_LOGGER.error e.inspect
    RAILS_DEFAULT_LOGGER.error e.backtrace
    flash[:error] = "<h3>Your feedback could not be sent</h3>We have been alerted of the problem, please try again later"
    render :action => :feedback
  end
    
  def index
   # @feed_items = @p.feed_items.paginate(:all, :conditions => "item_type= 'Comment'", :order => 'created_at desc', :page => params[:page], :per_page => 20)
    @comments = ProfileStatus.find(:all, :conditions=>'comments_count > "0"')
    @inbox_message = @p.received_messages.find(:all, :conditions => "saveto_inbox = '1'")
  end
  
  def new_message
   # @feed_items = @p.feed_items.paginate(:all, :conditions => "item_type= 'Comment'", :order => 'created_at desc', :page => params[:page], :per_page => 20)
    @comments = ProfileStatus.find(:all, :conditions=>'comments_count > "0"')
    # @comments_profile = @p.feeds.paginate(:all, :conditions=>'item_type="Comment"', :page => params[:page], :per_page => 20)
  end

  def sendto
    @message = Message.new(:receiver => get_profile_from_login(params[:id]))
    render :action => :new
  end
  
  def reply
    reply_to = Message.find(params[:id])
    @message = Message.new(:receiver => @parent.is_a?(Group)? @parent : reply_to.sender, :subject => "RE: #{reply_to.subject}")
    render :action => :new
  end
  
  def new_recipient
    @recipients = load_recipients_from_url
  end
  
  def add_recipient
    current_recipient_id = params[:message][:receiver_id]
    cumulative_recipient_ids = params[:cumulative_recipient_ids]
    
    if cumulative_recipient_ids.blank?
      cumulative_recipient_ids = [current_recipient_id]
    else
      cumulative_recipient_ids = cumulative_recipient_ids.split(',')
      cumulative_recipient_ids << current_recipient_id
      cumulative_recipient_ids.uniq!
    end
    
    base_url = "/messages/new_recipient/"
    add_more_recipients_url = "#{base_url}?cumulative_recipient_ids=#{cumulative_recipient_ids.join(',')}"
    redirect_to add_more_recipients_url
  end
  
  def new_multi_message
    @recipients = load_recipients_from_url
  end
  
  def create_multi_message
    @recipients = load_recipients_from_url
    form_params = {:body => params[:body], :subject => params[:subject]}
    
    @recipients.each do |recipient|
      message_params = form_params.merge({:receiver_id => recipient.id})
      @message = Message.new({:sender => @p, :receiver_type => 'Profile'}.merge(message_params))
      @message.icon = params[:message][:icon]
      unless @message.valid?
        flash.now[:error] = 'There was a error sending your message!'
        render :action => 'new_multi_message'
        return
      end
      @message.save!
    end
    
    flash[:notice] = 'Your message has been sent'
    redirect_to profile_messages_path(@p)
  end

  def welcome_message
     if ( @p.received_messages.length == 0)
    @recipient =  Profile.find(:first, :conditions => ["user_id = ?", params[:id]])
    form_params = {:body => "Welcome to 7.am .", :subject => "Welcome message", :icon => ""}
    message_params = form_params.merge({:receiver_id => 40081})
    @message = Message.new(:receiver_id => @recipient.id, :receiver_type => 'Profile', :sender_type => 'Profile', :sender_id => 40617, :body => "Welcome to 7.am .", :subject => "Please enter your Twitter and Facebook credentials.")
      respond_to do |format|
    if @message.save!
         format.mobile {  redirect_to session[:chat_return_to] || welcome_path}
     else 
       format.mobile  {  redirect_to session[:chat_return_to] || welcome_path}
    end
   end   

    else
      respond_to do |format|
      format.mobile {  redirect_to session[:chat_return_to] || welcome_path}
      end 
    end
  end


  def bulk_message
    render :layout => 'admins'
  end
  
 def create_bulk_message
render :layout => 'admins'
@recipients = Profile.all
    form_params = {:body => params[:body], :subject => params[:subject]}

    @recipients.each do |recipient|
      message_params = form_params.merge({:receiver_id => '38279'})
      @message = Message.new({:sender => @p, :receiver_type => 'Profile'}.merge(message_params))
      @message.icon = params[:message][:icon]
      unless @message.valid?
        flash.now[:error] = 'There was a error sending your message!'
        render :action => 'bulk_message'
        return
      end
      @message.save!
    end

    flash[:notice] = 'Your message has been sent'
    redirect_to admin_path
 
end

  def create
    @message = Message.new({:sender => @p, :receiver_type => @parent.class.name}.merge(params[:message]))
    
    RAILS_DEFAULT_LOGGER.debug @message.inspect
    
    unless @message.valid?
      flash[:error] = 'Message could not be sent'
      render :action => :new
      return
    end
    
    @message.save!
    flash[:notice] = "<h3>Message sent successfully</h3>You have sent a message to #{@message.receiver.f}"
    
    if @parent.is_a?(Group)
      redirect_to @parent
    else
      redirect_to :action => :index
    end
  end
  
  def new
    @message = if @parent.is_a?(Group)
      Message.new(:receiver => @parent)
    else
      Message.new
    end
    render
  end
  
  def sent
    @message = Message.new
    @to_list = @p.friends
  end
  
  def show
    @message = Message.find params[:id] rescue nil
    #@message ||= @p.received_messages.find params[:id] rescue nil
		if not @message.nil?
			@message.read = true
			@message.update_attribute('saveto_inbox', 1)
			@message.save
		else
		   
		end
    @to_list = [@message.sender]
     
  end

  def save_comment
    @comment_inbox = ProfileStatus.find(params[:id]).update_attribute('saveto_inbox', 1)
    flash[:notice] = "<h3>Comment saved to inbox</h3>"
    redirect_to :action => :new_message
  end

  def save_message
    @msg = Message.find(params[:id]).update_attribute('saveto_inbox', 1)
    flash[:notice] = "<h3>Message saved to inbox</h3>"
    redirect_to :action => :new_message
  end
  
  def destroy
    Message.find(params[:id]).destroy rescue nil
    flash[:notice] = "<h3>Message has been deleted</h3>"
    redirect_to :action => :index
  end
  
  def destroy_all_received
    @p.received_messages.each { |m| Message.destroy(m.id) }
    redirect_to profile_messages_url(@p)
  end

  def destroy_some_received
    @contact_ids = params[:message_id]    
       @contact_ids.each do |item_id, checked|
         if checked == "yes"
           @message_delete = Message.find(item_id, :conditions=>"receiver_id = '#@p'")
           @message_delete.destroy      
         end
       end
    flash[:notice] ="messages deleted"
    redirect_to :action => :new_message
  end

  protected
  
  def load_recipients_from_url
    if params[:cumulative_recipient_ids]
      ids = params[:cumulative_recipient_ids].split(',').uniq
      return Profile.all(:conditions => ["id in(?)", ids])
    end
    
    return []
  end
  
  def load_parent
    @parent = params[:profile_id] ? get_profile_from_login(params[:profile_id]) : Group.find(params[:group_id])
  end
  
  def allow_to
    super :user, :all => true
  end
  
  def can_send
    render :update do |page|
      page.alert "Sorry, you can't send messages. (Cuz you sux.)"
    end unless @p.can_send_messages
  end
  
end
