ActiveRecord::Base.class_eval do
  include Agilisto::Acts::Commentable
end