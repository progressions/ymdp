dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

dir = File.expand_path("#{dir}/ymdp")
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

# load application
#

require 'rubygems'
require 'erb'
require 'set'

require File.expand_path("#{dir}/tag_helper")
require File.expand_path("#{dir}/asset_tag_helper")

Dir["#{dir}/*.rb"].each do |path|
  require File.expand_path(path)
end

["support", "configuration", "compiler"].each do |directory|
  Dir["#{dir}/#{directory}/*.rb"].each do |path|
    require File.expand_path(path)
  end
end
