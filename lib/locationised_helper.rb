module LocationisedHelper
  def setup_map
    s = ""
    content_for :head do
      s << GMap.header
    end
    s
  end
end