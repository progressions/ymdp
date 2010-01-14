require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'deploy/ymdt'

describe "YMDT" do
  before(:each) do
    $stdout.stub!(:puts)
  end
  
  describe "instantiation" do
    it "should raise error without a username and password" do
      lambda {
        YMDT::Base.new()
      }.should raise_error(ArgumentError)
    end
    
    it "should raise error without a username" do
      lambda {
        YMDT::Base.new(:password => "password")
      }.should raise_error(ArgumentError)
    end
    
    it "should raise error without a password" do
      lambda {
        YMDT::Base.new(:username => "fred")
      }.should raise_error(ArgumentError)
    end
    
    it "should not raise error with a username and password" do
      lambda {
        YMDT::Base.new(:username => "fred", :password => "password")
      }.should_not raise_error(ArgumentError)
    end
    
    describe "instance variables" do
      before(:each) do
        @script_path = "./path/to/ymdt"
        @username = "fred"
        @password = "password"
        @ymdt = YMDT::Base.new(:username => @username, :password => @password, :script_path => @script_path)
      end
      
      it "should set username" do
        @ymdt.username.should == @username
      end
      
      it "should set password" do
        @ymdt.password.should == @password
      end
      
      it "should set script_path" do
        @ymdt.script_path.should == @script_path
      end
    end
  end
  
  describe "invoke" do
    before(:each) do
      YMDT::System.stub!(:execute)
      @ymdt = YMDT::Base.new(:username => "fred", :password => "password", :script_path => "./path/to/ymdt")
    end
    
    it "should execute command" do
      YMDT::System.should_receive(:execute).with("./path/to/ymdt put \".//servers/app\" -ufred -ppassword")
      @ymdt.invoke(:put, :application => "app")
    end
    
    it "should add sync flag" do
      YMDT::System.should_receive(:execute).with("./path/to/ymdt put \".//servers/app\" -s -ufred -ppassword")
      @ymdt.invoke(:put, :application => "app", :sync => true)
    end
    
    it "should put a path" do
      YMDT::System.should_receive(:execute).with("./path/to/ymdt put \".//servers/app/views\" -ufred -ppassword")
      @ymdt.invoke(:put, :application => "app", :path => "views")
    end
    
    it "shouldn't add extra slashes" do
    end
    
    describe "shortcut methods" do
      it "should put" do
        YMDT::System.should_receive(:execute).with("./path/to/ymdt put \".//servers/app\" -ufred -ppassword")
        @ymdt.put(:application => "app")
      end
      
      it "should get" do
        YMDT::System.should_receive(:execute).with("./path/to/ymdt get \".//servers/app\" -ufred -ppassword")
        @ymdt.get(:application => "app")
      end
      
      it "should create" do
        YMDT::System.should_receive(:execute).with("./path/to/ymdt get \".//servers/app\" -a12345 -ufred -ppassword")
        @ymdt.create(:application_id => "12345", :application => "app")
      end
      
      it "should ls" do
        YMDT::System.should_receive(:execute).with("./path/to/ymdt ls \".//servers/app\" -ufred -ppassword", :return => true)
        @ymdt.ls(:application => "app")
      end
      
      it "ls should return results" do
        @results = "These are the results."
        YMDT::System.stub!(:execute).with(anything, :return => true).and_return(@results)
        @ymdt.ls(:application => "app").should == @results
      end
    end
    
    describe "dry run" do
      it "should not execute anything for a dry run" do
        YMDT::System.should_not_receive(:execute)
        @ymdt.invoke(:put, :application => "app", :dry_run => true)
      end
    end
    
    describe "return results" do
      before(:each) do
        @results = "These are the results."
        YMDT::System.stub!(:execute).with(anything, :return => true).and_return(@results)
      end
      
      it "should return results from YMDT::System" do
        YMDT::System.should_receive(:execute).with(anything, :return => true)
        @ymdt.invoke(:put, :application => "app", :return => true)
      end
      
      it "should return results" do
        @ymdt.invoke(:put, :application => "app", :return => true).should == @results
      end
    end
    
    describe "output" do
      it "should not print username and password" do
        $stdout.should_receive(:puts).with("./path/to/ymdt put \".//servers/app\" -u[username] -p[password]")
        @ymdt.invoke(:put, :application => "app")
      end
    end
  end
end










