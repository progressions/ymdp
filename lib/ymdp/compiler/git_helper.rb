require 'grit'
include Grit

class GitHelper
  def get_hash(branch)
    branch = get_current_branch || "master"
    repo = Repo.new("#{BASE_PATH}/.")
    repo.commits(branch).first.id
  end

  def get_current_branch
    result = `git status`
    if result =~ /# On branch (.*)/
      return $1
    end
  end

  def do_commit(message)
    repo = Repo.new(".")
    repo.add(".")
    puts `git commit -am "#{message}"`
  end
end