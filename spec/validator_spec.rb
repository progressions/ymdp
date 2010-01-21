require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'processor/w3c'

describe "Validator" do
  before(:each) do
    stub_io
    stub_config
  end
  
  describe "HTML" do
    before(:each) do
      @resp = mock('resp', :read_body => "[Valid]")
      W3CPoster.stub!(:post_file_to_w3c_validator).and_return(@resp)
    end
    
    it "should call validator" do
      W3CPoster.should_receive(:post_file_to_w3c_validator).and_return(@resp)
      YMDP::Validator::HTML.validate("path")
    end
    
    it "should print OK" do
      $stdout.should_receive(:puts).with(/OK/)
      YMDP::Validator::HTML.validate("path")
    end
    
    describe "errors" do
      before(:each) do
        @resp.stub!(:read_body => "Not Valid")
      end
      
      it "should output a message" do
        $stdout.should_receive(:puts).with(/not valid HTML/)
        lambda {
          YMDP::Validator::HTML.validate("path")
        }.should raise_error("Invalid HTML")
      end
      
      it "should open the error file" do
        File.should_receive(:open).with(/path_errors/, "w").and_return(@file)
        lambda {
          YMDP::Validator::HTML.validate("path")
        }.should raise_error("Invalid HTML")
      end
      
      it "should write to the error file" do
        @file.should_receive(:puts).with("Not Valid")
        lambda {
          YMDP::Validator::HTML.validate("path")
        }.should raise_error("Invalid HTML")
      end
      
      it "should growl a message" do
        @g.should_receive(:notify).with(anything, anything, /HTML validation errors/, anything, anything)
        lambda {
          YMDP::Validator::HTML.validate("path")
        }.should raise_error("Invalid HTML")
      end
      
      it "should open the error file" do
        F.should_receive(:execute).with(/open/)
        lambda {
          YMDP::Validator::HTML.validate("path")
        }.should raise_error("Invalid HTML")
      end
      
      it "should raise an error" do
        lambda {
          YMDP::Validator::HTML.validate("path")
        }.should raise_error("Invalid HTML")
      end
    end
  end
  
  describe "JavaScript" do
    describe "jslint" do
      before(:each) do
        @jslint_settings = "/* These are JSLint settings %/"
        F.stub!(:execute).with(/java/, :return => true).and_return("jslint: No problems found")  
      end
      
      it "should set jslint settings" do
        YMDP::Validator::JavaScript.configure do |config|
          config.jslint_settings = @jslint_settings
        end
        YMDP::Validator::JavaScript.jslint_settings.should == @jslint_settings
      end
      
      it "should put jslint settings in the file" do
        @file.should_receive(:puts).with(@jslint_settings)
        YMDP::Validator::JavaScript.validate("path")
      end
    end
    
    describe "valid" do
      before(:each) do
        F.stub!(:execute).with(/java/, :return => true).and_return("jslint: No problems found")
      end
      
      it "should output 'OK'" do
        $stdout.should_receive(:puts).with(/OK/)
        YMDP::Validator::JavaScript.validate("path")
      end
    end
    
    describe "invalid" do
      before(:each) do
        @lines_with_errors = [
          "line 3 character 2: Unnecessary semicolon",
          "line 8 character 3: Unknown thingamajig"
        ].join("\n")
        F.stub!(:execute).with(/java/, :return => true).and_return(@lines_with_errors)
        F.stub!(:get_line_from_file).with(anything, 1)
        F.stub!(:get_line_from_file).with(anything, 5)
      end
      
      it "should growl" do
        @g.should_receive(:notify).with(anything, anything, /JavaScript Errors/, anything, anything)
        lambda {
          YMDP::Validator::JavaScript.validate("path")
        }.should raise_error
      end
      
      it "should output errors" do
        $stdout.should_receive(:puts).with(/Unnecessary semicolon/)
        $stdout.should_receive(:puts).with(/Unknown thingamajig/)
        lambda {
          YMDP::Validator::JavaScript.validate("path")
        }.should raise_error
      end
      
      it "should raise error" do
        lambda {
          YMDP::Validator::JavaScript.validate("path")
        }.should raise_error(/JavaScript Errors/)
      end
    end
  end
  
  describe "JSON" do
    describe "valid" do
      before(:each) do
        F.stub!(:execute).with(/java/, :return => true).and_return("jslint: No problems found")
      end
      
      it "should output 'OK'" do
        $stdout.should_receive(:puts).with(/OK/)
        YMDP::Validator::JSON.validate("path")
      end
    end
    
    describe "invalid" do
      before(:each) do
        @lines_with_errors = [
          "line 3 character 2: Unnecessary semicolon",
          "line 8 character 3: Unknown thingamajig"
        ].join("\n")
        F.stub!(:execute).with(/java/, :return => true).and_return(@lines_with_errors)
        F.stub!(:get_line_from_file).with(anything, 1)
        F.stub!(:get_line_from_file).with(anything, 5)
      end
      
      it "should growl" do
        @g.should_receive(:notify).with(anything, anything, /JavaScript Errors/, anything, anything)
        lambda {
          YMDP::Validator::JSON.validate("path")
        }.should raise_error
      end
      
      it "should output errors" do
        $stdout.should_receive(:puts).with(/Unnecessary semicolon/)
        $stdout.should_receive(:puts).with(/Unknown thingamajig/)
        lambda {
          YMDP::Validator::JSON.validate("path")
        }.should raise_error
      end
      
      it "should raise error" do
        lambda {
          YMDP::Validator::JSON.validate("path")
        }.should raise_error(/JavaScript Errors/)
      end
    end
    
    describe "Stylesheet" do
      it "should validate" do
        YMDP::Validator::Stylesheet.validate("path")
      end
    end
  end
end