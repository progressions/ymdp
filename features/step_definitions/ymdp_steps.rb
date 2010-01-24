Given %r{I load config.yml} do
  # puts File.expand_path ('configuration/constants')
  require 'ymdp/configuration/constants'
end

Then %r{my "([^\"]*)" setting should be "([^\"]*)"} do |key, value|
  YMDP::Base.configuration.send(key).should == value
end

Given %r{I compile the application with the message "([^\"]*)"} do |message|
  @options = {
    :commit => false,
    :branch => "master",
    :base_path => BASE_PATH,
    :servers => SERVERS,
    :message => message
  }
  Object.send(:remove_const, :YMDP_ENV) if defined?(YMDP_ENV)
  YMDP_ENV = "build"
  YMDP::Compiler::Domains.new(@options).compile
end

And %r{I should see "([^\"]*)" in "([^\"]*)"} do |content, path|
  File.read("#{BASE_PATH}/#{path}").should =~ /#{content}/
end

When %r{I deploy the application} do
  
end