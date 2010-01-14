$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'ymdp'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  BASE_PATH = "./"
  SERVERS_PATH = "#{BASE_PATH}/servers"
  TMP_PATH = "#{BASE_PATH}/tmp"
end
