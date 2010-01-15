require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'compiler/domains'

describe "Domains" do
  before(:each) do
    stub_git_helper
    
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
    
    @options = {
      :commit => true,
      :branch => "master",
      :message => "Commit message"
    }
    @base_path = "."
    
    YMDP::Compiler::Domains.base_path = @base_path
    YMDP::Compiler::Domains.servers = @servers
    
    @domains = YMDP::Compiler::Domains.new(@options)
  end
  
  describe "instantiation" do
    it "should instantiate" do
      @domains.should_not be_nil
    end
    
    it "should set options" do
      @domains.options.should == @options
    end
    
    it "should set message" do
      @domains.message.should == @options[:message]
    end
    
    it "should set servers" do
      @domains.servers.should == @servers
    end
    
    it "should set base_path" do
      @domains.base_path.should == @base_path
    end
    
    it "should set domains" do
      @domains = YMDP::Compiler::Domains.new(@options.merge({:domain => "staging"}))
      @domains.domains.should == ["staging"]
    end
    
    it "should not commit" do
      @git_helper.should_not_receive(:do_commit)
      @domains = YMDP::Compiler::Domains.new(@options.merge({:commit => false}))
    end
    
    it "should commit" do
      @git_helper.should_receive(:do_commit).with(@options[:message])
      @domains = YMDP::Compiler::Domains.new(@options)
    end
  end
  
  describe "compile" do
    before(:each) do
      stub_screen_io
      stub_file_io("")
      stub_erb("")
      stub_timer
      
      @compiler = mock('compiler').as_null_object
      YMDP::Compiler::Base.stub!(:new).and_return(@compiler)
    end
    
    describe "process domains" do
      it "should create a new compiler" do
        @servers.keys.each do |server|
          YMDP::Compiler::Base.should_receive(:new).with(anything, anything, anything).and_return(@compiler)
        end
        @domains.compile
      end
    
      it "should process the views" do
        @servers.keys.each do |server|
          @compiler.should_receive(:process_all)
        end
        @domains.compile
      end
    end
  end
end
