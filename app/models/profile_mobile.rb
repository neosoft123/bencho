class Profile
  
  def international_dialing_code
    InternationalDialingCode.find_for_mobile_number(self.mobile)
  end
  
end