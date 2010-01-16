require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe YMDP::Base do
  describe "instantiation" do
    it "should instantiate" do
      @ymdp = YMDP::Base.new
      @ymdp.should_not be_nil
    end
  end
  
  describe "configuration" do
    before(:each) do
      @ymdp = YMDP::Base.new
    end
    
    it "should set username" do
      YMDP::Base.configure do |config|
        config.username = "mal"
      end
      @ymdp.username.should == "mal"
    end
    
    it "should set password" do
      YMDP::Base.configure do |config|
        config.password = "password"
      end
      @ymdp.password.should == "password"
    end
    
    it "should set default_server" do
      YMDP::Base.configure do |config|
        config.default_server = "staging"
      end
      @ymdp.default_server.should == "staging"
    end
        
    it "should set growl" do
      YMDP::Base.configure do |config|
        config.growl = true
      end
      @ymdp.growl.should be_true
    end
    
    it "should set verbose" do
      YMDP::Base.configure do |config|
        config.verbose = true
      end
      @ymdp.verbose.should be_true
    end
    
    it "should set compress" do
      @compress = {
        "obfuscate" => true,
        "css" => true
      }
      YMDP::Base.configure do |config|
        config.compress = @compress
      end
      @ymdp.compress.should == @compress
    end
    
    it "should set validate" do
      @validate = {
        "html" => {
          "doctype" => "4.0",
          "build" => true
        },
        "embedded_js" => {
          "build" => true,
          "deploy" => false
        }
      }
      YMDP::Base.configure do |config|
        config.validate = @validate
      end
      @ymdp.validate.should == @validate
    end
    
    describe "content variables" do
      describe "add" do
        it "should add a content_variable" do
          YMDP::Base.configure do |config|
            config.add_content_variable(:funky, "Real funky")
          end
          @ymdp.funky.should == "Real funky"
        end
      end
      
      describe "load" do
        before(:each) do
          YAML.should_receive(:load_file).with(/content.yml$/).and_return({
            "version" => "1.1",
            "sprint_name" => "Gargantuan"
          })
        end
        
        it "should load version from a file" do
          YMDP::Base.configure do |config|
            config.load_content_variables "content"
          end
          @ymdp.version.should == "1.1"
        end
      end
      
      describe "set" do
        before(:each) do        
          YMDP::Base.configure do |config|
            config.content_variables = {
              "version" => "1.2",
              "sprint_name" => "Gorgonzola"
            }
          end
        end
    
        it "should set sprint name in content variables" do
          @ymdp.version.should == "1.2"
        end
    
        it "should set sprint name in content variables" do
          @ymdp.sprint_name.should == "Gorgonzola"
        end
      end
    end
  end
end