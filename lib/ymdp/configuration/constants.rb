unless defined?(YMDP_TEST)
  CONFIG = YMDP::Configuration::Config.new unless defined?(CONFIG)
  SERVERS = YMDP::Configuration::Servers.new unless defined?(SERVERS)

  @content_variables = YAML.load_file("#{BASE_PATH}/config/content.yml") if File.exists?("#{BASE_PATH}/config/content.yml")

  @jslint_settings = File.read("#{BASE_PATH}/config/jslint.js") if File.exists?("#{BASE_PATH}/config/jslint.js")

  YMDP::Base.configure do |config|
    config.username = CONFIG["username"]
    config.password = CONFIG["password"]
    config.default_server = CONFIG["default_server"]
    config.host = CONFIG["host"]
    config.growl = CONFIG["growl"]
  
    config.add_path(:base_path, BASE_PATH)
    config.servers = SERVERS
  
    config.content_variables = @content_variables
  end

  Epic::Base.configure do |config|
    config.base_path = BASE_PATH
    config.tmp_path = TMP_PATH
    config.doctype = CONFIG["validate"]["html"]["doctype"]
    config.jslint_settings = @jslint_settings
  end
end