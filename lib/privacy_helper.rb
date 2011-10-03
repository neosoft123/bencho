module PrivacyHelper
  
  def options_for_privacy(ki , type)
    settings = PrivacySetting::SETTINGS
    s = ""
    settings.each do |setting|
      s << "<div><label>"
      s << setting.capitalize
      s << ": "
      s << radio_button_tag('privacy' , setting , selected_privacy_setting(ki , type , setting))
      s << "</label></div>"
    end
    s
  end
  
  def render_basic_information(profile)
    render :partial => "profiles/basic_information"
  end
  
  def render_additional_information(profile)
    #profile.cascade_privacy_setting?("additional" , setting) ?  ( render :partial => "profiles/additional_information" ) : ""
    render :partial => "profiles/additional_information"
  end
  
  def render_contact_information(ki)
    #ki.cascade_privacy_setting?("contact" , setting) ?  ( render :partial => "profiles/contact_information" , :locals => { :ki => ki} ) : ""
    render :partial => "profiles/contact_information" 
  end
  
  def render_all_information(ki)
    s = render_basic_information(ki)
    s << render_additional_information(ki)
    if me? || @p.has_business_card_for?(@profile)
      s << render_contact_information(ki)
    end
  end
  
  protected
  
  def selected_privacy_setting(ki , type)
    #ki.privacy_setting?(type , setting) ? true : false 
  end
  
end