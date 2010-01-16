require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'compiler/base'
require 'compiler/template'

YMDP_ENV = "build"

describe "Compiler" do
  before(:each) do
    Object.send(:remove_const, :CONFIG)
    CONFIG = mock('config').as_null_object
    stub_screen_io
    stub_file_io
    stub_file_utils

    @domain = 'staging'
    @git_hash = 'asdfh23rh2fas'
    @base_path = "."
    
    @compiler = YMDP::Compiler::Base.new(@domain, @git_hash, :base_path => @base_path, :server => "staging")
  end
    
  describe "instantiation" do
    it "should instantiate" do
      @compiler.should_not be_nil
    end
    
    it "should set domain" do
      @compiler.domain.should == @domain
    end
    
    it "should set git_hash" do
      @compiler.git_hash.should == @git_hash
    end
  end
  
  describe "log" do
    it "should return output formatted with time" do
      @compiler.log("Hello").should match(/Hello$/)
    end
  end
  
  describe "process" do
    before(:each) do
      YMDP::ApplicationView.stub!(:supported_languages).and_return([])
      
      @view_template = mock('view_template').as_null_object
      YMDP::Compiler::Template::View.stub!(:new).and_return(@view_template)
      @js_template = mock('js_template').as_null_object
      YMDP::Compiler::Template::JavaScript.stub!(:new).and_return(@js_template)
      @yrb_template = mock('yrb_template').as_null_object
      YMDP::Compiler::Template::YRB.stub!(:new).and_return(@yrb_template)
      
      Dir.stub!(:[]).and_return([])
    end
    
    it "should see if server directory exists" do
      File.should_receive(:exists?).with("#{@base_path}/servers/#{@domain}")
      @compiler.process_all
    end
    
    describe "copy_images" do
      it "should remove images folder" do
        FileUtils.should_receive(:rm_rf).with("./app/servers/#{@domain}/assets/images")
        @compiler.process_all
      end
      
      it "should create images folder" do
        FileUtils.should_receive(:mkdir_p).with("./app/servers/#{@domain}/assets")
        @compiler.process_all
      end
      
      it "should copy images from app to server" do
        FileUtils.should_receive(:cp_r).with("./app/assets/images/", "./app/servers/#{@domain}/assets")
        @compiler.process_all
      end
      
      it "should log in verbose mode" do
        @compiler = YMDP::Compiler::Base.new(@domain, @git_hash, :base_path => @base_path, :server => "staging", :verbose => true)
        $stdout.should_receive(:puts).with(/Moving images/)
        @compiler.process_all
      end
    end

    describe "translations" do
      before(:each) do
        @supported_languages = ["en-US", "de-DE"]
        YMDP::ApplicationView.stub!(:supported_languages).and_return(@supported_languages)
      end
      
      it "should act on the list of supported languages" do
        @supported_languages.each do |lang|
          F.should_receive(:concat_files).with("#{@base_path}/app/assets/yrb/#{lang}/*", /keys_#{lang}\.pres/)
        end
        @compiler.process_all
      end
      
      it "should instantiate a new YRB template" do
        @supported_languages.each do |lang|
          YMDP::Compiler::Template::YRB.should_receive(:new) do |options|
            options[:file].should =~ /keys_#{lang}\.pres/
          end
        end
        @compiler.process_all
      end
      
      it "should build the new YRB template" do
        @supported_languages.each do |lang|
          @yrb_template.should_receive(:build)
        end
        @compiler.process_all
      end
      
      it "should validate the new YRB template" do
        CONFIG.stub!(:validate_json_assets?).and_return(true)
        @supported_languages.each do |lang|
          @yrb_template.should_receive(:validate)
        end
        @compiler.process_all
      end
      
      it "should validate the new YRB template" do
        CONFIG.stub!(:validate_json_assets?).and_return(false)
        @yrb_template.should_not_receive(:validate)
        @compiler.process_all
      end
    end
    
    describe "views" do
      describe "haml" do
        before(:each) do
          @files = ["./app/views/view.html.haml"]
          Dir.stub!(:[]).with("./app/views/**/*").and_return(@files)
        end
    
        it "should run on all views in the path" do
          Dir.should_receive(:[]).with("./app/views/**/*").and_return(@files)
          @compiler.process_all
        end
      
        it "should create view template class for haml" do
          YMDP::Compiler::Template::View.should_receive(:new).with(hash_including(:file => @files.first)).and_return(@view_template)
          @compiler.process_all
        end
      
        it "should build haml template" do
          YMDP::Compiler::Template::View.stub!(:new).with(hash_including(:file => @files.first)).and_return(@view_template)
          @view_template.should_receive(:build)
          @compiler.process_all
        end
      end
      
      describe "erb" do
        before(:each) do
          @files = ["./app/views/view.html.erb"]
          Dir.stub!(:[]).with("./app/views/**/*").and_return(@files)
        end
    
        it "should run on all views in the path" do
          Dir.should_receive(:[]).with("./app/views/**/*").and_return(@files)
          @compiler.process_all
        end
      
        it "should create view template class for haml" do
          YMDP::Compiler::Template::View.should_receive(:new).with(hash_including(:file => @files.first)).and_return(@view_template)
          @compiler.process_all
        end
      
        it "should build haml template" do
          YMDP::Compiler::Template::View.stub!(:new).with(hash_including(:file => @files.first)).and_return(@view_template)
          @view_template.should_receive(:build)
          @compiler.process_all
        end
      end
    end
    
    it "should run on all views in the path" do
      files = ["./app/assets/javascripts/view.js"]
      Dir.should_receive(:[]).with("./app/assets/**/*").and_return(files)
      @compiler.process_all
    end
  end
end