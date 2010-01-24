require 'compiler/git_helper'
require 'compiler/base'
require 'compiler/template'

# Covers all the domains and the actions that are taken on all domains at once.
#
# Usage:
#
# YMDP::Compiler::Domains.new(:message => "Commit message").compile
#
# Options are provided by command-line parsing from YMDP::Compiler::Options.
#
module YMDP
  module Compiler
    # Covers all the domains and the actions that are taken on all domains at once.
    #
    class Domains < YMDP::Base
      attr_accessor :git, :git_hash, :message, :domains, :options
  
      def initialize(options=nil)
        @options = options
        @servers = @options[:servers]
        @domains = @options[:domain] || all_domains
        @domains = @domains.to_a
        @message = @options[:message]

        commit if @options[:commit]
      end
        
      # Compile the source code for all domains into their usable destination files.
      #
      def compile
        Timer.new(:title => "YMDP").time do
          clean_tmp_dir do
            process_domains
          end
        end
      end
  
      # Returns all domains.
      #
      def all_domains
        servers.servers.keys
      end
  
      # Commit to git and store the hash of the commit.
      #
      def commit
        @git = YMDP::GitHelper.new
        @git.do_commit(@message)
        @git_hash = git.get_hash(options[:branch])    
      end
  
      # Process source code for each domain in turn.
      #
      def process_domains
        domains.each do |domain|
          params = options
          params[:host] = configuration.host
          params[:server] = servers[domain]["server"]
          compiler = YMDP::Compiler::Base.new(domain, git_hash, params)
          
          compiler.process_all
        end
      end
  
      # Perform a block, starting with a clean 'tmp' directory and ending with one.
      #
      def clean_tmp_dir
        system "rm -rf #{TMP_PATH}"
        system "mkdir #{TMP_PATH}"
        yield
        system "rm -rf #{TMP_PATH}"
        system "mkdir #{TMP_PATH}"
      end
    end
  end
end