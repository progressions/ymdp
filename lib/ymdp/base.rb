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
    # Configures global YMDP settings. Sends a YMDP::Configuration::Setter instance to
    # the block, which is used to define global settings.
    #
    def self.configure
      setter = YMDP::Configuration::Setter.new
      
      yield setter
      
      @@paths = setter.paths
      @@servers = setter.servers
      
      setter.instance_variables.each do |key|
        unless ["@servers", "@paths"].include?(key)
          value = setter.instance_variable_get(key)
          create_accessor(key, value)
        end
      end
      
      create_accessors_from_content_variables(setter.content_variables)
    end
    
    # Returns the server definition hash as a class variable, making it available to
    # any class derived from YMDP::Base.
    #
    def self.servers
      @@servers
    end
    
    # Returns the paths definition hash as a class variable, making it available to
    # any class derived from YMDP::Base.
    #   
    def self.paths
      @@paths
    end
    
    # Returns the server definition hash as an instance variable, making it available to
    # instances of any class derived from YMDP::Base.
    #
    def servers
      self.class.servers
    end
    
    # Returns the paths definition hash as an instance variable, making it available to 
    # instances of any class derived from YMDP::Base.
    #
    def paths
      self.class.paths
    end
    
    def self.base_path
      paths[:base_path]
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
    
    
    private
    
    # This probably isn't actually a good place to have this, because
    # the 'content variables' are only intended to be relevant inside
    # of a view template.
    #
    def self.create_accessors_from_content_variables(content_variables)
      content_variables.each do |key, value|
        create_accessor(key, value)
      end
    end
    
    # Creates class- and instance-level accessors for the key and value.
    #
    def self.create_accessor(key, value)
      if key
        value_str = "\"#{value}\""
      
        key = key.to_s.gsub("@", "")
      
        class_eval %(
          class << self
            attr_accessor :#{key}
          end
        )
        self.send("#{key}=".to_sym, value)
      
        eval %(
          def #{key}
            #{self}.#{key}
          end
        )
      end
    end 
  end
end

