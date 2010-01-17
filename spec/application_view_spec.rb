require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ApplicationView" do
  before(:each) do
    @assets_directory = "/om/assets/abcdefg_1"
    @view = YMDP::View.new(@assets_directory)
    stub_io
  end
  
  describe "languages" do
    it "should return supported languages" do
      Dir.stub!(:[]).and_return(["yrb/en-US", "yrb/de-DE", "yrb/es-ES"])
      @view.supported_languages.should == ["en-US", "de-DE", "es-ES"]
    end
    
    it "should raise an error if en-US doesn't exist" do
      Dir.stub!(:[]).and_return(["yrb/de-DE", "yrb/es-ES"])
      lambda {
        @view.supported_languages
      }.should raise_error("Default YRB key en-US not found")
    end
    
    it "should return english languages" do
      Dir.stub!(:[]).and_return(["yrb/en-US", "yrb/de-DE", "yrb/es-ES", "en-SG"])
      @view.english_languages.should == ["en-US", "en-SG"]
    end
  end
    
  describe "javascript_include" do
    describe "local JavaScript" do
      it "should include local JavaScript asset" do
        filename = "application.js"
        @view.javascript_include(filename).should == "<script src='#{@assets_directory}/javascripts/#{filename}' type='text/javascript' charset='utf-8'></script>"
      end
    
      it "should append .js to local JavaScript filename" do
        pending
        filename = "application"
        @view.javascript_include(filename).should == "<script src='#{@assets_directory}/javascripts/#{filename}.js' type='text/javascript' charset='utf-8'></script>"
      end
    end
    
    describe "external JavaScript" do
      it "should include external JavaScript assets" do
        filename = "http://www.site.com/application.js"
        @view.javascript_include(filename).should == "<script src='#{filename}' type='text/javascript' charset='utf-8'></script>"
      end
    
      it "should append .js to external JavaScript filename" do
        pending
        filename = "http://www.site.com/application"
        @view.javascript_include(filename).should == "<script src='#{filename}.js' type='text/javascript' charset='utf-8'></script>"
      end
    end
    
    it "should include firebug lite" do
      @view.include_firebug_lite.should == "<script src='http://getfirebug.com/releases/lite/1.2/firebug-lite-compressed.js' type='text/javascript' charset='utf-8'></script>"
    end
  end
  
  describe "render" do
    before(:each) do
      @processed_template = "processed template"
    end
    
    describe ":partial" do
      describe "single" do
        describe "Haml" do
          it "should render a partial if a Haml file exists in app/views" do
            File.stub!(:exists?).with(/app\/views\/_application.html.haml$/).and_return(true)
            @view.stub!(:process_haml).and_return(@processed_template)
            @view.render(:partial => 'application').should == @processed_template
          end
    
          it "should render a partial if a Haml file exists in app/views/shared" do
            File.stub!(:exists?).with(/app\/views\/shared\/_application.html.haml$/).and_return(true)
            @view.stub!(:process_haml).and_return(@processed_template)
            @view.render(:partial => 'application').should == @processed_template
          end
        end
        
        describe "HTML" do
          it "should render a partial if an HTML file exists in app/views" do
            File.stub!(:exists?).with(/app\/views\/_application.html$/).and_return(true)
            @view.stub!(:process_template).and_return(@processed_template)
            @view.render(:partial => 'application').should == @processed_template
          end
    
          it "should render a partial if an HTML file exists in app/views/shared" do
            File.stub!(:exists?).with(/app\/views\/shared\/_application.html$/).and_return(true)
            @view.stub!(:process_template).and_return(@processed_template)
            @view.render(:partial => 'application').should == @processed_template
          end
        end
    
        describe "ERB" do
          it "should render a partial if an ERB file exists in app/views" do
            File.stub!(:exists?).with(/app\/views\/_application.html.erb$/).and_return(true)
            @view.stub!(:process_template).and_return(@processed_template)
            @view.render(:partial => 'application').should == @processed_template
          end
    
          it "should render a partial if an ERB file exists in app/views/shared" do
            File.stub!(:exists?).with(/app\/views\/shared\/_application.html.erb$/).and_return(true)
            @view.stub!(:process_template).and_return(@processed_template)
            @view.render(:partial => 'application').should == @processed_template
          end
        end
      end

      describe "multiple" do
        describe "Haml" do
          it "should render multiple partials" do
            File.stub!(:exists?).with(/app\/views\/_application.html.haml$/).and_return(true)
            File.stub!(:exists?).with(/app\/views\/_sidebar.html.haml$/).and_return(true)
            
            @application_haml = "application haml"
            @sidebar_haml = "sidebar haml"
            
            @application_file = mock('file', :read => @application_haml)
            @sidebar_file = mock('file', :read => @sidebar_haml)
            
            File.stub!(:open).with(/_application.html.haml$/, anything).and_yield(@application_file)
            File.stub!(:open).with(/_sidebar.html.haml$/, anything).and_yield(@sidebar_file)
            
            @view.stub!(:process_haml).and_return("application", "sidebar")
            
            @view.render(:partial => ['application', 'sidebar']).should == "application\nsidebar"
          end
        end
        
        describe "ERB" do
          it "should render multiple partials" do
            File.stub!(:exists?).with(/app\/views\/_application.html.erb$/).and_return(true)
            File.stub!(:exists?).with(/app\/views\/_sidebar.html.erb$/).and_return(true)
            
            @application_template = "application erb"
            @sidebar_template = "sidebar erb"
            
            @application_file = mock('file', :read => @application_template)
            @sidebar_file = mock('file', :read => @sidebar_template)
            
            File.stub!(:open).with(/_application.html.erb$/, anything).and_yield(@application_file)
            File.stub!(:open).with(/_sidebar.html.erb$/, anything).and_yield(@sidebar_file)
            
            @view.stub!(:process_template).and_return("application", "sidebar")
            
            @view.render(:partial => ['application', 'sidebar']).should == "application\nsidebar"
          end
        end
        
        describe "HTML" do
          it "should render multiple partials" do
            File.stub!(:exists?).with(/app\/views\/_application.html$/).and_return(true)
            File.stub!(:exists?).with(/app\/views\/_sidebar.html$/).and_return(true)
            
            @application_template = "application html"
            @sidebar_template = "sidebar html"
            
            @application_file = mock('file', :read => @application_template)
            @sidebar_file = mock('file', :read => @sidebar_template)
            
            File.stub!(:open).with(/_application.html$/, anything).and_yield(@application_file)
            File.stub!(:open).with(/_sidebar.html$/, anything).and_yield(@sidebar_file)
            
            @view.stub!(:process_template).and_return("application", "sidebar")
            
            @view.render(:partial => ['application', 'sidebar']).should == "application\nsidebar"
          end
        end
      end
      
      it "should raise an error if partial can't be found" do
        File.stub!(:exists?).and_return(false)
        lambda {
          @view.render(:partial => 'application')
        }.should raise_error("Could not find partial: application")
      end
    end
    
    describe ":javascript" do
      before(:each) do
        
        @config = mock('config', :compress_embedded_js? => false, :validate_embedded_js? => false)
        reset_constant(:CONFIG, @config)
    
        @compressed_template = "compressed template"
        @processed_script = "<script type='text/javascript'>\n#{@processed_template}\n</script>"
        @compressed_script = "<script type='text/javascript'>\n#{@compressed_template}\n</script>"
        YMDP::Compressor::JavaScript.stub!(:compress).and_return(@compressed_template)
        YMDP::Validator::JavaScript.stub!(:validate)
      end
      
      describe "single" do
        before(:each) do
          File.stub!(:exists?).and_return(true)
          @view.stub(:process_template).and_return(@processed_template)
        end
        
        it "should render a compressed partial" do
          @config.stub!(:compress_embedded_js?).and_return(true)
          @view.render(:javascript => 'application').should == @compressed_script
        end
        
        it "should render an uncompressed partial" do
          @config.stub!(:compress_embedded_js?).and_return(false)
          @view.render(:javascript => 'application').should == @processed_script
        end
        
        it "should render compressed without tags" do
          @config.stub!(:compress_embedded_js?).and_return(true)
          @view.render(:javascript => 'application', :tags => false).should == @compressed_template
        end
        
        it "should render uncompressed without tags" do
          @config.stub!(:compress_embedded_js?).and_return(false)
          @view.render(:javascript => 'application', :tags => false).should == @processed_template
        end
        
        it "should validate with config true" do
          @config.stub!(:validate_embedded_js?).and_return(true)
          F.should_receive(:save_to_tmp_file).with(anything, "./tmp/application.js").and_return(true)
          YMDP::Validator::JavaScript.should_receive(:validate)
          @view.render(:javascript => 'application')
        end
        
        it "should not validate with config false" do
          @config.stub!(:validate_embedded_js?).and_return(true)
          F.should_receive(:save_to_tmp_file).with(anything, "./tmp/application.js").and_return(false)
          YMDP::Validator::JavaScript.should_not_receive(:validate)
          @view.render(:javascript => 'application')
        end
        
        it "should not validate if file exists and config true" do
          @config.stub!(:validate_embedded_js?).and_return(false)
          F.should_receive(:save_to_tmp_file).with(anything, "./tmp/application.js").and_return(true)
          YMDP::Validator::JavaScript.should_not_receive(:validate)
          @view.render(:javascript => 'application')
        end
        
        it "should not validate if file exists and config false" do
          @config.stub!(:validate_embedded_js?).and_return(false)
          F.should_receive(:save_to_tmp_file).with(anything, "./tmp/application.js").and_return(true)
          YMDP::Validator::JavaScript.should_not_receive(:validate)
          @view.render(:javascript => 'application')
        end
      end

      describe "multiple" do
        before(:each) do
          File.stub!(:exists?).with(/app\/javascripts\/application.js$/).and_return(true)
          File.stub!(:exists?).with(/app\/javascripts\/sidebar.js$/).and_return(true)
          
          @application_template = "application js"
          @sidebar_template = "sidebar js"
          
          @application_file = mock('file', :read => @application_template)
          @sidebar_file = mock('file', :read => @sidebar_template)
          
          File.stub!(:open).with(/application.js$/, anything).and_yield(@application_file)
          File.stub!(:open).with(/sidebar.js$/, anything).and_yield(@sidebar_file)
          
          @view.stub!(:process_template).and_return("application", "sidebar")
        end
        
        it "should render multiple partials" do
          @view.render(:javascript => ['application', 'sidebar']).should == "<script type='text/javascript'>\napplication\nsidebar\n</script>"
        end
        
        it "should render multiple partials without tags" do
          @view.render(:javascript => ['application', 'sidebar'], :tags => false).should == "application\nsidebar"
        end
        
        it "should render multiple partials to a filename" do
          F.should_receive(:save_to_tmp_file).with(anything, "./tmp/javascripts.js")
          @view.render(:javascript => ['application', 'sidebar'], :filename => 'javascripts')
        end
      end
      
      it "should not raise an error if partial can't be found" do
        File.stub!(:exists?).and_return(false)
        lambda {
          @view.render(:javascript => 'application')
        }.should_not raise_error
      end
      
      it "should return blank string if partial can't be found" do
        File.stub!(:exists?).and_return(false)
        lambda {
          @view.render(:javascript => 'application').should == ""
        }.should_not raise_error
      end
    end
    
    describe ":stylesheet" do
      before(:each) do
        @config = mock('config', :compress_css? => false)
        reset_constant(:CONFIG, @config)
    
        @compressed_template = "compressed template"
        @processed_script = "<style type='text/css'>\n#{@processed_template}\n</style>"
        @compressed_script = "<style type='text/css'>\n#{@compressed_template}\n</style>"
        YMDP::Compressor::Stylesheet.stub!(:compress).and_return(@compressed_template)
        YMDP::Validator::Stylesheet.stub!(:validate).and_return(true)
      end
      
      describe "single" do
        before(:each) do
          File.stub!(:exists?).and_return(true)
          @view.stub(:process_template).and_return(@processed_template)
        end
        
        it "should render a compressed partial" do
          @config.stub!(:compress_css?).and_return(true)
          @view.render(:stylesheet => 'application').should == @compressed_script
        end
        
        it "should render an uncompressed partial" do
          @config.stub!(:compress_css?).and_return(false)
          @view.render(:stylesheet => 'application').should == @processed_script
        end
        
        it "should render compressed without tags" do
          @config.stub!(:compress_css?).and_return(true)
          @view.render(:stylesheet => 'application', :tags => false).should == @compressed_template
        end
        
        it "should render uncompressed without tags" do
          @config.stub!(:compress_css?).and_return(false)
          @view.render(:stylesheet => 'application', :tags => false).should == @processed_template
        end
      end

      describe "multiple" do
        before(:each) do
          File.stub!(:exists?).with(/app\/stylesheets\/application.css$/).and_return(true)
          File.stub!(:exists?).with(/app\/stylesheets\/sidebar.css$/).and_return(true)
          
          @application_template = "application css"
          @sidebar_template = "sidebar css"
          
          @application_file = mock('file', :read => @application_template)
          @sidebar_file = mock('file', :read => @sidebar_template)
          
          File.stub!(:open).with(/application.css$/, anything).and_yield(@application_file)
          File.stub!(:open).with(/sidebar.css$/, anything).and_yield(@sidebar_file)
          
          @view.stub!(:process_template).and_return("application", "sidebar")
        end
        
        it "should render multiple partials" do
          @view.render(:stylesheet => ['application', 'sidebar']).should == "<style type='text/css'>\napplication\nsidebar\n</style>"
        end
        
        it "should render multiple partials without tags" do
          @view.render(:stylesheet => ['application', 'sidebar'], :tags => false).should == "application\nsidebar"
        end
        
        it "should render multiple partials to a filename" do
          F.should_receive(:save_to_tmp_file).with(anything, "./tmp/stylesheets.css")
          @view.render(:stylesheet => ['application', 'sidebar'], :filename => 'stylesheets')
        end
      end
      
      it "should not raise an error if partial can't be found" do
        File.stub!(:exists?).and_return(false)
        lambda {
          @view.render(:stylesheet => 'application')
        }.should_not raise_error
      end
      
      it "should return blank string if partial can't be found" do
        File.stub!(:exists?).and_return(false)
        lambda {
          @view.render(:stylesheet => 'application').should == ""
        }.should_not raise_error
      end
    end

  end
end