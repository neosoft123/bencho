require 'erb'

class SmsBuilder
  attr_accessor :builder, :result, :expanded_path
  def initialize(options)
    partial = "#{options.delete(:partial)}.erb"
    expanded_path = File.join(RAILS_ROOT, 'app', 'views', partial)
    @builder = ERB.new(File.open(expanded_path, 'r').read)
  end
  
  def render_to_string(binding)
    @builder.result(binding)
  end
end