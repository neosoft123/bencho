# load Facebook YAML configuration file (credit: Evan Weaver)
::TUNNEL = {}
begin
  yamlFile = YAML.load_file("#{RAILS_ROOT}/config/tunnel.yml")
rescue Exception => e
  raise StandardError, "config/tunnel.yml could not be loaded."
end

if yamlFile
  if yamlFile[RAILS_ENV]
    TUNNEL.merge!(yamlFile[RAILS_ENV])
  else
    raise StandardError, "config/tunnel.yml exists, but doesn't have a configuration for RAILS_ENV=#{RAILS_ENV}."
  end
else
  raise StandardError, "config/tunnel.yml does not exist."
end
