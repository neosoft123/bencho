module AdvertsHelper
  
  def get_random_advert
    adverts = Advert.all(:conditions => ["run_from <= :today and run_to >= :today", {:today => Date.today} ])
    return unless adverts.length > 0
    ad = adverts[rand(adverts.length)]
    ad.views += 1
    ad.save!
    # return image_tag(url_for_file_column(ad, :image))
    if ad.send_to.blank?
      image_tag(url_for_file_column(ad, :image))
    else
      link_to image_tag(url_for_file_column(ad, :image)), advert_clickthru_path(ad)
    end
  end
  
end
