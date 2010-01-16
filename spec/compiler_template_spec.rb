require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'compiler/base'
require 'compiler/template'


describe "Compiler" do
  before(:each) do
    reset_constant(:YMDP_ENV, "build")
    reset_constant(:CONFIG, mock('config').as_null_object)

    Application.stub!(:current_view=)
    
    stub_io
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
      stub_yrb_configuration
      
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
    
    describe "validation" do
      it "should raise an error without a server" do
        lambda {
          @view_template = YMDP::Compiler::Template::View.new(@params.merge({:domain => "nowhere"}))
        }.should raise_error
      end
    end
  end
end