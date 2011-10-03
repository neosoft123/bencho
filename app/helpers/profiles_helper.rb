require 'avatar/view/action_view_support'

module ProfilesHelper
  include Avatar::View::ActionViewSupport
  include PrivacyHelper
  include LocationisedHelper
  
  def content_for_chat_message msg, posted_by=nil, content=nil, &block
    if @device && @device.low?
      content_for_chat_message_low msg, posted_by, content, &block
    else
      content_for_chat_message_mid msg, posted_by, content, &block
    end
  end
  
  def content_for_chat_message_low msg, posted_by, content=nil, &block
    msg_content = []
    msg_content.unshift(posted_by(posted_by, msg.created_at)) unless posted_by.nil?
    msg_content << content unless block_given?
    msg_content << capture(&block) if block_given?
    concat content_tag_for(:li, msg) { msg_content.to_s }
  end

  def content_for_chat_message_mid msg, posted_by, content=nil, &block
    msg_content = []
    msg_content.unshift(posted_by(posted_by, msg.created_at)) unless posted_by.nil?
    msg_content.unshift(content_tag(:div, link_to(avatar_icon_tag(posted_by), posted_by), :class => 'feed-avatar')) unless posted_by.nil?
    msg_content << capture(&block) if block_given?
    msg_content << content unless block_given?
    concat content_tag_for(:li, msg) { msg_content.to_s }
  end  

  def is_my_profile?(profile)
    my_profile == profile
  end
  
  def subscribed_to?(profile)
    @p.subscribed?(profile)
  end

  def age_and_sex(profile)
    out = unless profile.years_old == 0
      ["#{pluralize(profile.years_old, 'year')} old"]
    else
      []
    end
   #out << profile.gender.titleize unless profile.gender.blank?
    out.to_sentence
  end
    
  def avatar_icon_tag profile, size = :small, image_opts = {}
   image_tag(avatar_path(profile, size), image_opts.merge(:alt => ""))
  end
  
  def avatar_path profile = nil, size = :small
    path = nil
    unless profile.nil? || profile.icon.blank?
      path = url_for_file_column(profile, :icon, size.to_s) rescue nil
    end
    path = "avatar_default_#{size.to_s}.png" if path.blank?
    path
  end
    
  def location_link profile = @p
    return profile.location if profile.location == Locationised::NOWHERE
    link_to h(profile.location), search_profiles_path.add_param('search[location]' => profile.location)
  end
  
  def hide_or_display(context)
    return context ? "style='display:block;'" : "style='display:none;'"
  end
  
  def profile_icon(profile , size = "medium", img_options={})
    if profile.icon
      return image_tag(url_for_file_column(profile, 'icon' , size.to_s) , img_options)
    else
      return "<div class='noavatar'>You do not have an image set yet</div>"
    end
  end
  
  def messenger_alerted?
    session[:alerted]
  end
  
  def messenger_alerted(value)
    session[:alerted] = true
  end
  
  def stream_link_to_twitter
    link_to(twitter_path) do
      capture(image_tag("twitter.png", :class => caption_class(@active, :twitter)))
    end
  end
end
