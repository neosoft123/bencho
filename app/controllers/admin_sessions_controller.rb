class AdminSessionsController < ApplicationController
  # GET /admin_sessions
  # GET /admin_sessions.xml
  def index
    @admin_sessions = AdminSession.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_sessions }
    end
  end

  # GET /admin_sessions/1
  # GET /admin_sessions/1.xml
  def show
    @admin_session = AdminSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_session }
    end
  end

  # GET /admin_sessions/new
  # GET /admin_sessions/new.xml
  def new
    @admin_session = AdminSession.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_session }
    end
  end

  # GET /admin_sessions/1/edit
  def edit
    @admin_session = AdminSession.find(params[:id])
  end

  # POST /admin_sessions
  # POST /admin_sessions.xml
  def create
    @admin_session = AdminSession.new(params[:admin_session])

    respond_to do |format|
      if @admin_session.save
        flash[:notice] = 'AdminSession was successfully created.'
        format.html { redirect_to(@admin_session) }
        format.xml  { render :xml => @admin_session, :status => :created, :location => @admin_session }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_sessions/1
  # PUT /admin_sessions/1.xml
  def update
    @admin_session = AdminSession.find(params[:id])

    respond_to do |format|
      if @admin_session.update_attributes(params[:admin_session])
        flash[:notice] = 'AdminSession was successfully updated.'
        format.html { redirect_to(@admin_session) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_sessions/1
  # DELETE /admin_sessions/1.xml
  def destroy
    @admin_session = AdminSession.find(params[:id])
    @admin_session.destroy

    respond_to do |format|
      format.html { redirect_to(admin_sessions_url) }
      format.xml  { head :ok }
    end
  end
end
