dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

dir = File.expand_path("#{dir}/application_view")
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

# load application
#

require File.expand_path("#{dir}/tag_helper")
require File.expand_path("#{dir}/asset_tag_helper")

Dir["#{dir}/*.rb"].each do |path|
  require File.expand_path(path)
end

# load support
#
Dir["#{dir}/support/*.rb"].each do |path|
  require File.expand_path(path)
end
