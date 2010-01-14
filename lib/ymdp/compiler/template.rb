module YMDP
  module Template
    # Compiles a single file in a single domain, processing its Haml or ERB and turning
    # it into usable destination files in the 'servers' directory.
    #
    class Base
      # Usage:
      # 
      #   @template = YMDP::Template::Base.new(params)
      #
      # Arguments:
      #
      #   - verbose: boolean value, output verbose notices,
      #   - domain: string, indicates which domain the template is compiling to,
      #   - file: filename of the template in questions,
      #   - hash: git hash of the latest commit,
      #   - message: commit message of the latest commit.
      #
      def initialize(params)
        @verbose = params[:verbose]
        @domain = params[:domain]
        @server = SERVERS[@domain]["server"]
        @file = params[:file]
        @assets_directory = "/om/assets/#{SERVERS[@domain]['assets_id']}"
        @hash = params[:git_hash]
        @message = params[:message]
    
        set_content_variables
    
        @view = base_filename(@file.split("/").last)
        Application.current_view = @view
      end
  
      # Parses the file 'content.yml' and adds each of its keys to the environment as
      # an instance variable, so they will be available inside the template.
      #
      def set_content_variables
        content = YAML.load_file("#{CONFIG_PATH}/content.yml")
        content.each do |key, value|
          attribute = "@#{key}"
          instance_variable_set(attribute, value) unless instance_variable_defined?(attribute)
        end
      end
      
      # If the filename begins with a _ it's a partial.
      #
      def partial?
        @file =~ /#{BASE_PATH}\/app\/views\/_/
      end

      # Compile this view unless it is a partial.
      #
      def build
        unless partial?
          write_template(processed_template)
        end
      end
  
      # Returns the compiled template code after its Haml or ERB has been processed.
      #
      def processed_template
        result = ""
        File.open(@file) do |f|
          template = f.read
          if @file =~ /\.haml$/
            result = process_haml(template, @file)
          else
            result = process_template(template)
          end
        end
        result
      end
      
      # Implemented in child classes, this defines what must be done to process a template.
      #
      def process_template(template)
        raise "Define in child"
      end
  
      # Produces the destination path of this template, in the servers directory for
      # the given domain.
      #
      # For example:
      #
      #   source: app/views/authorize.html.haml
      #   destination: servers/staging/views/authorize.html.haml
      #
      def destination_path
        # just the file, with no directory
        filename = File.basename(@file)
        
        # just the filename, with no extension
        filename = convert_filename(filename)
        
        # just the directory, with no file 
        directory = File.dirname(@file)
        
        # replace the app directory with the server directory
        relative_directory = directory.gsub!("#{BASE_PATH}/app", server_path)
        
        # make the directory if it doesn't exist
        FileUtils.mkdir_p(relative_directory)
        
        "#{relative_directory}/#{filename}"
      end
      
      # Path to the servers directory for the current domain:
      #
      # - "./servers/staging"
      # - "./servers/alpha"
      #
      def server_path
        "#{SERVERS_PATH}/#{@domain}"
      end
  
      # Outputs a message if @verbose is on.
      #
      def verbose(message)
        $stdout.puts(message) if @verbose
      end
      
      # Writes the input string to the destination file without adding any layout.
      #
      def write_template_without_layout(result)
        path = destination_path
    
        File.open(path, "w") do |f|
          f.write(result)
        end
        verbose "Finished writing #{path}.\n"
      end
  
      def write_template_with_layout(result)
        @content = result
        application_layout = "#{BASE_PATH}\/app\/views\/layouts\/application.html"
        haml_layout = application_layout + ".haml"
        erb_layout = application_layout + ".erb"
        
        if File.exists?(haml_layout)
          layout = File.open(haml_layout) do |f|
            template = f.read
            process_haml(template, haml_layout)
          end
        elsif File.exists?(erb_layout)
          layout = File.open(erb_layout) do |f|
            template = f.read
            process_template(erb_layout)
          end
        end
        
        write_template_without_layout(layout)
      end
  
      # Write this processed template to its destination file.
      #
      # Overwrite in child class to define whether the class uses a template or not.
      #
      def write_template(result)
        write_template_with_layout(result)
      end
    end

    class View < Base
      include ActionView::Helpers::TagHelper
  
      begin
        include ApplicationHelper
      rescue NameError
      end
    
      include YMDP::Base
      include YMDP::AssetTagHelper
      include YMDP::FormTagHelper
      include YMDP::LinkTagHelper
  
      attr_accessor :output_buffer
      
      # Filename without its extension:
      #
      # - "authorize.html.haml" becomes "authorize"
      #
      def base_filename(filename)
        filename.gsub(/(\.html|\.erb|\.haml)/, "")
      end

      # Filename without its extension:
      #
      # - "authorize.html.haml" becomes "authorize"
      #
      def convert_filename(filename)
        base_filename(filename)
      end
  
      # Process this template with ERB.
      #
      def process_template(template)
        ERB.new(template, 0, "%<>").result(binding)
      end
  
      # Process this template with Haml.
      #
      def process_haml(template, filename=nil)
        options = {}
        if filename
          options[:filename] = filename
        end
        Haml::Engine.new(template, options).render(self)
      end
  
      def write_template(result)
        write_template_with_layout(result)
        YMDP::Validator::HTML.validate(destination_path) if CONFIG.validate_html?
      end
    end

    class JavaScript < View
      def compress_js(filename)
        if compress_js_assets?
          validate_filename = "#{filename}.min"
          YMDP::Compressor::JavaScript.compress(filename)
        end
      end
    
      def write_template(result)
        filename = @file.split("/").last
        tmp_filename = "./tmp/#{filename}"
        save_to_file(result, tmp_filename)
        result = YMDP::Compressor::JavaScript.compress(tmp_filename) || result
        write_template_without_layout(result)
      end
    end

    class YRB < Base
      def directory
        directory = "#{BASE_PATH}/servers/#{@domain}/assets/yrb"
        FileUtils.mkdir_p(directory)
        directory
      end
  
      def destination_path
        filename = convert_filename(@file.split("/").last)
        "#{directory}/#{filename}"
      end  
  
      def to_json
        processed_template
      end
  
      def to_hash
        JSON.parse(to_json)
      end
  
      def to_yaml
        h = {}
        to_hash.each do |k,v|
          k = k.downcase
          h[k] = "#{v}"
        end
        h.to_yaml
      end
  
      def processed_template
        super.to_json
      end
  
      def validate
        YMDP::Validator::JSON.validate(destination_path)
      end
  
      private
  
      def base_filename(filename)    
        filename.gsub(/\.pres/, "")
      end
  
      def convert_filename(filename)
        "#{base_filename(filename)}.json"
      end
  
      def process_template(template)
        @hash = {}
        lines = template.split("\n")
        lines.each do |line|
          unless line =~ /^[\s]*#/
            line =~ /^([^\=]+)=(.+)/
            key = $1
            value = $2
            unless key.blank?
              if @hash.has_key?(key)
                puts
                puts "Duplicate value in #{destination_path}"
                puts "  #{key}=#{@hash[key]}"
                puts "  #{key}=#{value}"
                puts
                if @hash[key] == value
                  puts "  Values are the same but duplicate values still should not exist!"
                  puts
                end
                raise "Duplicate key error"
              end
              @hash[key] = value
            end
          end
        end
        @hash
      end
  
      def write_template(result)
        puts destination_path if CONFIG.verbose?
        write_template_without_layout(result)
      end
    end
  end
end
