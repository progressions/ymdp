dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

dir = File.expand_path("#{dir}/ymdp")
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

# load application
#

require 'rubygems'
require 'haml'
require 'erb'
require 'set'

require 'ymdp/base'
require 'view/tag_helper'
require 'view/asset_tag_helper'
require 'f'
require 'configuration/config'
