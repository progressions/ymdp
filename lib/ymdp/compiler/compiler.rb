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
          :branch => "master"
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
  
    # Covers all the domains and the actions that are taken on all domains at once.
    #
    class Domains
      attr_accessor :git, :git_hash, :message, :domains, :options
  
      def initialize(options=nil)
        @options = options || Compiler::Options.parse
        @domains = @options[:domain] || all_domains
        @domains = @domains.to_a
        @message = @options[:message]

        commit
      end
  
      # Returns all domains.
      #
      def all_domains
        SERVERS.servers.keys
      end
  
      # Commit to git and store the hash of the commit.
      #
      def commit
        @git = GitHelper.new
        if options[:commit]
          git.do_commit(@message)
        end
        @git_hash = git.get_hash(options[:branch])    
      end
  
      # Compile the source code for all domains into their usable destination files.
      #
      def compile
        Timer.new(:title => "YMDP").time do
          clean_tmp_dir do
            process_domains
          end
        end
      rescue StandardError => e
        puts e.message
        puts e.backtrace
      end
  
      # Process source code for each domain in turn.
      #
      def process_domains
        domains.each do |domain|
          compiler = Compiler::Base.new(domain, git_hash, options)
          
          compiler.clean_domain
  
          ["views", "assets"].each do |dir|
            compiler.process("#{BASE_PATH}/app/#{dir}/")
          end
        end
    
        if options[:rake]
          system "rake #{options[:rake]}"
        end
      end
  
      # Perform a block, starting with a clean 'tmp' directory and ending with one.
      #
      def clean_tmp_dir
        system "rm -rf #{TMP_DIR}"
        system "mkdir #{TMP_DIR}"
        yield
        system "rm -rf #{TMP_DIR}"
        system "mkdir #{TMP_DIR}"
      end
    end

    # Compiles the source code for an individual domain.
    #
    # Usage:
    #
    #   @compiler = Compiler::Base.new('staging', 'asdfh23rh2fas')
    #
    # You can then compile the domain:
    #
    #   @compiler.build
    #
    class Base
      attr_accessor :domain, :git_hash, :options
  
      # A TemplateCompiler instance covers a single domain, handling all the processing necessary to 
      # convert the application source code into usable destination files ready for upload.
      #
      def initialize(domain, git_hash, options)
        @domain = domain
        @git_hash = git_hash
        @options = options
      end

      # Do all the processing necessary to convert the application source code into usable destination files ready for upload to the server:
      #
      # - create server directory if necessary,
      # - for each file in the source path, build the file, and
      # - copy the images from the source to the destination directory.
      #
      def process(path)
        puts "Processing #{path} for #{domain}"
        create_directory("servers/#{domain}")
        process_all_files(path)
        process_all_translations
        copy_images
      end
  
      # Process all code files (HTML and JavaScript) into usable, complete HTML files.
      #
      def process_all_files(path)
        Dir["#{path}**/*"].each do |f|
          build_file(f)
        end    
      end
  
      # Build this file if it's either:
      #   - a view, but not a partial or layout, or
      #   - a JavaScript file.
      #
      def build_file(file)
        params = {
          :file => file, :domain => domain, :git_hash => git_hash, :message => options[:message], :verbose => options[:verbose]
        }
        if build?(file)
          if file =~ /(\.haml|\.erb)$/
            YMDP::Template::View.new(params).build
          elsif file =~ /\.js$/
            YMDP::Template::JavaScript.new(params).build
          end
        end
      end
  
      # Convert all YRB translation files from YRB ".pres" format into a single JSON file per language.
      #
      def process_all_translations
        puts "Processing ./app/assets/yrb/ for #{domain}"
        YMDP::Base.supported_languages.each do |lang|
          process_each_yrb(lang)
        end
      end
  
      # Convert the YRB translation files of a single language for this domain into a single JSON file.
      #
      def process_each_yrb(lang)
        tmp_file = "#{TMP_DIR}/keys_#{lang}.pres"
    
        # Concatenate together all the YRB ".pres" files for this language into one file in the tmp dir.
        #
        Dir["#{BASE_PATH}/app/assets/yrb/#{lang}/*"].each do |path|
          system "cat #{path} >> #{tmp_file}"
        end
    
        yrb = YMDP::Template::YRB.new(:file => tmp_file, :domain => domain)
        yrb.build
        yrb.validate if CONFIG.validate_json_assets?
        system "rm #{tmp_file}"
      end
  
      # Creates a fresh destination directory structure for the code to be compiled into.
      #
      def clean_domain
        dir = "#{YMDP_ROOT}/servers/#{domain}"
        system "rm -rf #{dir}/views"
        system "rm -rf #{dir}/assets/javascripts"
        system "rm -rf #{dir}/assets/stylesheets"
        system "rm -rf #{dir}/assets/yrb"
        system "rm -rf #{TMP_DIR}/"
        system "mkdir #{TMP_DIR}"
      end

      # Format text in a standard way for output to the screen.
      #
      def log(text)
        "#{Time.now.to_s} #{text}"
      end
  
      # If this directory doesn't exist, create it and print that it's being created.
      #
      def create_directory(path)
        dest = destination(path)
    
        unless File.exists?("#{BASE_PATH}/#{path}")
          puts "     create #{path}"
          FileUtils.mkdir_p "#{BASE_PATH}/#{path}"
        end
      end
  
      # Convert a file's path from its source to its destination.
      #
      # The source directory is in the 'app' directory.
      #
      # The destination directory is made from the 'servers' root and the domain name.
      #
      # For example: 
      #   - ./servers/staging
      #   - ./servers/alpha
      #
      def destination(path)
        destination = path.dup
        destination.gsub!("#{YMDP_ROOT}/app", "#{YMDP_ROOT}/servers/#{domain}")
      end
  
      # Images don't require any processing, just copy them over into this domain's assets directory.
      #
      def copy_images
        if options[:verbose]
          puts log("Moving images into #{YMDP_ROOT}/servers/#{domain}/assets/images...")
        end
        system "rm -rf #{YMDP_ROOT}/servers/#{domain}/assets/images"
        system "cp -r #{YMDP_ROOT}/app/assets/images #{YMDP_ROOT}/servers/#{domain}/assets"
      end
  
      # A filename beginning with an underscore is a partial.
      #
      def partial?(file)
        file.split("/").last =~ /^_/
      end
  
      # A file in the layouts directory is a layout.
      #
      def layout?(file)
        file =~ /\/app\/views\/layouts\//
      end
  
      # Build if it's not a partial and not a layout.
      #
      def build?(file)
        !partial?(file) && !layout?(file)
      end
    end
  end
end