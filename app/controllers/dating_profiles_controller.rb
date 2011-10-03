class DatingProfilesController < ApplicationController
  
  append_before_filter :find_dating_profile, :only => [:show, :edit, 
    :update, :matches, :destroy, :pay, :transaction_history]
    
  def pay
    @p.wallet.pay_dating_subscription!
    flash[:notice] = "Your payment is being processed and may take a few minuted to reflect"
    respond_to do |format|
      format.mobile { redirect_to(transaction_history_profile_dating_profile_url(@p)) }
    end
  end
  
  def transaction_history
    @service = Service.find_by_title("DatingSubscription")
    @entries = @p.subscription_billing_entries(:condition => { :service_id => @service.id })
    respond_to do |format|
      format.mobile
    end
  end
  
  def matches
    flash[:error] = render_to_string(:partial => "no_sub") unless @dating_profile.valid_subscription?
    @matches = (@dating_profile.valid_subscription?) ? 
      @dating_profile.matches(params[:page] || 1) : [].paginate(:page => params[:page], :per_page => 5)
    respond_to do |format|
      format.mobile
    end
  end
  
  def notice
    flash[:notice] = render_to_string(:partial => "subs_notice")
    respond_to do |format|
      format.mobile
    end
  end
    
  def new
    flash.clear
    @dating_profile = DatingProfile.new(:profile => @profile)
    respond_to do |format|
      format.mobile
    end
  end
  
  def create
    attribs = params[:dating_profile]
    @p.update_attribute(:gender, attribs[:gender]) if attribs.has_key?(:gender)
    @dating_profile = DatingProfile.new(attribs)
    @dating_profile.profile = @p
    @dating_profile.international_dialing_code = @p.international_dialing_code
    @dating_profile.gender = @p.gender
    @dating_profile.age = @p.years_old
    respond_to do |format|
      if @dating_profile.save
        format.mobile { render(:action => :show) }
      else
        format.mobile { render(:action => :new) }
      end
    end
  end
  
  def update
    attribs = params[:dating_profile]
    @p.update_attribute(:gender, attribs[:gender]) if attribs.has_key?(:gender)
    attribs[:international_dialing_code_id] = @p.international_dialing_code.id
    attribs[:gender] = @p.gender
    attribs[:age] = @p.years_old
    respond_to do |format|
      if @dating_profile.update_attributes(attribs)
        format.mobile { render(:action => :show) }
      else
        format.mobile { render(:action => :edit) }
      end
    end
  end
  
  def show
    flash[:error] = render_to_string(:partial => "no_sub") unless @dating_profile.valid_subscription?
    respond_to do |format|
      format.mobile
    end
  end
  
  def destroy
    flash[:notice] = "Your dating profile has been removed and you have been unsubscribed"
    @dating_profile.delete
    respond_to do |format|
      format.mobile { redirect_to(@p) }
    end
  end
    
  protected  
  
    def allow_to
      super :owner, :all => true
      super :all, :only => [:show]
    end
    
  private
  
    def find_dating_profile
      @dating_profile = @p.dating_profile
    end
  
end

