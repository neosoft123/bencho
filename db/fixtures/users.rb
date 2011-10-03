User.seed(:login, :email) do |s|
  s.login = "admin" 
  s.password = "secret"  
end