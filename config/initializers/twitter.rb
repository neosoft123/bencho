TWITTER_CONFIG = YAML.load_file(File.join(RAILS_ROOT, 'config', 'twitter.yml'))[ENV['RAILS_ENV']]
