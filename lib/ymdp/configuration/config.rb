require 'serenity'

module YMDP
  module Configuration
    module Helpers
      def self.included(klass)
        klass.send :extend, ClassMethods
        klass.send :include, InstanceMethods
      end
      
      module ClassMethods
        # Class Methods to handle global stuff like base path and server settings
      
        def self.base_path= base_path
          @@base_path = base_path
        end
      
        def self.base_path
          @@base_path
        end
      
        def self.servers= servers
          @@servers = servers
        end
      
        def self.servers
          @@servers
        end
      end
      
      module InstanceMethods      
        # Instance Methods to access global stuff like base path and server settings
      
        def servers
          send :class_attribute_get, "#@@servers"
        end
      
        def base_path
          @@base_path
        end
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
    
      def options(*args)
        @config.get(base, *args)
      end
      
      def each
        options.each do |name, values|
          yield name, values
        end
      end
      
      def file_not_found(filename)
        puts
        puts "Create #{filename} with the following command:\n\n  ./script/config" 
        puts
  
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