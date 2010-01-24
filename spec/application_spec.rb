require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'application'

describe Application do
  describe "set current view" do
    it "should set current view" do
      Application.current_view = "staging"
      Application.current_view.should == "staging"
    end
  end
  
  describe "current_view?" do
    it "should be true" do
      Application.current_view = "staging"
      Application.current_view?("staging")
    end
    
    it "should be false" do
      Application.current_view = "staging"
      Application.current_view?("funk")
    end
  end
  
  describe "return current view" do
    it "should return current view" do
      Application.current_view = "staging"
      Application.current_view.should == "staging"
    end
  end
end