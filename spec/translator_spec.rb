require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'translator/base'

describe "Translator" do
  before(:each) do
    stub_timer
    stub_screen_io
  end
  
  describe "Yaml" do
    before(:each) do
      YAML.stub!(:load_file).and_return({"hi" => "what"})
      @original_translations = ["application_en-US.yml", "sidebar_en-US.yml"]
      Dir.stub!(:[]).with(/app\/assets\/yrb\/en-US\/\*\.yml/).and_return(@original_translations)
    end
    
    describe "class methods" do
      it "should output a message for each file" do
        File.stub!(:readlines).and_return([""])
        @original_translations.each do |file|
          $stdout.should_receive(:puts).with(/Processing /)
        end
        YMDP::Translator::Yaml.translate
      end
      
      it "should instantiate a new template" do
        @original_translations.each do |file|
          @yaml = mock('yaml', :copy => true)
          YMDP::Translator::Yaml.should_receive(:new).with(file).and_return(@yaml)
        end
        YMDP::Translator::Yaml.translate
      end
      
      it "should copy the new template" do
        @original_translations.each do |file|
          @yaml = mock('yaml', :copy => true)
          @yaml.should_receive(:copy)
          YMDP::Translator::Yaml.stub!(:new).with(file).and_return(@yaml)
        end
        YMDP::Translator::Yaml.translate
      end
    end
    
    describe "instance methods" do
      before(:each) do
        @path = "path_en-US.yml"
        @yml = YMDP::Translator::Yaml.new(@path)
      end
      
      it "should instantiate" do
        @yml.should_not be_nil
      end
      
      it "should copy keys" do
        File.stub!(:readlines).with("path_en-US.yml").and_return(["key: value\n"])
        # 
        @file = mock('file', :puts => true)
        @file.should_receive(:puts).with(/key: translated value/)
        
        File.stub!(:open).with(anything, "a").and_yield(@file)
        
        size = YMDP::Translator::Yaml::LOCALES.size - 1
        
        YMDP::Translator::Yaml::LOCALES.each do |lang, code|
          unless lang == "en-US"
            Dir.should_receive(:[]).with(/app\/assets\/yrb\/#{lang}\/\*\.yml/).and_return(["keys_#{lang}.yml"])
          end
        end
        
        Translate.stub!(:t).with("value", "ENGLISH", anything).exactly(size).and_return("translated value")
        
        @yml.copy
      end
      
      it "should not copy comments" do
        File.stub!(:readlines).with("path_en-US.yml").and_return(["# comment\n"])
        
        @file = mock('file', :puts => true)
        @file.should_not_receive(:puts).with(/key: translated value/)
        
        File.stub!(:open).with(anything, "a").and_yield(@file)
        
        size = YMDP::Translator::Yaml::LOCALES.size - 1
        Translate.stub!(:t).with("value", "ENGLISH", anything).exactly(size).and_return("translated value")
        
        @yml.copy
      end
      
      it "should not copy empty keys" do
        File.stub!(:readlines).with("path_en-US.yml").and_return(["KEY=\n"])
        
        @file = mock('file', :puts => true)
        @file.should_not_receive(:puts).with(/key: translated value/)
        
        File.stub!(:open).with(anything, "a").and_yield(@file)
        
        size = YMDP::Translator::Yaml::LOCALES.size - 1
        Translate.stub!(:t).with("value", "ENGLISH", anything).exactly(size).and_return("translated value")
        
        @yml.copy
      end
      
      it "should copy keys with variables" do
        File.stub!(:readlines).with("path_en-US.yml").and_return(["key: value {0}\n"])
        
        @file = mock('file', :puts => true)
        @file.should_receive(:puts).with(/key: translated value {0}/)
        
        File.stub!(:open).with(anything, "a").and_yield(@file)
        
        size = YMDP::Translator::Yaml::LOCALES.size - 1
        
        YMDP::Translator::Yaml::LOCALES.each do |lang, code|
          unless lang == "en-US"
            Dir.should_receive(:[]).with(/app\/assets\/yrb\/#{lang}\/\*\.yml/).and_return(["keys_#{lang}.yml"])
          end
        end
        
        Translate.stub!(:t).with("value [0]", "ENGLISH", anything).exactly(size).and_return("translated value [0]")
        
        @yml.copy
      end
    end
  end
  
  describe "YRB" do
    before(:each) do
      @original_translations = ["application_en-US.pres", "sidebar_en-US.pres"]
      Dir.stub!(:[]).with(/app\/assets\/yrb\/en-US\/\*\.pres/).and_return(@original_translations)
    end
    
    describe "class methods" do
      it "should output a message for each file" do
        File.stub!(:readlines).and_return([""])
        @original_translations.each do |file|
          $stdout.should_receive(:puts).with(/Processing /)
        end
        YMDP::Translator::YRB.translate
      end
      
      it "should instantiate a new template" do
        @original_translations.each do |file|
          @yrb = mock('yrb', :copy => true)
          YMDP::Translator::YRB.should_receive(:new).with(file).and_return(@yrb)
        end
        YMDP::Translator::YRB.translate
      end
      
      it "should copy the new template" do
        @original_translations.each do |file|
          @yrb = mock('yrb', :copy => true)
          @yrb.should_receive(:copy)
          YMDP::Translator::YRB.stub!(:new).with(file).and_return(@yrb)
        end
        YMDP::Translator::YRB.translate
      end
    end
    
    describe "instance methods" do
      before(:each) do
        @path = "path_en-US.pres"
        @yrb = YMDP::Translator::YRB.new(@path)
      end
      
      it "should instantiate" do
        @yrb.should_not be_nil
      end
      
      it "should copy keys" do
        File.stub!(:readlines).with("path_en-US.pres").and_return(["KEY=value\n"])
        
        @file = mock('file', :puts => true)
        @file.should_receive(:puts).with(/KEY=translated value/)
        
        File.stub!(:open).with(anything, "a").and_yield(@file)
        
        size = YMDP::Translator::YRB::LOCALES.size - 1
        
        @template = mock('template', :to_hash => {"key" => "value"})
        YMDP::Compiler::Template::YRB.stub!(:new).and_return(@template)
        
        YMDP::Translator::YRB::LOCALES.each do |lang, code|
          unless lang == "en-US"
            Dir.should_receive(:[]).with(/app\/assets\/yrb\/#{lang}\/\*\.pres/).and_return(["keys_#{lang}.pres"])
          end
        end
        
        Translate.stub!(:t).with("value", "ENGLISH", anything).exactly(size).and_return("translated value")
        
        @yrb.copy
      end
      
      it "should not copy comments" do
        File.stub!(:readlines).with("path_en-US.pres").and_return(["# comment\n"])
        
        @file = mock('file', :puts => true)
        @file.should_not_receive(:puts).with(/KEY=translated value/)
        
        File.stub!(:open).with(anything, "a").and_yield(@file)
        
        size = YMDP::Translator::YRB::LOCALES.size - 1
        Translate.stub!(:t).with("value", "ENGLISH", anything).exactly(size).and_return("translated value")
        
        @yrb.copy
      end
      
      it "should not copy empty keys" do
        File.stub!(:readlines).with("path_en-US.pres").and_return(["KEY=\n"])
        
        @file = mock('file', :puts => true)
        @file.should_not_receive(:puts).with(/KEY=translated value/)
        
        File.stub!(:open).with(anything, "a").and_yield(@file)
        
        size = YMDP::Translator::YRB::LOCALES.size - 1
        Translate.stub!(:t).with("value", "ENGLISH", anything).exactly(size).and_return("translated value")
        
        @yrb.copy
      end
      
      it "should copy keys with variables" do
        File.stub!(:readlines).with("path_en-US.pres").and_return(["KEY=value {0}\n"])
        
        @file = mock('file', :puts => true)
        @file.should_receive(:puts).with(/KEY=translated value {0}/)
        
        File.stub!(:open).with(anything, "a").and_yield(@file)
        
        size = YMDP::Translator::YRB::LOCALES.size - 1
        
        @template = mock('template', :to_hash => {"key" => "value"})
        YMDP::Compiler::Template::YRB.stub!(:new).and_return(@template)
        
        YMDP::Translator::YRB::LOCALES.each do |lang, code|
          unless lang == "en-US"
            Dir.should_receive(:[]).with(/app\/assets\/yrb\/#{lang}\/\*\.pres/).and_return(["keys_#{lang}.pres"])
          end
        end
        
        Translate.stub!(:t).with("value [0]", "ENGLISH", anything).exactly(size).and_return("translated value [0]")
        
        @yrb.copy
      end
    end
  end
  
  describe "Base" do
    describe "class methods" do
      it "should raise error on original_translations" do
        lambda {
          YMDP::Translator::Base.original_translations
        }.should raise_error("Define in child")
      end
    
      it "should raise error on all_source_files" do
        lambda {
          YMDP::Translator::Base.all_source_files
        }.should raise_error("Define in child")
      end
    
      it "should raise error on template" do
        lambda {
          YMDP::Translator::Base.template
        }.should raise_error("Define in child")
      end
    
      it "should raise error on translate" do
        lambda {
          YMDP::Translator::Base.translate
        }.should raise_error("Define in child")
      end
    end
  
    describe "instance methods" do
      it "should raise an error on instantiation" do
        lambda {
          @base = YMDP::Translator::Base.new("path")
        }.should raise_error("Define in child")
      end
    end

    describe "raise in child" do
      before(:each) do
        class YMDPTranslatorBase < YMDP::Translator::Base
          def language(path)
            "en-US"
          end
      
          def base_filename(path)
            path
          end
        end
        @thing = YMDPTranslatorBase.new("path")
      end

      it "should raise an error calling parse_template" do
        lambda {
          @thing.parse_template("path")
        }.should raise_error("Define in child")
      end

      it "should raise an error calling format" do
        lambda {
          @thing.format("a", "b")
        }.should raise_error("Define in child")
      end

      it "should raise an error calling key_and_value_from_line" do
        lambda {
          @thing.key_and_value_from_line("line")
        }.should raise_error("Define in child")
      end

      it "should raise an error calling comment?" do
        lambda {
          @thing.comment?("line")
        }.should raise_error("Define in child")
      end
    end
  end
end
