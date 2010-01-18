require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'compiler/git_helper'

describe "GitHelper" do
  before(:each) do
    stub_screen_io
    
    @repo = mock('repo')
    Repo.stub!(:new).and_return(@repo)
    
    F.stub!(:execute).with("git status", :return => true).and_return("# On branch git-helper")
    @commit = mock('commit', :id => "abcdefg")
    @commits = mock('commits', :first => @commit)
    @repo.stub!(:commits).with("git-helper").and_return(@commits)
    
    @git = YMDP::GitHelper.new
  end
  
  it "should instantiate" do
    @git.should_not be_nil
  end
  
  it "should get hash" do
    @git.get_hash("branch").should == "abcdefg"
  end
  
  it "should get current branch" do
    @git.get_current_branch.should == "git-helper"
  end
  
  describe "commit" do
    before(:each) do
      @repo.stub!(:add)
      F.stub!(:execute).with(/git commit/, :return => true).and_return("Committed")
    end
    
    it "should add current directory" do
      @repo.should_receive(:add).with(".")
      @git.do_commit("message")
    end
    
    it "should commit with message" do
      F.should_receive(:execute).with("git commit -am \"message\"", :return => true).and_return("Committed")
      @git.do_commit("message")
    end
    
    it "should output results" do
      $stdout.should_receive(:puts).with("Committed")
      @git.do_commit("message")
    end
  end
end
