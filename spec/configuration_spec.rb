require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Configuration" do
  before(:each) do
    stub_screen_io
    reset_constant(:YMDP_ENV, "test")
    
    File.stub!(:exists?).with(/servers.yml/).and_return(true)
    File.stub!(:exists?).with(/config.yml/).and_return(true)
  end
  
  describe "Config" do
    before(:each) do
      # using strings for some boolean values to avoid false positives
      
      @config_yml = {
        "config" => {
          "username" => "captmal",
          "password" => "inara",
          "growl" => 'growl',
          "verbose" => 'verbose',
          "compress" => {
            "embedded_js" => "compress_embedded_js",
            "js_assets" => "compress_js_assets",
            "css" => "compress_css",
            "obfuscate" => "obfuscate"
          },
          "validate" => {
            "embedded_js" => {
              "test" => "validate_embedded_js"
            },
            "js_assets" => {
              "test" => "validate_js_assets"
            },
            "json_assets" => {
              "test" => "validate_json_assets"
            },
            "html" => {
              "test" => "validate_html"
            }
          }
        }
      }
      YAML.stub!(:load_file).and_return(@config_yml)
      @config = YMDP::Configuration::Config.new
    end
    
    it "should return username" do
      @config.username.should == @config_yml["config"]["username"]
    end
    
    it "should return password" do
      @config.password.should == @config_yml["config"]["password"]
    end
    
    it "should return growl?" do
      @config.growl?.should == @config_yml["config"]["growl"]
    end
    
    it "should return verbose?" do
      @config.verbose?.should == @config_yml["config"]["verbose"]
    end
    
    describe "compress settings" do
    
      it "should return compress_embedded_js?" do
        @config.compress_embedded_js?.should == @config_yml["config"]["compress"]["embedded_js"]
      end
    
      it "should return compress_js_assets?" do
        @config.compress_js_assets?.should == @config_yml["config"]["compress"]["js_assets"]
      end
    
      it "should return compress_css?" do
        @config.compress_css?.should == @config_yml["config"]["compress"]["css"]
      end
    
      it "should return obfuscate?" do
        @config.obfuscate?.should == @config_yml["config"]["compress"]["obfuscate"]
      end
    end
    
    describe "validate settings" do
      it "should return validate_embedded_js?" do
        @config.validate_embedded_js?.should == @config_yml["config"]["validate"]["embedded_js"][YMDP_ENV]
      end
    
      it "should return validate_js_assets?" do
        @config.validate_js_assets?.should == @config_yml["config"]["validate"]["js_assets"][YMDP_ENV]
      end
    
      it "should return validate_json_assets?" do
        @config.validate_json_assets?.should == @config_yml["config"]["validate"]["json_assets"][YMDP_ENV]
      end
    
      it "should return validate_html?" do
        @config.validate_html?.should == @config_yml["config"]["validate"]["html"][YMDP_ENV]
      end
    end
    
    describe "each" do
      it "should go through each of the values" do
        $stdout.should_receive(:puts).exactly(@config_yml["config"].keys.length).times
        @config.each do |key, value|
          $stdout.puts key
        end
      end
    end
    
    describe "[]" do
      it "should return username" do
        @config["username"].should == @config_yml["config"]["username"]
      end
    
      it "should return password" do
        @config["password"].should == @config_yml["config"]["password"]
      end
    end
    
    describe "file not found" do
      before(:each) do
        File.stub!(:exists?).and_return(false)
      end
      
      it "should raise an error" do
        lambda {
          @config = YMDP::Configuration::Config.new
        }.should raise_error(/File not found/)
      end
      
      it "should output to the screen" do
        $stdout.should_receive(:puts).with(/with the following command/)
        lambda {
          @config = YMDP::Configuration::Config.new
        }.should raise_error(/File not found/)        
      end
    end
  end
  
  describe "Server" do
    before(:each) do
      @servers_yml = {
        "servers" => {
          "server" => "staging"
        }
      }
      YAML.stub!(:load_file).and_return(@servers_yml)
      @servers = YMDP::Configuration::Servers.new
    end
    
    it "should return servers hash" do
      @servers.servers.should == @servers_yml["servers"]
    end
  end
end