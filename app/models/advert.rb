class Advert < ActiveRecord::Base
  
  validates_presence_of :title, :run_from, :run_to, :image#, :send_to
  
  file_column :image
  
end
