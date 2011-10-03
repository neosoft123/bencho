class DatingProfile < ActiveRecord::Base
  
  belongs_to :profile
  belongs_to :from_international_dialing_code, :class_name => "InternationalDialingCode"
  belongs_to :international_dialing_code
    
  validates_presence_of :seeking, :age_lowest, :age_highest,
    :for, :from_international_dialing_code, :international_dialing_code, :gender
    
  def matches page=1
    sql = <<-SQL
      select dating_profiles.* from dating_profiles
      where international_dialing_code_id = :idc
      and gender = :gender
      and age >= :agelow
      and age <= :agehigh
    SQL
    DatingProfile.paginate_by_sql(
      [
        sql, { 
          :idc => self.from_international_dialing_code_id,
          :gender => self.seeking,
          :agelow => self.age_lowest,
          :agehigh => self.age_highest
        }
      ], :page => page, :per_page => 5)
  end
  
  def valid_subscription?
    return false if self.last_billed.nil?
    (Time.now - self.last_billed) < 7.days.to_i
  end
  
  private
  
    def after_create
      self.profile.wallet.pay_dating_subscription!
    end
    
end
