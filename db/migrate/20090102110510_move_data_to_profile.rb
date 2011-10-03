class MoveDataToProfile < ActiveRecord::Migration
  def self.up
    
    Profile.transaction do
      
      Profile.all.each do |profile|
        if profile.respond_to?('kontact_information')
          %w(display_name family_name given_name middle_name gender birthday).each do |field|
            unless field == 'birthday'
              eval("profile.#{field} = profile.kontact_information.#{field}")
            else
              begin
                b = profile.kontact_information.birthday
                b = Chronic.parse(b)
                b = Date.parse(b) unless b
                profile.birthday = b
              rescue
                profile.birthday = nil
              end
            end
          
            profile.mobile_number = profile.kontact_information.primary_phone_number.value
          
          end
        
          profile.save!

        end
        
      end
      
    end
    
  end

  def self.down
  end
end
