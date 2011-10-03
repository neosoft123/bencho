module LocationisedController

  private
  
  def build_location_attributes
    { :lng => session[:map_location][:lng], 
      :lat => session[:map_location][:lat], 
      :location => build_location_name( session[:map_location][:lng] , session[:map_location][:lat] ) }
  end
  
  def build_location_name(lng , lat)
    require 'geonames'
    location = Geonames::WebService.find_nearby_place_name(lat,lng).first
    return '' if location.blank?
    location_name = location.name
    location_name << ','
    location_name << location.country_name
  end
  
  def get_coords(profile)
    if profile.has_location?
      [profile.location.latitude, profile.location.longitude]
    else
      if profile == my_profile
        location = GeoKit::Geocoders::IpGeocoder.geocode(request.remote_ip)
        [location.lat, location.lng]
      else
        nil
      end
    end
  end
  
  def create_friends_map
    return if request.format == :mobile
    if @profile
      coords = get_coords(@profile)
      unless coords.nil?
        @map = GMap.new("friends_map")
        @map.control_init(:small => true)
        @map.center_zoom_init(coords, 9)  
        marker = GMarker.new(coords,   
          :title => @profile.formatted_name, :info_window => "<div class=\"left avatar\">#{@profile.formatted_name}</div>")
        @map.overlay_global_init(marker, "marker")
        @profile.friends.each do |friend|
          friend_coords = get_coords(friend)
          @map.add_overlay(GMarker.new(friend_coords, :title => friend.full_name))
        end
      end
    end
  end
  
  def set_location_map
    coords = get_coords(@profile)
    unless coords.nil?
      #@profile.location = location.full_address.blank? ? "Johannesburg, South Africa" : location.full_address unless @profile.location?
      @map = GMap.new("set_location_map")
      @map.control_init(:small_map => true, :map_type => true)
      @map.set_map_type_init(GMapType::G_HYBRID_MAP)
      @draggable = GMarker.new(coords, :draggable => true, :name => "draggable" , :title => "Your location")
      @map.center_zoom_init(coords, 12)
      @map.overlay_global_init(@draggable, "draggable")
      @map.event_init @draggable, :dragend, 
        "function() { 
            var lat = draggable.getLatLng().lat();
            var lng = draggable.getLatLng().lng();
            $('#profile_lat').val(lat);
            $('#profile_lng').val(lng);
          }"
    end
  end
end