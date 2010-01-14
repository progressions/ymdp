$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

BASE_PATH = File.dirname(__FILE__) + "/data"
CONFIG_PATH = "#{BASE_PATH}/config"
SERVERS_PATH = "#{BASE_PATH}/servers"
TMP_PATH = "#{BASE_PATH}/tmp"

require 'ymdp'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
end
