module Locationised

  Locationised::NOWHERE = 'Nowhere'

  def location=(location)
    super(location)
    # REVIEW: Why would we only geocode the address after it was saved? This should be inline
    # functionality
    geocode_address if self.location_changed?
  end

  # def location
  #   return Locationised::NOWHERE if attributes['location'].blank?
  #   attributes['location']
  # end
  
  def location?
    return self.location != Locationised::NOWHERE && self.lng && self.lat
  end
  
  def set_lat_lng
    unless location.blank?
      if lat.nil? or lng.nil?
        geocode_address
      end
    end
  end
  
  protected
  def geocode_address
    return if location.blank? or location.blank? or location == Locationised::NOWHERE
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(location)
    errors.add(:location, "Could not Geocode Location") unless geo.success
    if geo.success
      self.send("#{lat_column_name}=", geo.lat)
      self.send("#{lng_column_name}=", geo.lng)
    end
    #self.lat, self.lng = geo.lat, geo.lng if geo.success
  end

end