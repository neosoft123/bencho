class TextMessagesController < ApplicationController

  before_filter :get_profile
  layout 'application'
  # layout 'new_application'
  
  # GET /text_messages
  # GET /text_messages.xml
  def index
    @text_messages = @profile.text_messages.paginate(:all, :page => params[:page], :order => 'created_at desc', :per_page => 15)

    respond_to do |format|
      format.mobile
      format.html # index.html.erb
      format.xml  { render :xml => @text_messages }
    end
  end

  # GET /text_messages/1
  # GET /text_messages/1.xml
  def show
    @text_message = @profile.text_messages.find(params[:id])

    respond_to do |format|
      format.mobile
      format.html # show.html.erb
      format.xml  { render :xml => @text_message }
    end
  end

  # GET /text_messages/new
  # GET /text_messages/new.xml
  def new
    @text_message = @profile.text_messages.build

    respond_to do |format|
      format.mobile
      format.html # new.html.erb
      format.xml  { render :xml => @text_message }
    end
  end

  # GET /text_messages/1/edit
  def edit
    @text_message = @profile.text_messages.find(params[:id])
  end

  # POST /text_messages
  # POST /text_messages.xml
  def create
    @text_message = @profile.text_messages.build(params[:text_message])

    respond_to do |format|
      if @text_message.save
        flash[:notice] = 'TextMessage was successfully created.'
        format.mobile {redirect_to([@profile, @text_message]) }
        format.html { redirect_to([@profile, @text_message]) }
        format.xml  { render :xml => @text_message, :status => :created, :location => @text_message }
      else
        format.mobile { render :action => "new"}
        format.html { render :action => "new" }
        format.xml  { render :xml => @text_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /text_messages/1
  # PUT /text_messages/1.xml
  def update
    @text_message = @profile.text_messages.find(params[:id])

    respond_to do |format|
      if @text_message.update_attributes(params[:text_message])
        flash[:notice] = 'TextMessage was successfully updated.'
        format.mobile { redirect_to([@profile, @text_message]) }
        format.html { redirect_to([@profile, @text_message]) }
        format.xml  { head :ok }
      else
        format.mobile { render :action => "edit" }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @text_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /text_messages/1
  # DELETE /text_messages/1.xml
  def destroy
    @text_message = @profile.text_messages.find(params[:id])
    @text_message.destroy

    respond_to do |format|
      format.html { redirect_to(profile_text_messages_url(@profile)) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def allow_to
    super :owner, :all => true
  end
  
end
