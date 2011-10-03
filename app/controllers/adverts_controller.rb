class AdvertsController < ApplicationController
  
  append_before_filter :force_iphone
  before_filter :find_advert, :only => [:show, :edit, :update, :clickthru]
  
  def clickthru
    @advert.clicks += 1
    @advert.save!
    redirect_to @advert.send_to
  end
  
  def index
    respond_to do |format|
      format.mobile { @adverts = Advert.all }
    end
  end
  
  def show
    respond_to do |format|
      format.mobile { render }
    end
  end
  
  def new
    respond_to do |format|
      format.mobile { @advert = Advert.new }
    end
  end
  
  def edit
    respond_to do |format|
      format.mobile { render }
    end
  end
  
  def update
    respond_to do |format|
      format.mobile do
        if @advert.update_attributes(params[:advert])
          flash[:notice] = "Advert updated"
          render :action => :show
        else
          render :action => :edit
        end
      end
    end
  end
  
  def create
    respond_to do |format|
      format.mobile do
        @advert = Advert.new(params[:advert])
        if @advert.save
          flash[:notice] = "Advert created"
          redirect_to @advert
        else
          render :action => :new
        end
      end
    end
  end
  
  def destroy
    Advert.destroy params[:id]
    flash[:notice] = "Advert deleted"
    redirect_to :action => :index
  end
  
  private 
  
  def find_advert
    @advert = Advert.find params[:id]
  end
  
  def force_iphone
    unless @wurfl_device
      @device = @wurfl_device = WurflDevice.find_by_xml_id("apple_iphone_ver2_2_1")
    end
  end
  
  def allow_to
    super :admin, :all => true
    super :all, :only => [:clickthru]
  end
  
end
