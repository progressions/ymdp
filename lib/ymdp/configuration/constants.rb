CONFIG = YMDP::Configuration::Config.new unless defined?(CONFIG)
SERVERS = YMDP::Configuration::Servers.new unless defined?(SERVERS)

YMDP::Base.configure do |config|
  config.username = CONFIG["username"]
  config.password = CONFIG["password"]
  config.default_server = CONFIG["default_server"]
  config.growl = CONFIG["growl"]
  config.verbose = CONFIG["verbose"]
  config.compress = CONFIG["compress"]
  config.validate = CONFIG["validate"]
  
  config.add_path(:base_path, BASE_PATH)
  config.servers = SERVERS
  
  config.load_content_variables("config.yml")
end
