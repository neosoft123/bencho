class AccountEntriesController < ApplicationController

  before_filter :get_profile, :find_wallet
  before_filter :find_services, :only => [:new]
  before_filter :find_account_entry, :only => [:show, :destroy, :update]

  ## GET /account_entries
  # GET /account_entries.xml
  def index
    @account_entries = AccountEntry.find(:all)

    respond_to do |format|
      format.html ## index.html.erb
      format.xml  { render :xml => @account_entries }
      format.mobile { redirect_to profile_wallet_path(@p) }
    end
  end

  ## GET /account_entries/1
  # GET /account_entries/1.xml
  def show
    respond_to do |format|
      format.html ## show.html.erb
      format.mobile ## show.mobile.erb
      format.xml  { render :xml => @account_entry }
    end
  end

  ## GET /account_entries/new
  # GET /account_entries/new.xml
  def new
    @account_entry = AccountEntry.new

    respond_to do |format|
      format.html ## new.html.erb
      format.mobile ## new.mobile.erb
      format.xml  { render :xml => @account_entry }
    end
  end

  ## GET /account_entries/1/edit
  def edit
    @account_entry = AccountEntry.find(params[:id])
  end

  ## POST /account_entries
  # POST /account_entries.xml
  def create
    Wallet.transaction do 
      @service = Service.find(params[:account_entry][:service_id]) ##@wallet.account_entries.build(params[:account_entry])
      @account_entry = @wallet.buy_smartbucks(@service)
      respond_to do |format|
        if @account_entry.pending?
          flash[:notice] = 'Transaction queued for processing'
          format.html { redirect_to(profile_wallet_path(@profile)) }
          format.mobile { redirect_to(profile_wallet_path(@profile)) }
          format.xml  { render :xml => @account_entry, :status => :created, :location => @account_entry }
        else
          format.html { render :action => "new" }
          format.mobile { render :action => "new" }
          format.xml  { render :xml => @account_entry.reason, :status => :unprocessable_entity }
        end
      end
    end
  end

  ## PUT /account_entries/1
  # PUT /account_entries/1.xml
  def update
    @account_entry = AccountEntry.find(params[:id])

    respond_to do |format|
      if @account_entry.update_attributes(params[:account_entry])
        flash[:notice] = 'AccountEntry was successfully updated.'
        format.html { redirect_to(@account_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  ## DELETE /account_entries/1
  # DELETE /account_entries/1.xml
  def destroy
    @account_entry = AccountEntry.find(params[:id])
    @account_entry.destroy

    respond_to do |format|
      format.html { redirect_to(account_entries_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  def find_wallet
    @wallet = @profile.wallet
  end
  
  def find_services
    @services = Service.active
  end
  
  def find_account_entry
    @account_entry = @wallet.account_entries.find(params[:id])
  end
  
  def allow_to
    super :admin, :all => true
    super :owner, :all => true
  end
end

