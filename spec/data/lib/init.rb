require 'fileutils'
require 'erb'
require 'net/http'
require 'optparse'

Dir["./app/helpers/*.rb"].each do |path|
  require path
end

require 'vendor/gems/environment'
Bundler.require_env

require 'constants'
