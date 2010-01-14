require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Configuration" do
  describe "Config" do
    before(:each) do
      @config_yml = {
        "config" => {
          "username" => "captmal",
          "password" => "iluvinara",
          "growl" => true
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
    
    it "should return growl" do
      @config.growl?.should == @config_yml["config"]["growl"]
    end
    
    describe "[]" do
      it "should return username" do
        @config["username"].should == @config_yml["config"]["username"]
      end
    
      it "should return password" do
        @config["password"].should == @config_yml["config"]["password"]
      end
    end
  end
end