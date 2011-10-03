class EmailsController < ApplicationController

  before_filter :get_profile, :find_kontact, :find_kontact_information
  before_filter :find_email, :only => [:show, :edit, :update, :destroy]

  # GET /emails
  # GET /emails.xml
  def index
    @emails = @kontact_information.emails.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.mobile
      format.xml  { render :xml => @emails }
    end
  end

  # GET /emails/1
  # GET /emails/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.mobile
      format.xml  { render :xml => @email }
    end
  end

  # GET /emails/new
  # GET /emails/new.xml
  def new
    @email = @kontact_information.emails.new

    respond_to do |format|
      format.html # new.html.erb
      format.mobile
      format.xml  { render :xml => @email }
    end
  end

  # GET /emails/1/edit
  def edit
  end

  # POST /emails
  # POST /emails.xml
  def create
    @email = @kontact_information.emails.build(params[:email])

    respond_to do |format|
      if @email.save
        flash[:notice] = 'Email was successfully created.'
        format.html { redirect_to(@email) }
        format.mobile { redirect_to profile_kontact_kontact_information_plural_fields_path(@profile, @kontact)}
        format.xml  { render :xml => @email, :status => :created, :location => @email }
      else
        flash[:error] = @email.errors
        format.html { render :action => "new" }
        format.mobile {render :action => "new" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /emails/1
  # PUT /emails/1.xml
  def update

    respond_to do |format|
      if @email.update_attributes(params[:email])
        flash[:notice] = 'Email was successfully updated.'
        format.html { redirect_to(@email) }
        format.mobile { redirect_to profile_kontact_kontact_information_plural_fields_path(@profile, @kontact)}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.mobile { render :action => "edit" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /emails/1
  # DELETE /emails/1.xml
  def destroy
    @email.destroy

    respond_to do |format|
      format.html { redirect_to(emails_url) }
      format.mobile { redirect_to profile_kontact_kontact_information_plural_fields_path(@profile, @kontact)}
      format.xml  { head :ok }
    end
  end
  
  protected
  def find_kontact
    @kontact = @profile.kontacts.find(params[:kontact_id])
  end
  
  def find_kontact_information
    @kontact_information = @kontact.kontact_information
  end
  
  def find_email
    @email = @kontact_information.emails.find(params[:id])
  end 
  
  def allow_to
    super :owner, :all => true
  end
end
