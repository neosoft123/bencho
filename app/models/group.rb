class Group < ActiveRecord::Base
  
  DISPLAY_LIMIT = 5
  
  # for convenience with messages I'm aliasing this method - this is because
  # both groups and profiles can be the senders or receivers of messages
  def f; name; end
  
  belongs_to :owner, :class_name => 'Profile'
  has_and_belongs_to_many :members, :class_name => 'Profile'
  
  has_many :messages, :order => 'created_at desc', :foreign_key => 'receiver_id', :as => :receiver
  
  has_many :kontacts, :as => :parent  do
    def own
      first :conditions => ['status = "own"']
    end
  end
  has_many :kontact_informations, :through => :kontacts, :uniq => true, :include => [:phone_numbers, :emails]
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def is_member? p
    members.include? p
  end
  
  def is_owner? p
    p == owner
  end
  
  def invite_friends me, friends
    transaction { friends.each { |f| invite_friend me, f } }
  end
  
  def invite_friend me, friend
    GroupInvitation.create!(:inviter => me, :invitee => friend, :group => self)
  end
  
  def join(profile)
    self.members << profile unless self.is_member?(profile)
  end
  
  def leave(profile)
    self.members.delete(profile)
    self.destroy if self.members.count == 0 || profile == self.owner
  end
  
  def share_contacts(contacts, validate=true)
    transaction do
      contacts.each do |contact|
        self.kontacts.new(
          :kontact_information => contact,
          :status => Kontact::CONTACT
        ).save(validate)
      end
    end
  end
  
  def unshare_contacts(*contacts)
    transaction do
      contacts.each do |contact|
        contact.destroy
      end
    end
  end
  
  def sharable_contacts profile, page=1, per_page = 100
    # profile.kontact_informations.map{ |ki| ki unless self.kontact_informations.include? ki }.compact
    
    sql = <<-EOV 
        select ki.*
        from kontact_informations ki, kontacts
        where ki.id = kontacts.kontact_information_id
        and kontacts.parent_id = ?
        and kontacts.parent_type = "Profile"
        and ki.id not in 
        (
          select kontact_information_id
          from kontacts
          where parent_id = ?
          and parent_type = "Group"
        )
        order by ki.display_name
      EOV
      
    KontactInformation.paginate_by_sql([sql, profile.id, self.id], :page => page, :per_page => per_page)
    
  end
  
end
