require 'rubygems'
require 'sinatra'
require 'activerecord'
require 'yaml'

dbconfig = YAML.load_file(File.join(File.dirname(__FILE__), "../..", "config", "database.yml"))

class JabberMessage < ActiveRecord::Base
  
  belongs_to :owner, :class_name => 'User'
  belongs_to :from, :class_name => 'User'
  belongs_to :to, :class_name => 'User'
  named_scope :unread, :conditions => { :read => false }
  named_scope :with,
  proc { |with|
    {
      :conditions => ["((from_id = :with_id or from_id = :with_id)) or ((to_id = :with_id or to_id = :with_id))", {
        :with_id => with.id }]
    }
  }      
  named_scope :latest, :order => 'created_at desc', :limit => 10

end

class User < ActiveRecord::Base
  
  has_one :profile
  has_many :jabber_messages, :foreign_key => 'to_id', :order => 'created_at desc'
  has_many :conversations, :foreign_key => 'owner_id', :class_name => 'JabberMessage'
  
end

class Profile < ActiveRecord::Base
  
  belongs_to :user
  
  def f
    unless display_name.blank?
      display_name
    else
      name = [given_name, family_name].join(' ')
      unless name.blank?
        name
      else
        self.user.login
      end
    end
  end
  
end

ActiveRecord::Base.establish_connection(dbconfig['development'])

def get_user(login)
  User.find_by_login(login) if login
end

get '/:login' do
  u = User.find_by_login(params[:login]) if params[:login]
  "Hello #{u.profile.f}" if u
end

get '/messages/:login' do
  @messages = get_user(params[:login]).jabber_messages
  haml :messages
end

get '/messages/:login/unread' do
  @messages = get_user(params[:login]).jabber_messages.unread
  haml :messages
end

get '/messages/:login/from/:from.xml' do
  @messages = get_user(params[:login]).conversations.with(get_user(params[:from])).latest
  haml :messages
end


























