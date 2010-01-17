CONFIG = YMDP::Configuration::Config.new unless defined?(CONFIG)
SERVERS = YMDP::Configuration::Servers.new unless defined?(SERVERS)

@content_variables = YAML.load_file("#{CONFIG_PATH}/content.yml")

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
  
  config.content_variables = @content_variables
end