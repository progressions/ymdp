require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'compiler/base'
require 'compiler/template'

describe "Template" do
  before(:each) do
    stub_screen_io
    
    reset_constant(:YMDP_ENV, "build")

    Application.stub!(:current_view=)
    
    @domain = "staging"
    @filename = "filename.html.haml"
    @git_hash = "asjkhfasjkfhjk"
    @message = "This is a commit message."
    
    stub_ymdp_configuration
    
    stub_config
  end
  
  describe "javascript" do
    before(:each) do
      stub_file_utils
      
      @filename = "filename.pres"
      
      @params = {
        :verbose => false,
        :domain => @domain,
        :file => @filename,
        :git_hash => @git_hash,
        :message => @message
      }
      
      @js_template = YMDP::Compiler::Template::YRB.new(@params)
    end
    
    it "should instantiate" do
      @js_template.should_not be_nil
    end
    
    describe "build" do
      before(:each) do
        @file = mock('file', :write => true)
        File.stub!(:open).with(/filename.json/, "w").and_return(@file)
        F.stub!(:save_to_file)
      end
    
      it "should save json" do
        File.stub!(:read).with("filename.pres").and_return("KEY=value")
        @js_template.build.should == "{\"KEY\":\"value\"}"
      end
      
      it "should skip lines that aren't keys" do
        File.stub!(:read).with("filename.pres").and_return("KEY=value\nnot a key\n")
        @js_template.build.should == "{\"KEY\":\"value\"}"
      end
      
      it "should raise error for duplicate keys" do
        File.stub!(:read).with("filename.pres").and_return("KEY=value\nKEY=value\n")
        lambda {
          @js_template.build
        }.should raise_error(/Duplicate key error/)
      end
      
      describe "methods" do
        before(:each) do
          @file = mock('file', :write => true)
          File.stub!(:open).with(/filename.json/, "w").and_return(@file)
          F.stub!(:save_to_file)
          File.stub!(:read).with("filename.pres").and_return("KEY=value")
        end
        
        it "should return json" do
          @js_template.to_json.should == "{\"KEY\":\"value\"}"
        end
        
        it "should return yaml" do
          @js_template.to_yaml.should == "--- \nkey: value\n"
        end
        
        it "should validate" do
          YMDP::Validator::JSON.should_receive(:validate)
          @js_template.validate
        end
      end
    end
  end

  
  describe "javascript" do
    before(:each) do
      stub_file_utils
      
      @filename = "filename.js"
      
      @params = {
        :verbose => false,
        :domain => @domain,
        :file => @filename,
        :git_hash => @git_hash,
        :message => @message
      }
      
      @js_template = YMDP::Compiler::Template::JavaScript.new(@params)
      
    end
    
    it "should instantiate" do
      @js_template.should_not be_nil
    end
    
    it "should build" do
      @js_template.configuration.compress["embedded_js"] = false
      
      File.stub!(:read).with("filename.js").and_return("unprocessed")
      
      # process the contents of filename.html.erb through ERB
      #
      @erb = mock('erb', :result => "processed template output")
      ERB.should_receive(:new).with("unprocessed", anything, anything).and_return(@erb)
      
      YMDP::Compressor::JavaScript.stub!(:compress).and_return("compressed template output")
      
      F.stub!(:save_to_file).with("processed template output")
      
      @js_template.build.should == "processed template output"
    end
    
    it "should compress" do
      # process the contents of filename.html.erb through ERB
      #
      @erb = mock('erb', :result => "processed template output")
      ERB.should_receive(:new).with("unprocessed", anything, anything).and_return(@erb)      
      
      YMDP::Compressor::JavaScript.stub!(:compress).and_return("compressed template")
      File.stub!(:read).with("filename.js").and_return("unprocessed")
      
      F.stub!(:save_to_file)
      
      @js_template.build.should == "compressed template"
    end
  end
  
  describe "view" do
    before(:each) do
      @params = {
        :verbose => false,
        :domain => @domain,
        :file => @filename,
        :git_hash => @git_hash,
        :message => @message
      }      
      @view_template = YMDP::Compiler::Template::View.new(@params)
    end
    
    describe "instantiation" do
      it "should raise an error if called on base" do
        lambda {
          @view_template = YMDP::Compiler::Template::Base.new(@params)
        }.should raise_error("Define in child")
      end
      
      it "should raise an error if process_template is called from base" do
        class Thing < YMDP::Compiler::Template::Base
          def base_filename(filename)
            filename
          end
        end
        
        @thing = Thing.new(@params)
        lambda {
          @thing.process_template("template")
        }.should raise_error("Define in child")
      end
      
      it "should instantiate" do
        @view_template.should_not be_nil
      end
      
      it "should set verbose" do
        @view_template.verbose?.should be_false
      end
      
      it "should set domain" do
        @view_template.domain.should == @domain
      end
      
      it "should set server" do
        @view_template.server.should == "staging"
      end
      
      it "should set file" do
        @view_template.file.should == @filename
      end
      
      it "should set content variables" do
        @view_template.instance_variable_get("@version").should == @content_variables["version"]
        @view_template.instance_variable_get("@sprint_name").should == @content_variables["sprint_name"]
      end
      
      it "should set Application.current_view" do
        Application.should_receive(:current_view=).with("filename")
        @view_template = YMDP::Compiler::Template::View.new(@params)
      end
    end
    
    describe "build" do
      before(:each) do
        @processed_haml = "processed haml"
        stub_haml_class
        
        YMDP::Validator::HTML.stub!(:validate).and_return(true)
      end
      
      it "should not build if it's a partial" do
        @view_template = YMDP::Compiler::Template::View.new(@params.merge({:file => "_partial.html.haml"}))
        @view_template.build.should be_nil
      end
      
      it "should get Haml when no layout exists" do
        stub_file_utils
        
        # File.exists? will return false, so no layouts exist
        
        # read the contents of filename.html.haml
        #
        File.stub!(:read).with("filename.html.haml").and_return("unprocessed")
        
        # process the contents of filename.html.haml through Haml::Engine
        #
        @haml = mock('haml', :render => "processed_template output")
        Haml::Engine.stub!(:new).with("unprocessed", :doctype => :html4, :filename=>"filename.html.haml").and_return(@haml)
        
        @view_template.build.should == "processed_template output"
      end
      
      it "should get ERB when no layout exists" do
        stub_file_utils
        
        # File.exists? will return false, so no layouts exist
        
        # read the contents of filename.html.haml
        #
        File.stub!(:read).with("filename.html.erb").and_return("unprocessed")
        
        # process the contents of filename.html.erb through ERB
        #
        @erb = mock('erb', :result => "processed_template output")
        ERB.should_receive(:new).with("unprocessed", anything, anything).and_return(@erb)
        
        @view_template = YMDP::Compiler::Template::View.new(@params.merge({:file => "filename.html.erb"}))
        @view_template.build.should == "processed_template output"
      end
      
      describe "haml template exists" do
        it "should return processed layout" do
          stub_file_utils
          
          File.stub!(:exists?).with(/application.html.haml/).and_return(true)
          
          # read the contents of application.html.haml
          #
          File.stub!(:read).with(/application.html.haml/).and_return("unprocessed layout") 
          
          # process the contents of application.html.haml through Haml::Engine
          #
          @layout_haml = mock('layout_haml', :render => "processed layout")
          Haml::Engine.stub!(:new).with("unprocessed layout", :doctype => :html4, :filename=>"./base_path//app/views/layouts/application.html.haml").and_return(@layout_haml)
          
          # read the contents of filename.html.haml
          #
          File.stub!(:read).with("filename.html.haml").and_return("unprocessed")
          
          # process the contents of filename.html.haml through Haml::Engine
          #
          @haml = mock('haml', :render => "processed template output")
          Haml::Engine.stub!(:new).with("unprocessed", :doctype => :html4, :filename=>"filename.html.haml").and_return(@haml)
          
          @view_template.build.should == "processed layout"        
        end
      end
    end
    
    describe "validation" do
      it "should raise an error without a server" do
        lambda {
          @view_template = YMDP::Compiler::Template::View.new(@params.merge({:domain => "nowhere"}))
        }.should raise_error("Server settings are required.")
      end
      
      it "should raise an error without a server" do
        @invalid_servers = {
          "staging" => {
            "application_id" => "abcdefg_1"
          }
        }
        YMDP::Base.configure do |config|
          config.servers = @invalid_servers
        end
        
        lambda {
          @view_template = YMDP::Compiler::Template::View.new(@params)
        }.should raise_error("Server name does not exist in server settings.")
      end
    end
  end
end