require 'rubygems'
require './lib/ymdp/configuration/config'

class Thing
  include YMDP::Configuration::Helpers

  def self.configure
    setter = YMDP::Configuration::Setter.new
    
    yield setter
    
    @@paths = setter.paths
    @@servers = setter.servers
    
    setter.content_variables.each do |key, value|
      class_eval %(
        class << self
          attr_accessor :#{key}
        end
          
        self.#{key} = "#{value}"
      )
      
      eval %(
        def #{key}
          self.class.#{key}
        end
      )
    end
  end
end



Thing.configure do |config|
  config.add_content_variable :hello, "what"
  config.add_content_variable :yer_mom, "yeah"
end

t = Thing.new

puts Thing.hello
puts t.hello

puts Thing.yer_mom
puts t.yer_mom
