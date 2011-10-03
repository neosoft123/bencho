module Commentable

  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end

  module ClassMethods

    def acts_as_commentable

      has_many :comments, :as => :commentable, :order => 'created_at asc', :dependent => :destroy
      include InstanceMethods

    end

  end

  module InstanceMethods

    def comment(profile, comment)
      self.comments << self.comments.new(:profile => profile, :comment => comment)
    end

  end

end

#ActiveRecord::Base.send :include, Agilisto::Acts::Commentable