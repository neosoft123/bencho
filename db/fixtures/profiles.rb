Profile.seed(:user_id , :first_name , :last_name , :location, :email) do |p|
  p.first_name = "Armand"
  p.last_name = "du Plessis"
  p.user_id = User.find_by_login("admin").id
end

