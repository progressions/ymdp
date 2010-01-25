require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'validator/validator'

describe "Validator" do
  before(:each) do
    stub_io
    stub_config
    stub_ymdp_configuration
    File.stub!(:exists?).with(/jslint.js/).and_return(true)
  end
  
  describe "HTML" do
    before(:each) do
      class ResultsMock
        def errors
          []
        end
      end
      
      class ValidatorMock
        def validate_file(path)
          ResultsMock.new
        end
        
        def set_doctype!(doctype)
          
        end
      end
      
      @validator = ValidatorMock.new
      W3CValidators::MarkupValidator.stub!(:new).and_return(@validator)
    end
    
    it "should call validator" do
      W3CValidators::MarkupValidator.should_receive(:new).and_return(@validator)
      YMDP::Validator::HTML.validate("path")
    end
    
    it "should print OK" do
      $stdout.should_receive(:puts).with(/OK/)
      YMDP::Validator::HTML.validate("path")
    end
    
    describe "errors" do
      before(:each) do
        class ResultsMock
          def errors
            ["HTML Error 1", "HTML Error 2"]
          end
        end
      
        class ValidatorMock
          def validate_file(path)
            ResultsMock.new
          end
        
          def set_doctype!(doctype)
          
          end
        end
      
        @validator = ValidatorMock.new
        W3CValidators::MarkupValidator.stub!(:new).and_return(@validator)
      end
      
      it "should be false" do
        YMDP::Validator::HTML.validate("path").should be_false
      end
      
      it "should output a message" do
        $stdout.should_receive(:puts).with("validation errors")
        YMDP::Validator::HTML.validate("path")
      end
    end
  end
  
  describe "JavaScript" do
    describe "jslint" do
      before(:each) do
        File.stub!(:exists?).with(/jslint.js/).and_return(true)
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