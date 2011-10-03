class PrivateColumn < String
  def initialize
    super
    self << "Private"
  end
  
  def build(arg)
    []
  end
  
  def create(arg)
    nil
  end
  
  def value
    "Private"
  end
end