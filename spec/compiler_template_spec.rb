require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'compiler/base'
require 'compiler/template'


describe "Compiler" do
  before(:each) do
    Object.send(:remove_const, :YMDP_ENV)
    YMDP_ENV = "build"
    
    Object.send(:remove_const, :CONFIG)
    CONFIG = mock('config').as_null_object

    Application.stub!(:current_view=)
    
    stub_screen_io
    stub_file_io
    stub_file_utils
    stub_yaml
  end
  
  describe "view" do
    before(:each) do
        @domain = "staging"
        @filename = "filename.html.haml"
        @git_hash = "asjkhfasjkfhjk"
        @message = "This is a commit message."
        
        @params = {
          :verbose => false,
          :domain => @domain,
          :file => @filename,
          :git_hash => @git_hash,
          :message => @message
        }
        @content_variables = {
          "version" => "0.1.0",
          "sprint_name" => "Gorgonzola"
        }
        YAML.stub!(:load_file).with(/content\.yml$/).and_return(@content_variables)
        
        
    
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
        @base_path = "."
        
        YMDP::Compiler::Template::Base.servers = @servers
        YMDP::Compiler::Template::Base.base_path = @base_path
        
        @view_template = YMDP::Compiler::Template::View.new(@params)
    end
    
    describe "instantiation" do
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
        @view_template.server.should == @servers["server"]
      end
      
      it "should set file" do
        @view_template.file.should == @filename
      end
      
      it "should get content variables from yml file" do
        YAML.should_receive(:load_file).with(/content\.yml$/)
        @view_template = YMDP::Compiler::Template::View.new(@params)
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
  end
end