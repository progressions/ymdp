module YMDP
  module Compiler
    # Command-line options processor for Compiler module.
    #
    class Options
      # Parse command line options into an options hash.
      #
      def self.parse
        options = {
          :commit => false,
          :branch => "master",
          :base_path => BASE_PATH,
          :servers => SERVERS
        }
        OptionParser.new do |opts|
          options[:commit] = false
          options[:verbose] = CONFIG.verbose?
          opts.banner = "Usage: build.rb [options]"

          opts.on("-d", "--domain [domain]", "Force Domain") do |v|
            options[:domain] = v
          end
          opts.on("-b", "--branch [branch]", "Current Branch") do |v|
            options[:branch] = v
          end
          opts.on("-m", "--message [message]", "Commit Message") do |v|
            options[:commit] = true
            options[:message] = v
          end
          opts.on("-n", "--no-commit", "Don't Commit") do |v|
            options[:commit] = false
          end
          opts.on("-v", "--verbose", "Verbose (show all file writes)") do |v|
            options[:verbose] = true
          end
          opts.on("-r", "--rake [task]", "Execute Rake task") do |v|
            options[:rake] = v
          end
          opts.on("-c", "--compress", "Compress JavaScript and CSS") do |v|
            options[:compress] = v
          end
        end.parse!
    
        options
      end    
    end
  end
end