require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'translator/base'

describe "Translator" do
  it "should set base_path" do
    BASE_PATH.should == "./"
  end
end