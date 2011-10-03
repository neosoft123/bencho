class Message < ActiveRecord::Base
  
  belongs_to :sender, :polymorphic => true
  belongs_to :receiver, :polymorphic => true
  validates_presence_of :body, :subject, :sender, :receiver
  # attr_immutable :id, :sender_id, :receiver_id
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  after_create :feedme
  
  class << self
    
    def send_message(from, to, subject, body)
      m = Message.new(:sender => from, :receiver => to, :subject => subject, :body => body)
      return m.save
    end
    
  end
  
  def unread?
    !read
  end
  
  def feedme
    f = FeedItem.create!(:item => self)
    if receiver.is_a?(Profile)
      add_feed_item(receiver, f)
    elsif receiver.is_a?(Group)
      receiver.members.each { |m| add_feed_item(m, f) }
    end
  end
  
  def add_feed_item(profile, feed_item)
    feed_item.private!
    profile.feed_items << feed_item
  end
  
  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "120x120", :name => "medium"},
      :small => {:crop => "1:1", :size => "32x32", :name => "small"},
      :tiny => { :crop => "1:1", :size => "17x17" , :name => "tiny" },
      :iphone => {:crop => "1:1", :size => "62x62", :name => "iphone" }
    }
  }
  
  validates_file_format_of :icon, :in => ["gif", "jpg"]
  validates_filesize_of :icon, :in => 1.kilobytes..5000.kilobytes
  



end
