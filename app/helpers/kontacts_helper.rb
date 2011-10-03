module KontactsHelper
  def kontact_icon kontact_information, size = :small, img_opts = {}
    return "" if kontact_information.nil?
    img_opts = {:title => kontact_information.formatted_name, :alt => kontact_information.formatted_name, :class => size}.merge(img_opts)
    link_to(avatar_tag(kontact_information, {:size => size, :file_column_version => size }, img_opts), 
      kontact_information_path(kontact_information))
  end

  def kontact_avatar(kontact, size, img_opts = {})
    if kontact.parent_type == "Profile"
      img_opts = {:title => kontact.parent.full_name, :alt => kontact.parent.full_name, :class => size}.merge(img_opts)
      link_to(avatar_tag(kontact.parent, {:size => size, :file_column_version => size }, img_opts), profile_path(profile))
    else
      avatar(kontact, size)
    end
  end
  
  def kontact_icon(kontact, size = "medium", img_options={})
    if kontact.kontact_information.icon
      return image_tag(url_for_file_column(kontact.kontact_information, 'icon' , size.to_s) , img_options)
    else
      return "<div class='noavatar'>You do not have an image set yet</div>"
    end
  end
  
  def add_email_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :emails, :partial => :email, :object => @kontact.kontact_information.emails.build
    end
  end
  
  def add_phone_number_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :phone_numbers, :partial => :phone_number, :object => @kontact.kontact_information.phone_numbers.build
    end
  end
  
  # TODO: Method missing these
  def edit_owner_kontact_path(owner, kontact)
    eval("edit_#{owner.class_name}_kontact_path(owner, kontact)")
  end
  
  def owner_kontact_path(owner, kontact)
    eval("#{owner.class.name.underscore}_kontact_path(owner, kontact)")
  end
  
  def kontact_icon_url(ki, options = {})
    if ki.icon
      return image_path(url_for_image_column(ki, 'icon', options))
    else
      return "<div class='noavatar'>You do not have an image set yet</div>"
    end
  end
  
  def avatar(kontact , size='medium')
    if kontact.avatar?
      return (image_tag url_for_file_column('kontact_information' , 'icon' , size), :size => "32x32" , :class => 'photo') if size == 'small'
      return "<div class='avatar'>#{ image_tag url_for_file_column('kontact_information' , 'icon' , size) }</div>"
    else
      if kontact.kontact_information.owner_type == "Profile"
        profile = kontact.kontact_information.owner
        if kontact.status == Kontact::OWN or profile.friend_of?(@p)
          return avatar_tag(profile, {:size => size.to_sym, :file_column_version => size.to_sym}, {})
        end
        #return image_tag url_for_file_column(kontact.parent , 'icon' , size), :size => "32x32" , :class => 'photo' if size == 'small'
        #return "<div class='avatar'>#{ image_tag url_for_file_column('profile' , 'icon' , size) }</div>"
      end
      return "<img src='/images/kontact/temp/captaincondor.png' alt='photo of captain condor' class='photo' width='32' height='32'/>" if size == 'small'
      return "<div class='noavatar'>You do not have an image set yet</div>"
    end
  end
  
end
