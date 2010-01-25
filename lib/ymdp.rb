dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

dir = File.expand_path("#{dir}/ymdp")
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

# load application
#

require 'rubygems'
require 'erb'
require 'set'

require 'base'
require 'validator/validator'
require 'view/tag_helper'
require 'view/asset_tag_helper'
require 'support/file'
require 'configuration/config'
