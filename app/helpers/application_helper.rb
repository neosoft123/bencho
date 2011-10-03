module ApplicationHelper
  require 'digest/sha1'
  require 'net/http'
  require 'uri'
    
  def posted_by profile, at
    content_tag :div,
      "#{name_link(profile, true, true)} #{time_ago_in_words(at)} ago", 
      :class => "posted-by"
  end
  
  def help_image_link
    help_img = image_tag('/images/kontact/icons/help_16.png')
    hide_help_link = link_to(help_img + 'Hide help', hide_help_path, :id => 'hide_help')
    show_help_link = link_to(help_img + 'Help', show_help_path, :id => 'show_help')
    return show_help_link + hide_help_link
  end
  
  #def draw_crumbs *crumbs
  #  crumbs << Crumb.new("FlashSA.mobi", "http://flashsa.mobi") if current_subdomain == "flashsa"
  #  content_for(:crumbs, 
  #    content_tag(:ol, 
  #      crumbs.flatten.collect{|crumb|content_tag(:li,crumb)}.unshift(
  #        content_tag(:li, link_to("Logout (#{@p.formatted_name})", logout_path))).unshift(
  #        content_tag(:li, link_to('Public', public_stream_path))).unshift(
  #        content_tag(:li,link_to('Home', welcome_path))).unshift(
  #        content_tag(:li, link_to('Menu', main_menu_path))),
  #      :id => 'crumbs'))
  #end

  def draw_crumbs *crumbs
    crumbs << Crumb.new("FlashSA.mobi", "http://flashsa.mobi") if current_subdomain == "flashsa"
    content_for(:crumbs, 
      content_tag(:ol, 
        crumbs.flatten.collect{|crumb|content_tag(:li,crumb)}.unshift(
          content_tag(:li, link_to("Logout (#{@p.formatted_name})", logout_path))).unshift(
          content_tag(:li, link_to('Public', public_stream_path))).unshift(
          content_tag(:li,link_to('Home', welcome_path))).unshift(
          content_tag(:li, link_to('Menu', main_menu_path))),
        :id => 'crumbs'))
  end
  
  def draw_crumbs_only *crumbs
    crumbs << Crumb.new("FlashSA.mobi", "http://flashsa.mobi") if current_subdomain == "flashsa"
    content_for(:crumbs, 
      content_tag(:ol, 
        crumbs.flatten.collect{|crumb|content_tag(:li,crumb)}.compact.join('<li>»</li>'), 
        :id => 'crumbs'))
  end
  
  def specify_width_if_mobile
    dev_env = ['development', 'production_local'].include?(RAILS_ENV)
    if @device && @device.is_mobile? && dev_env
      unless @device[:resolution_width].nil?
        " style='width:#{@device[:resolution_width]}px'"
      else
       " style='width:100%'"
     end
    elsif session[:force_agent] == :mobile
      " style='width:100%;'"
    end
  end
  
  # NOTE commented out the underlining thingy, since we use numbers now
  def access_key_link_to text, url, access_key
    # pos = text.downcase =~ Regexp.new("(#{access_key})")
    # if pos == 0
    #   text = "<u>#{access_key.upcase}</u>" + text.slice(pos+1..text.length-1) if pos
    # elsif pos
    #   text = text.slice(0..pos-1) + "<u>#{access_key}</u>" + text.slice(pos+1..text.length-1) if pos
    # end
    # "<div class=\"posted-by\" style=\"font-size:10px;\">Press #{access_key} to select</div>" + link_to(text, url)
    [content_tag(:div, "Press #{access_key} to select", :class => "access-key"), link_to(text, url)].to_s
    #link_to(access_key, url, :accesskey => access_key) + " - " + link_to(text, url)
  end
  
  def less_form_for name, *args, &block
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder=>LessFormBuilder)
    args = (args << options)
    form_for name, *args, &block
  end
  
  def less_remote_form_for name, *args, &block
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder=>LessFormBuilder)
    args = (args << options)
    remote_form_for name, *args, &block
  end
  
  def display_standard_flashes(message = 'There were some problems with your submission:')
    if flash[:notice]
      flash_to_display, level = flash[:notice], 'notice'
    elsif flash[:warning]
      flash_to_display, level = flash[:warning], 'warning'
    elsif flash[:error]
      level = 'error'
      if flash[:error].instance_of?( ActiveRecord::Errors) || flash[:error].is_a?( Hash)
        flash_to_display = message
        flash_to_display << activerecord_error_list(flash[:error])
      else
        flash_to_display = flash[:error]
      end
    else
      return
    end
    content_tag 'ul', flash_to_display, :class => "#{level}", :id => 'messages'
  end

  def activerecord_error_list(errors)
    error_list = '<ul class="error_list">'
    error_list << errors.collect do |e, m|
      "<li>#{e.humanize unless e == "base"} #{m}</li>"
    end.to_s << '</ul>'
    error_list
  end
    
  def inline_tb_link link_text, inlineId, html = {}, tb = {}
    html_opts = {
      :title => '',
      :class => 'thickbox'
    }.merge!(html)
    tb_opts = {
      :height => 300,
      :width => 400,
      :inlineId => inlineId
    }.merge!(tb)
    
    path = '#TB_inline'.add_param(tb_opts)
    link_to(link_text, path, html_opts)
  end
  
  def tb_video_link youtube_unique_path
    return if youtube_unique_path.blank?
    youtube_unique_id = youtube_unique_path.split(/\/|\?v\=/).last.split(/\&/).first
    p youtube_unique_id
    client = YouTubeG::Client.new
    video = client.video_by YOUTUBE_BASE_URL+youtube_unique_id rescue return "(video not found)"
    id = Digest::SHA1.hexdigest("--#{Time.now}--#{video.title}--")
    inline_tb_link(video.title, h(id), {}, {:height => 355, :width => 430}) + %(<div id="#{h id}" style="display:none;">#{video.embed_html}</div>)
  end
  
  def me?
    @p == @profile
  end
  
  def get_name profile, use_pronoun=true, capitalise=false, possessive=false
    name = profile.f
    name = (profile == @p) ?  'you' : profile.f if use_pronoun
    name = (profile == @p) ?  'you' : ((name =~ /\w+?s$/) ? profile.f + "'" : profile.f + "'s") if possessive 
    name = name.titleize if capitalise
    name
  end
  
  def formatted_profile_name profile
    name = profile.f
    name = ((name =~ /\w+?s$/) ? profile.f + "'" : profile.f + "'s")
    name = name.titleize
    name
  end
  
  def name_link(profile, use_pronoun=true, capitalise=false, possessive=false, options={})
    link_to get_name(profile, use_pronoun, capitalise, possessive), profile, options
  end
  
  def is_are(profile)
    profile == @p ? 'are' : 'is'
  end
  
  def has_have(profile)
    profile == @p ? 'have' : 'has'
  end
  
  def is_admin? user = nil
    user && user.is_admin?
  end
  
  def if_admin
    yield if is_admin? @u
  end
  
  def current_controller
    return controller.controller_name
  end
  # Uses jQuery to toggle the visibily of a div
  def toggle_element(element)
    update_page do |page|
      page[element].toggle
    end
  end
  
  def show_element(element)
    update_page do |page|
      page[element].show
    end
  end
  
  def hide_element(element)
    update_page do |page|
      page[element].hide
    end
  end
  
  def working_indicator(options = {}, &block)
    options = {:id => :working}.merge(options)
    concat(
      content_tag(:div, { :id => options.delete(:id), :class => :working, :style => 'display:none;' }.merge(options)) do 
        capture(&block) + 
        unless options[:image] == false then 
          image_tag('loadingAnimation.gif')  
        end
    end, block.binding)
  end
  
  def button_to_remote(name, value, options = {})
      options[:method] ||= :post
      options[:with] ||= 'Form.serialize(this.form)'
      options[:html] ||= {}
      options[:html][:type] = 'button'
      options[:html][:onclick] = "#{remote_function(options)}; return false;"
      options[:html][:name] = name
      options[:html][:value] = 'submit'
      options[:html][:class] = 'submitBtn'
      content_tag(:button, options[:html], false) do
        content_tag(:span) do
          value
        end
      end
    end
    
    def submit_button(name, value, options = {})
        options[:html] ||= {}
        options[:html][:type] = 'button'
        options[:html][:name] = name
        options[:html][:value] = 'submit'
        options[:html][:class] = 'submitBtn'
        content_tag(:button, options[:html], false) do
          content_tag(:span) do
            value
          end
        end
      end

  def flash_notice(page)
      page.replace_html :topflash, display_standard_flashes
      page[:topflash].show
      page.delay(2) do
         page.visual_effect :fade, :topflash
      end
    flash.discard
  end
  
  # Mobile Javascript Helpers to make it easier to render partial page fragments
  # instead of reloading the page
  
  def update_element(element, &block)
    content = capture &block
    concat(
      update_page do |page|
        page.replace_html(element, content)
      end, block.binding)
  end
  
  def add_body_css(css_class)
    update_page do |page|
      page << "$('body').addClass('normal');"
    end
  end
  
  def remove_body_css(css_class)
    update_page do |page|
      page << "$('body').removeClass('normal');"
    end
  end
  
  def round_corners
    update_page do |page|
      page << "$('.corner').corner();"
    end
  end
  
  def online_status(profile)
    profile.user.online? ? 'Online' : 'Offline'
  end
  
  def location_defined?(profile)
    location = profile.locations.first
    return location if location
    nil
  end
  
  class DefinitionListFormBuilder < ActionView::Helpers::FormBuilder
    (field_helpers - %w(check_box radio_button hidden_field)).each do |selector|
      src = <<-END_SRC
        def #{selector}(field, options = {})
          @template.content_tag(:dd, 
            @template.content_tag(:label, options[:title] || field.to_s.humanize) + 
              @template.content_tag(:dt, super))
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end
  end
end