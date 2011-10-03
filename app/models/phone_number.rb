class PhoneNumber < PluralField
  MOBILE, FAX, PAGER = 'Mobile', 'Fax', 'Pager', 'Landline'
  DEFAULT_OPTIONS = PluralField::DEFAULT_OPTIONS.merge(:field_type => MOBILE)
  TYPE = PluralField::TYPE.concat([MOBILE, FAX, PAGER])
  
  attr_reader :international_dialing_code
  
  validates_presence_of :value
  # validates_format_of :value,
  #                     :with => /^[+\/\-() 0-9]+$/
  # validates_length_of :value, :minimum => 10, :message => "This doesn't look like a valid phone number"
  
  validate :valid_msisdn?
  
  attr_protected nil
  
  def before_validation_on_create
    value = value.gsub(/[^0-9]/, "") unless value.blank?
  end
  
  named_scope :mobile, :conditions => { :field_type => MOBILE }
  
  def valid_msisdn?
    self.value = value.gsub(/\D/, '')
    self.value = value[2..value.length] if value =~ /^00/
    if value =~ /^(\d{2})(\d{2})(\d{7,})$/
      code, local_code, number = $1, $2, $3
      self.value = code + local_code.gsub(/0/,'') + number
      unless InternationalDialingCode.exists?(:code => code)
        errors.clear
        if value =~ /^(\d{3})(\d{2})(\d{7,})$/
          errors.add_to_base("#{$1} is not a valid international dialing code") unless InternationalDialingCode.exists?(:code => $1)
        else
          errors.add_to_base("#{code} is not a valid international dialing code")
        end
      else
        @international_dialing_code = InternationalDialingCode.find_by_code(code)
      end
    else
      errors.clear
      errors.add_to_base("#{value} is not a valid mobile number, please include international dialing code");
    end
    self.value = "+#{value}"
  end
  
end
