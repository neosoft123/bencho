class WalletsController < ApplicationController

  before_filter :get_profile, :find_wallet, :check_country_of_origin

  def show
    @recent_activity = @wallet.account_entries.recent.paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.html # show.html.erb
      format.mobile
      format.xml  { render :xml => @wallet }
    end
  end
  
  def new
    @wallet = @profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wallet }
    end
  end

  def edit
  end
  
  def create
    # putting this here because I cannot work out how people are managing to call
    # this action, but its causing errors..
    redirect_to profile_wallet_path(@p)
  end

  def update

    respond_to do |format|
      if @wallet.update_attributes(params[:wallet])
        flash[:notice] = 'Wallet was successfully updated.'
        format.html { redirect_to(@wallet) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wallet.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @wallet.destroy

    respond_to do |format|
      format.html { redirect_to(wallets_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def check_country_of_origin
    if @profile.international_dialing_code && 
      @profile.international_dialing_code.code != "27"
      flash[:error] = "We apologise, but Smartbucks are currently only available to people with South African mobile numbers"
      redirect_to :back
    end
  end
  
  def find_wallet
    unless @profile.wallet
      @profile.wallet = Wallet.new(:balance => 0)
      @profile.wallet.save!
    end
    @wallet = @profile.wallet
  end
  
  def allow_to
    super :admin, :all => true
    super :owner, :all => true
  end
  
end
