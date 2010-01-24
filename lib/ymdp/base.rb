require 'rubygems'
require 'json'
require 'configuration/config'

module YMDP
  # Defines the global configuration options for all YMDP classes.  This is the class that knows
  # about local settings such as server names, server application_ids, and configuration options such
  # as when compression or validation is required on a view.
  # 
  # == Configuration
  #
  # Set configuration options as a block with the <tt>configure</tt> command.
  #
  #   YMDP::Base.configure do |config|
  #     config.username = "malreynolds"
  #     config.password = "firefly2591"
  #     config.default_server = "staging"
  #     config.host = "host"
  #     config.production_server = "www"
  #     config.growl = true
  #     config.verbose = false
  #     config.compress = @compress
  #     config.validate = @validate
  # 
  #     config.add_path(:base_path, @base_path)
  #     config.servers = @servers
  #   
  #     config.load_content_variables('content')
  #   end
  #
  # These options are still evolving.
  #
  class Base
    def self.configuration
      @@configuration ||= YMDP::Configuration::Setter.new
    end
    
    def content_variables
      configuration.content_variables
    end
    
    def configuration
      @@configuration
    end
    
    # Configures global YMDP settings. Sends a YMDP::Configuration::Setter instance to
    # the block, which is used to define global settings.
    #
    def self.configure
      yield configuration
    end
    
    # Returns the server definition hash as an instance variable, making it available to
    # instances of any class derived from YMDP::Base.
    #
    def servers
      configuration.servers
    end
    
    # Returns the paths definition hash as an instance variable, making it available to 
    # instances of any class derived from YMDP::Base.
    #
    def paths
      configuration.paths
    end
    
    def self.base_path
      configuration.paths[:base_path]
    end
    
    def base_path
      self.class.base_path
    end
    
    # Parses out the <tt>base_path</tt> setting from a path to display it in a
    # less verbose way.
    #
    def self.display_path(path)
      path = File.expand_path(path)
      path.gsub(base_path.to_s, "")
    end
    
    def display_path(path)
      self.class.display_path(path)
    end
  end
end
