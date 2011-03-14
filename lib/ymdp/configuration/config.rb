require 'serenity'
require 'yaml'

module YMDP
  module Configuration #:nodoc:
    # Provides an interface to set global configuration variables inside a block.
    #
    # Used by the YMDP::Base <tt>configure</tt> method.
    #
    # == Examples
    #
    # In the following example, the <tt>config</tt> variable inside the block is an
    # instance of YMDP::Configuration::Setter.
    #
    #   YMDP::Base.configure do |config|
    #     config.username = 'malreynolds'
    #     config.load_content_variables('content')
    #   end
    #
    # It is then up to YMDP::Base.configure to take the Setter instance and set all the 
    # appropriate options based on its settings.
    #
    class Setter
      # String value containing the login used to communicate with the Yahoo! Mail Development
      # Platform to deploy the application.
      attr_accessor :username
      
      # String value containing the password used to communicate with the Yahoo! Mail Development
      # Platform to deploy the application.
      attr_accessor :password
      
      # String value containing the default_server name. Matches the related entry in the 
      # <tt>servers</tt> hash to define which server is the default for rake tasks such as 
      # <tt>deploy</tt>.
      attr_accessor :default_server
      
      # Host name for the website backend of this application.
      attr_accessor :host
      
      # Boolean value which sets whether Growl notifications should be used when compiling 
      # and deploying the application.
      attr_accessor :growl
      
      # Hash value containing settings which tell the application when to compress CSS and JavaScript.
      attr_accessor :compress
      
      # Hash value containing settings which tell the application when to validate HTML and JavaScript.
      attr_accessor :validate
      
      # Boolean value which sets whether to output verbose messages or not.
      attr_accessor :verbose
      
      # Hash value containing content variables which are made available to the views at build time.
      attr_accessor :content_variables
      
      # Hash value containing application data about the servers, such as their asset and application IDs.
      attr_accessor :servers
      
      # Hash value containing paths used by the application to locate its files. This can be used to
      # overwrite default settings.
      attr_accessor :paths
      
      # Configuration options for JSLint JavaScript validator. Should be maintained in
      # <tt>jslint_settings.yml</tt>.
      #
      attr_accessor :jslint_settings
      
      attr_accessor :external_assets
      
      attr_accessor :test_javascripts
      
      def initialize #:nodoc:
        @paths = {}
        @content_variables = {}
      end
      
      # Adds an entry to the <tt>paths</tt> hash. 
      #
      def add_path(name, value)
        @paths[name] = value
      end
      
      # Adds an entry to the <tt>content_variables</tt> hash.
      #
      def add_content_variable(name, value)
        @content_variables[name] = value
      end
      
      # Loads the <tt>content_variables</tt> hash from a Yaml file.
      #
      def load_content_variables(filename)
        path = "#{CONFIG_PATH}/#{filename}".gsub(/\.yml$/, "")
        path = "#{path}.yml"
        @content_variables = YAML.load_file(path)
      end
    end
    
    class Base
      attr_accessor :base
      
      def initialize(filename, base)
        if File.exists?(filename)
          @config = Serenity::Configuration.new(filename)
          @base = base
        else
          file_not_found(filename)
        end
      end
    
      def [](key)
        @config.get(base, key)
      end
      
      def exists?(*args)
        @config.exists?(base, *args)
      end
    
      def options(*args)
        @config.get(base, *args)
      end
      
      def each
        options.each do |name, values|
          yield name, values
        end
      end
      
      def file_not_found(filename)
        $stdout.puts
        $stdout.puts "Create #{filename} with the following command:\n\n  ./script/config" 
        $stdout.puts
  
        raise "File not found: #{filename}"
      end      
    end
    
    class Servers < Base
      def initialize
        super("#{CONFIG_PATH}/servers.yml", "servers")
      end
      
      def servers
        options
      end
    end
    
    class Config < Base
      def initialize
        super("#{CONFIG_PATH}/config.yml", "config")
      end
      
      def username
        options("username")
      end
      
      def password
        options("password")
      end
      
      def test_javascripts?
        options("test_javascripts", YMDP_ENV)
      end
      
      def compress_embedded_js?
        options("compress", "embedded_js")
      end
    
      def compress_js_assets?
        options("compress", "js_assets")
      end
    
      def compress_css?
        options("compress", "css")
      end
    
      def validate_embedded_js?
        options("validate", "embedded_js", YMDP_ENV)
      end
    
      def validate_js_assets?
        options("validate", "js_assets", YMDP_ENV)
      end
    
      def validate_json_assets?
        options("validate", "json_assets", YMDP_ENV)
      end
    
      def validate_html?
        options("validate", "html", YMDP_ENV)
      end
    
      def obfuscate?
        options("compress", "obfuscate")
      end
    
      def verbose?
        options("verbose")
      end
    
      def growl?
        options("growl")
      end
    end
  end
end