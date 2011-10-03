module Mapped
  def geotag_me
    location = find_last_checkin
    return true unless location # No last check-in
    self.latitude = location.latitude
    self.longitude = location.longitude
  end
  
  private
  def find_last_checkin
    location = self.profile.locations.first
  end
end