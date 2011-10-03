class PublicFeedItem < ActiveRecord::Base
  
  belongs_to :item, :polymorphic => true
  before_save :geotag_me
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  
  def partial
    item.class.name.underscore
  end
  
  def geotag_me
    return true unless (item.respond_to?(:latitude) && item.latitude && item.respond_to?(:longitude) && item.longitude)
    self.latitude = item.latitude
    self.longitude = item.longitude
  end
  
  # def item
  #   clazz = class_eval(item_type)
  #   if clazz.respond_to?(:get_cache)
  #     begin
  #       clazz.get_cache("#{item_type.underscore.dasherize}-#{item_id}") do
  #         clazz.find(item_id)
  #       end
  #     rescue
  #       clazz.find(item_id)
  #     end
  #   else
  #     clazz.find(item_id)
  #   end
  # end
    
end
