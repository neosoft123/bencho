class Settings < ActiveRecord::Base
  
  ride_the_fireeagle
  
  belongs_to :user  

  named_scope :with_facebook_credentials, :conditions => "facebook_infinite_session is not null and facebook_uid is not null"
  
  concerned_with :twitter
  
  def handle_mysql_error e, &block
    ActiveRecord::Base.connection.reconnect!
    yield if block_given?
  end
  
  def has_facebook_login?
    !self.facebook_infinite_session.blank? && !self.facebook_uid.blank?
  end
  
  def get_last_facebook_status
    return unless has_facebook_login?
    puts "Checking last facebook status for user: #{self.user.login}"
    config = YAML.load_file(File.join(RAILS_ROOT, "config", "facebooker.yml"))[RAILS_ENV]
    fb = Facebooker::Session.create(config['api_key'], config['secret_key'])
    response = fb.post('facebook.users.getInfo', :session_key => self.facebook_infinite_session, :uids => self.facebook_uid, :fields => "status")
    if response
      status = response[0]['status']
      if status
        unless self.last_facebook_status_id == status['status_id']
          status_message = status['message'].to_s
          return if status_message.blank?
          last_status = self.user.profile.profile_statuses.first.text rescue nil
          status_message.chop! if status_message =~ /\.$/ unless last_status.nil? || last_status[last_status.length-1, last_status.length] =~ /\./
         @getfbstrm = self.user.profile.profile_statuses.find(:first, :conditions => "facebook_status_id = #{status['status_id']}" ) 
         if @getfbst
           puts "Facebok feed already saved"
          else
          if last_status != status_message
            transaction do
              puts "Setting profile status: #{status_message}"
              #status_message = "#{status_message}" if status_message.length > 140
              self.user.profile.profile_statuses.create!(:text => status_message, :facebook_status_id => status['status_id'])
              puts "Setting last facebook status ID: #{status['status_id']}"
              self.update_attribute(:last_facebook_status_id, status['status_id'])
            end
          end
        end
        end
      end
    end
  rescue Facebooker::Session::SessionExpired
    puts "Facebook session key expired"
   # expire_facebook_session!
  rescue Facebooker::Session::UnknownError
    puts "Facebook API error - nothing we can do about this, ignoring"
  rescue ActiveRecord::StatementInvalid => e
    raise e # raise this to be handled externally
  rescue Timeout::Error
    nil
  rescue => e
    puts e.inspect
    HoptoadNotifier.notify(e)
  end

  def get_friends_statuses
    return unless has_facebook_login?
    puts "Checking facebook stream for user: #{self.user.login}"
    config = YAML.load_file(File.join(RAILS_ROOT, "config", "facebooker.yml"))[RAILS_ENV]
    fb = Facebooker::Session.create(config['api_key'], config['secret_key'])
    response = fb.post('facebook.stream.get', :session_key => self.facebook_infinite_session, :viewer_id => self.facebook_uid)
    if response && !response.empty?
      uids = []
      response.each do |post|
        #puts post
        uids << post["source_id"]
      end
      users = fb.post('facebook.users.getInfo', :session_key => self.facebook_infinite_session, :uids => uids.uniq.join(","), :fields => "name,pic_square")
      response.each do |post|
        #puts post["post_id"]
	 
	post_id = post["post_id"].split("_")[1].to_i
        unless FacebookStatus.exists?(:status_id => post_id) || post["message"].blank?
          s = FacebookStatus.new(:profile => self.user.profile)
          s.status_id = post_id
          s.text = post["message"]
          s.facebook_uid = post["source_id"]
          s.posted_at = DateTime.parse(Time.at(post["created_time"].to_i).to_s)
          users.each do |u|
            if u["uid"] == post["source_id"]
              s.name = u["name"]
              s.pic_square = u["pic_square"]
            end
          end
          s.save
        end
      end
    end
  rescue Facebooker::Session::SessionExpired
    puts "Facebook session key expired"
   # expire_facebook_session!
  rescue Facebooker::Session::UnknownError
    puts "Facebook API error - nothing we can do about this, ignoring"
  rescue ActiveRecord::StatementInvalid => e
    raise e # raise this to be handled externally
  rescue StandardError => e
    if e.message =~ /read_stream/
    #  expire_facebook_session!
    else
      puts e.inspect
      HoptoadNotifier.notify(e)
    end
 rescue Timeout::Error
    nil 
 rescue => e
    puts e.inspect
    HoptoadNotifier.notify(e)
  end
  
  def expire_facebook_session!
   # self.update_attributes :facebook_infinite_session => nil, :facebook_session_expired => true
  end
  
end
