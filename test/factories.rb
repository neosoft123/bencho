require 'factory_girl'

Factory.define :user do |u|
  u.login 'kim'
  u.password 'Bouwer'
#  u.password_confirmation 'Bouwer'
  u.email 'joe.modise@telkom.co.za'
  u.is_admin false
  u.terms_of_service '1'
end

Factory.define :joe, :class => "User" do |u|
  u.login 'joe'
  u.password 'Password'
#  u.password_confirmation 'Password'
  u.email 'joe.modise@telkom.co.za'
  u.is_admin false
  u.terms_of_service '1'
end

Factory.define :jim, :class => "User" do |u|
  u.login 'jim2'
  u.password 'Password'
#  u.password_confirmation 'Password'
  u.email 'jim.modise@telkom.co.za'
  u.is_admin false
  u.terms_of_service '1'
  u.association :profile, :factory => :profile_mike
end

Factory.define :mike, :class => "User" do |u|
  u.login 'mike'
  u.password 'password'
#  u.password_confirmation 'password'
  u.email 'mike@super.com'
  u.is_admin false
  u.terms_of_service '1'
  u.state 'active'
  u.association :profile, :factory => :profile_mike
end

Factory.define :joe, :class => 'Profile' do |p|
  p.email 'joe@super.com'
  p.association :user, :factory => :user
end

Factory.define :jane, :class => 'Profile' do |p|
  p.email 'jane@super.com'
end


Factory.define :kontact_info_dave, :class => 'KontactInformation' do |ki|
  ki.display_name 'Dave Pretorius'
  ki.formatted_name 'Dave Pretorius'
  ki.family_name 'Pretorius'
  ki.given_name 'Dave'
  ki.gender 'male'
end

Factory.define :kontact_info_tebogo, :class => 'KontactInformation' do |ki|
  ki.display_name 'Tebogo Dlamimi'
  ki.formatted_name 'Tebogo Dlamimi'
  ki.family_name 'Dlamini'
  ki.given_name 'Tebogo'
  ki.gender 'male'
end

Factory.define :kontact_info_kim, :class => 'KontactInformation' do |ki|
  ki.display_name 'Kim Bouwer'
  ki.formatted_name 'Kim Bouwer'
  ki.family_name 'Bouwer'
  ki.given_name 'Kim'
  ki.gender 'female'
end

Factory.define :kontact_info_mike, :class => 'KontactInformation' do |ki|
  ki.display_name 'Mike Hansson'
  ki.formatted_name 'Mike Hansson'
  ki.family_name 'Hansson'
  ki.given_name 'Mike'
  ki.gender 'male'
end

Factory.define :profile_mike, :class => 'Profile' do |p|
  p.email 'mike@super.com'
end