require 'support/file'
require 'grit'
include Grit

module YMDP
  class GitHelper
    def get_hash(branch)
      branch = get_current_branch || "master"
      repo = Repo.new("#{BASE_PATH}/.")
      repo.commits(branch).first.id
    end

    def get_current_branch
      result = F.execute("git status", :return => true)
      if result =~ /# On branch (.*)/
        return $1
      end
    end

    def do_commit(message)
      repo = Repo.new(".")
      repo.add(".")
      $stdout.puts F.execute("git commit -am \"#{message}\"", :return => true)
    end
  end
end