module LocationsHelper
  def static_map_tag(location, opts = {})
    key = Ym4r::GmPlugin::ApiKey.get 
    
    width = opts.delete(:width) || @device[:usableDisplayWidth] || 175 rescue 175
    height = opts.delete(:height) || @device[:usableDisplayHeight] || 75 rescue 75
    marker_size = opts.delete(:marker) || :tiny
    zoom = opts.delete(:zoom) || 12
    
    lat, lng = if ['development', 'production_local', 'production'].include?(RAILS_ENV)
      [location.latitude, location.longitude]
    else
      [location.longitude, location.latitude]
    end
    coords = [lat, lng]
    
    map = StaticGmaps::Map.new(
      :center => coords,  
      :zoom => zoom,
      :size => [ width, height ],
      :key => key,
      :map_type => :mobile
    )
      
    map.markers = [StaticGmaps::Marker.new(
      :latitude => lat,
      :longitude => lng,
      :color => :green,
      :size => marker_size
    )]
    
    image_tag(map.url)
  end
  
  def static_map_with_markers_tag(locations, opts = {})
     key = Ym4r::GmPlugin::ApiKey.get 

     width = opts.delete(:width) || @device[:usableDisplayWidth] || 230
     height = opts.delete(:height) || @device[:usableDisplayHeight] || 320
     marker_size = opts.delete(:marker) || :mid # Smaller don't display alpha_characters

     markers = []
     locations.each_index do |i|
       location = locations[i]
       markers << StaticGmaps::Marker.new(
        :latitude => location.latitude,
        :longitude => location.longitude,
        :color => :green,
        :size => marker_size, 
        :alpha_character => StaticGmaps::Marker::VALID_ALPHA_CHARACTERS[i])
        break if i == 49 #TODO 50 item limit- going to have to make sure only 50 are displayed elsewhere as well
      end
      
    map = StaticGmaps::Map.new(
      :center => !(markers.length > 1) ? [markers[0].latitude, markers[0].longitude] : nil,
      :zoom => !(markers.length > 1) ? 10 : nil,
      :size => [ width, height ],
      :key => key,
      :markers => markers,
      :map_type => :mobile)

    image_tag(map.url)
  end
  
end
