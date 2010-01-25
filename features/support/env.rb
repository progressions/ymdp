require 'vendor/gems/environment'
Bundler.require_env :cucumber

require 'spec/expectations'
require 'spec/mocks'
  
require 'lib/ymdp'
require 'compiler/domains'

require 'spec/stubs'

Before do
  unless defined?(BASE_PATH)
    BASE_PATH = File.expand_path("./features/data")
    APPLICATION_PATH = File.expand_path("./features/data/app")
    CONFIG_PATH = File.expand_path("./features/data/config")
    SERVERS_PATH = File.expand_path("./features/data/servers")
    TMP_PATH = File.expand_path("./features/data/tmp")
  end
  
  @exception = nil
  @files = []

  $rspec_mocks ||= Spec::Mocks::Space.new  
  
  stub_growl
  
  @git_helper = 'git_helper'
  @git_helper.stub(:commit).as_null_object
  YMDP::GitHelper.stub!(:new).and_return(@git_helper)
  
  @ymdt = "ymdt"
  YMDT::Base.stub!(:new).and_return(@ymdt)
end

After do
  @files.each do |file|
    system "rm #{file}"
  end
end
