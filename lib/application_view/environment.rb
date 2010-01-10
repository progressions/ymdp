require 'fileutils'
require 'erb'
require 'net/http'
require 'optparse'

require 'vendor/gems/environment'
Bundler.require_env

require 'constants'

# load application
#
Dir["#{APPLICATION_PATH}/*.rb"].each do |path|
  require path
end

# load support
#
Dir["#{APPLICATION_PATH}/support/*.rb"].each do |path|
  require path
end

# load everything in the lib directory
#
Dir["#{BASE_PATH}/lib/**/*.rb"].each do |path|
  require path unless path == File.expand_path(__FILE__)
end

require "#{APPLICATION_PATH}/support/file"
