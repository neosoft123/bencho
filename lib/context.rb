class Context
  attr_accessor :profile

  def self.current
    Thread.current[:kontact_context] ||= Context.new
  end
  
end