
def stub_ymdp_configuration
  @content_variables = {
    "version" => 1,
    "sprint_name" => "Firefly" 
  }
  
  @servers = {
    "staging" => {
      "server" => "staging",
      "application_id" => "12345",
      "assets_id" => "abcdefg_1"
    },
  
    "production" => {
      "server" => "www",
      "application_id" => "678910",
      "assets_id" => "hijklmno_1"
    }
  }
  @servers.stub!(:servers).and_return(@servers)
  
  @compress = {"obfuscate"=>true, "js_assets"=>true, "css"=>true, "embedded_js"=>true}
  @validate = {"html"=>{"doctype"=>"HTML 4.0 Transitional", "build"=>true, "deploy"=>true}, "js_assets"=>{"build"=>false, "deploy"=>false}, "json_assets"=>{"build"=>false, "deploy"=>false}, "embedded_js"=>{"build"=>true, "deploy"=>true}}

  @base_path = "./base_path/"

  YMDP::Base.configure do |config|
    config.username = "malreynolds"
    config.password = "firefly2591"
    config.default_server = "staging"
    config.growl = true
    config.verbose = false
    config.compress = @compress
    config.validate = @validate

    config.add_path(:base_path, @base_path)
    config.servers = @servers
    
    config.content_variables = @content_variables
  end
end
