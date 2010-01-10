# load application
#
Dir["lib/application_view/*.rb"].each do |path|
  require path
end

# load support
#
Dir["lib/application_view/support/*.rb"].each do |path|
  require path
end

# load everything in the lib directory
#
Dir["lib/**/*.rb"].each do |path|
  require path unless path == File.expand_path(__FILE__)
end
