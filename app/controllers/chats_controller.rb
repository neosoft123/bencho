class ChatsController < ApplicationController
  
  layout 'application'
  # prepend_before_filter :get_profile
  skip_before_filter :setup_chat
  
  def create
    @chat = @profile.chats.build(params[:chat])
    unless User.authenticate(@u.login, @chat.jabber_password)
      flash[:error] = "Whoops, that's not it"
      redirect_to profile_chats_url(@profile) and return
    end
    if params[:chat]
      if @chat.save
        redirect_to [@profile, @chat]
      end
    end
  end
  
  def index
    @chat = @profile.chats.new
    @chats = @profile.chats.paginate(:page => params[:page], :per_page => 5, :order => 'created_at desc')
  end
  
  def show
    @chat = @profile.chats.find(params[:id])
    @chat_id = @chat.chat_id = @chat.start_chat(@chat.jabber_password)
    @chat.save!
  end
  
  def check_for_messages
    #
    # this method is only useful if you're not using the custom
    # mongrel action
    #
    to = @profile.chats.find(params[:id]) || @profile.chats.current
    render :text => to.get_messages_from(to.chat_id, params[:from]).to_json
  end
  
  def send_message
    from = @profile.chats.find(params[:id])
    begin 
      from.send_message_to(from.chat_id,
                              params[:to],
                              params[:message])
      render :text => ""
    rescue Exception => e #CanHasChat::Remote::MustSupplyPassword
      flash[:error] = "You must supply a password before you begin chatting. #{e.message}"
      raise
    end
  end
  
  def unread_messages
    @messages = @u.jabber_messages.unread
    respond_to do |format|
      format.mobile
      format.html
    end
  end
  
  def chatjs
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def converse
    @chat = @profile.chats.find(params[:id])
    @chat.to = params[:to]
    respond_to do |format|
      format.mobile
    end
  end

end