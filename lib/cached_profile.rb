module CachedProfile
  
  # def profile
  #   puts "Using cached profile"
  #   Profile.get_caches("profile-#{self.profile_id}") do
  #     Profile.find(self.profile_id)
  #   end
  # end
  
  def profile
    Profile.get_cache("profile-#{self.profile_id}") do
      p = Profile.find(self.profile_id)
      p.user = User.get_cache("user-#{p.user_id}") do
        User.find(p.user_id)
      end
      p
    end
  end
  
end