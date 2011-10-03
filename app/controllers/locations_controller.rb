class LocationsController < ApplicationController

  skip_filter :store_location, :only => [:create]
  before_filter :get_profile
  before_filter :find_location, :only => [:show, :update, :destroy, :stream]
  
  def index
    @current = @profile.locations.first # weird sorting order 
    @location = @profile.locations.new
    @locations = @profile.locations.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html
      format.mobile
    end
  end
  
  def stream 
    # TODO: Determine how to make geokit play nicely with named scopes
    #@feed_items = @profile.feed_items.close_to(@location, 50).paginate(:all, :page => params[:page], :per_page => 10)
    @feed_items = @profile.feed_items.public.paginate(:all, :page => params[:page], :per_page => 10, :origin => @location, :within => 50)
  end
  
  def create
    @location = @profile.locations.new(params[:location])    
    @result = GeoKit::Geocoders::MultiGeocoder.geocode(@location.title)
  
    respond_to do |format|
      if @result.success
        if @result.all.length > 1
          format.html { render :partial => 'loc_options', :layout => false }
          format.mobile { render }
        else
          if @result.all.length == 1
            set_location(@result)
            format.html { redirect_to profile_locations_path(@profile) }
            format.mobile { redirect_to profile_location_path(@profile, @location) }
          else
            format.html { render :text => "<h2>Sorry, we couldn't find that location.. please try again</h2>", :layout => false }
            format.mobile do
              flash[:error] = "<h3>Where are you?</h3>Sorry, we could not find that location, please try again"
              redirect_to profile_locations_path(@profile)
            end
          end
        end
      else
        format.html { render :text => "<h2>Sorry, we couldn't find that location.. please try again</h2>", :layout => false }
        format.mobile do
          flash[:error] = "<h3>Where are you?</h3>Sorry, we could not find that location, please try again"
          redirect_to profile_locations_path(@profile)
        end
      end
    end
  rescue Errno::ECONNRESET => e
    flash[:error] = "A time-out expired resolving your location, please try again later"
    HoptoadNotifier.notify(e)
    redirect_to profile_locations_path(@profile)
  rescue Errno::ETIMEDOUT => e
    flash[:error] = "A time-out expired resolving your location, please try again later"
    HoptoadNotifier.notify(e)
    redirect_to profile_locations_path(@profile)
  rescue Timeout::Error => e
    flash[:error] = "A time-out expired resolving your location, please try again later"
    HoptoadNotifier.notify(e)
    redirect_to profile_locations_path(@profile)
  rescue EOFError => e
    flash[:error] = "A time-out expired resolving your location, please try again later"
    HoptoadNotifier.notify(e)
    redirect_to profile_locations_path(@profile)
  end
  
  def set
    @location = @profile.locations.new
    res = GeoKit::Geocoders::MultiGeocoder.geocode(params[:location])
    respond_to do |format|
      if res.success
        set_location(res)
        format.mobile { redirect_to profile_location_path(@profile, @location) }
        format.html { redirect_to profile_locations_path(@profile) }
      else
        flash[:error] = "<h3>Where are you?</h3>Sorry, we couldn't find that location"
        format.mobile { redirect_to profile_locations_path(@profile) }
        format.html { redirect_to profile_locations_path(@profile) }
      end
    end
  end
  
  # GET /devices/1
  # GET /devices/1.xml
  def show
    
    respond_to do |format|
      format.mobile # show.mobile.erb
      format.html # show.html.erb
      format.xml  { render :xml => @location }
    end
  end
  
  
  def destroy
    @location.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = 'Check-in was deleted.'
        redirect_to profile_locations_path(@p)
      end
      format.mobile do
        flash[:notice] = "<h3>Your check-in has been deleted</h3>"
        redirect_to profile_locations_path(@p)
      end
    end
  end
  
  def geocode
    @loc = GeoKit::Geocoders::MultiGeocoder.geocode(params[:location])
    @map = Variable.new("map")
    @draggable = Variable.new('draggable')
    
    respond_to do |format|
      if @loc.success 
        format.html # new.html.erb
        format.xml  { render :xml => @location }
        format.js
      else
        format.html {}
        format.xml {}
        format.js { render :update  do |page| page.replace_html :error, "Failed to geocode, please try again." end }
      end
    end
  end
  
  protected
  def allow_to
    super :admin, :all => true
    super :owner, :all => true
    super :friend, :only => [:show, :index, :stream]
    super :follower, :only => [:show, :index, :stream]
    super :user, :only => [:show, :index, :stream]
  end
  
  def find_location
    @location = @profile.locations.find(params[:id])
  end  
  
  private
  def set_location(res)
    @location.latitude = res.lat
    @location.longitude = res.lng
    @location.title = res.full_address
    @location.save!
    # update location in fire eagle
    # @profile.user.settings.update_location({:q => res.full_address}) if @profile.user.settings.authorized_with_fireeagle?
    flash[:notice] = "<h3>Checked in!</h3>You've set your location to #{@location.title}"
  end
  
end
