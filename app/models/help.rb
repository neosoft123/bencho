class Help < ActiveRecord::Base
  
  # acts_as_textiled :content
  
  set_table_name :help
  
  validates_uniqueness_of :action, :scope => [:controller], :message => 'The combination of controller and action must be unique'
  validates_presence_of :controller
  validates_presence_of :action
  validates_presence_of :content
  
  def validate
    # Ensure route is valid
    route = ActionController::Routing::Routes.routes_for_controller_and_action(controller.to_s, action.to_s)
    errors.add :base, 'Invalid route' if route.empty?
  end
  
  has_and_belongs_to_many :users
  
  def has_been_show_to?(user)
    begin
      return true if users.find(user.id)
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end
  
  def has_now_been_shown_to!(user)
    self.users << user
  end
  
end
