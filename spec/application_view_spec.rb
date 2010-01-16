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
  end
end