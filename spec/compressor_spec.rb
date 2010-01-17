require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Compressor" do
  before(:each) do
    stub_io
  end
  
  describe "Base" do
    it "should use the compressed file if it already exists" do
      File.stub(:exists?).and_return(true)
      @file = "compressed file"
      File.stub(:read).and_return(@file)
      YMDP::Compressor::Base.compress("file.js", "type" => "js").should == @file
    end
    
    describe "generate a compressed file if one doesn't exist" do
      before(:each) do
        File.stub!(:exists?).and_return(false, true)
      end
      
      it "should log what it's doing" do
        $stdout.should_receive(:print).with(/file.js  compressing . . ./)
        YMDP::Compressor::Base.compress("file.js", "type" => "js")
      end
      
      it "should run the compressor" do
        F.should_receive(:execute).with(/yuicompressor/, :return => true).and_return("")
        YMDP::Compressor::Base.compress("file.js", "type" => "js")
      end
      
      describe "options" do
        it "should set nomunge" do
          F.should_receive(:execute).with(/nomunge/, :return => true).and_return("")
          YMDP::Compressor::Base.compress("file.js", "type" => "js", "obfuscate" => true)
        end
      
        it "should not set nomunge" do
          F.stub!(:execute).with(/yuicompressor/, :return => true).and_return("")
          F.should_not_receive(:execute).with(/nomunge/, :return => true).and_return("")
          YMDP::Compressor::Base.compress("file.js", "type" => "js", "obfuscate" => false)
        end
      
        it "should set verbose" do
          F.should_receive(:execute).with(/verbose/, :return => true).and_return("")
          YMDP::Compressor::Base.compress("file.js", "type" => "js", "verbose" => true)
        end
      
        it "should not set verbose" do
          F.stub!(:execute).with(/yuicompressor/, :return => true).and_return("")
          F.should_not_receive(:execute).with(/verbose/, :return => true).and_return("")
          YMDP::Compressor::Base.compress("file.js", "type" => "js", "verbose" => false)
        end
      
        it "should set preserve-semi on javascript" do
          F.should_receive(:execute).with(/preserve-semi/, :return => true).and_return("")
          YMDP::Compressor::Base.compress("file.js", "type" => "js")
        end
      
        it "should not set preserve-semi on css" do
          F.stub!(:execute).with(/yuicompressor/, :return => true).and_return("")
          F.should_not_receive(:execute).with(/preserve-semi/, :return => true).and_return("")
          YMDP::Compressor::Base.compress("file.css", "type" => "css")
        end
      end
      
      describe "on errors" do
        before(:each) do
          F.stub!(:execute).with(/yuicompressor/, :return => true).and_return("[ERROR] 12:13: Too much fruzzlegump")
        end
        
        it "should raise an exception" do
          lambda {
            YMDP::Compressor::Base.compress("file.js", "type" => "js")
          }.should raise_error(/JavaScript errors/)
        end
        
        it "should growl" do
          @g.should_receive(:notify)
          lambda {
            YMDP::Compressor::Base.compress("file.js", "type" => "js")
          }.should raise_error(/JavaScript errors/)
        end
        
        it "should show the source code" do
          F.should_receive(:get_line_from_file).with("file.js", 12).and_return("")
          lambda {
            YMDP::Compressor::Base.compress("file.js", "type" => "js")
          }.should raise_error(/JavaScript errors/)
        end
      end
      
      it "should report OK" do
        $stdout.should_receive(:puts).with("OK")
        YMDP::Compressor::Base.compress("file.js", "type" => "js")
      end
      
      it "should raise an error if the compressed file doesn't exist" do
        File.stub!(:exists?).and_return(false)
        lambda {
          YMDP::Compressor::Base.compress("file.js", "type" => "js")
        }.should raise_error(/File does not exist/)
      end
    end
  end
  
  describe "JavaScript" do
    it "should call Base with type js" do
      File.stub(:exists?).and_return(true)
      @file = "compressed file"
      File.stub(:read).and_return(@file)
      YMDP::Compressor::JavaScript.compress("file.js").should == @file
    end
  end
  
  describe "Stylesheet" do
    it "should call Base with type css" do
      File.stub(:exists?).and_return(true)
      @file = "compressed file"
      File.stub(:read).and_return(@file)
      YMDP::Compressor::Stylesheet.compress("file.css").should == @file
    end
  end
end