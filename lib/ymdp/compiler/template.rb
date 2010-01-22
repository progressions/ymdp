require 'yrb'

module YMDP
  module Compiler #:nodoc:
    module Template #:nodoc:
      # Process source files into usable code.
      #
      # Source files can be HTML, Haml, ERB, JavaScript, or CSS files.
      #
      # Files with an extension of ".haml" will be processed with Haml, all others will
      # use ERB.
      #
      # ==== Examples
      #
      #   YMDP::Compiler::Template::View.new(params).build
      #
      #   YMDP::Compiler::Template::JavaScript.new(params).build
      # 
      #   @template = YMDP::Compiler::Template::Base.new(params)
      #
      # ==== Options
      #
      #   verbose: boolean value, output verbose notices,
      #   domain: string, indicates which domain the template is compiling to,
      #   file: filename of the template in question,
      #   hash: git hash of the latest commit,
      #   message: commit message of the latest commit.
      #
      class Base < YMDP::Base
        attr_accessor :domain, :server, :file, :assets_directory, :hash, :message
        
        def initialize(params)
          @verbose = params[:verbose]
          @domain = params[:domain]
          
          server_settings = servers[@domain]
          if server_settings
            @server = server_settings["server"]
          else
            raise StandardError.new("Server settings are required.")
          end
          
          raise StandardError.new("Server name does not exist in server settings.") unless @server
          
          @file = params[:file]
          @assets_directory = "/om/assets/#{servers[@domain]['assets_id']}"
          @hash = params[:git_hash]
          @message = params[:message]
          
          set_content_variables
          
          @view = base_filename(@file.split("/").last)
          Application.current_view = @view
        end
        
        # Is the verbose setting on?
        #
        def verbose?
          @verbose
        end
  
        # Parses the file 'content.yml' and adds each of its keys to the environment as
        # an instance variable, so they will be available inside the template.
        #
        def set_content_variables
          content_variables.each do |key, value|
            attribute = "@#{key}"
            instance_variable_set(attribute, value) unless instance_variable_defined?(attribute)
            class_eval %(
              attr_accessor :#{key}
            )
          end
        end
      
        # If the filename begins with a _ it's a partial.
        #
        def partial?
          File.basename(@file) =~ /^_/
        end

        # Compile this view unless it is a partial.
        #
        def build
          # puts "Base build"
          unless partial?
            write_template(processed_template)
          end
        end
  
        # Returns the compiled template code after its Haml or ERB has been processed.
        #
        def processed_template
          # "Base processed_template"
          result = ""
          template = File.read(@file)
          if @file =~ /\.haml$/
            result = process_haml(template, @file)
          else
            result = process_template(template)
          end
          result
        end
        
        def base_filename(filename)
          raise "Define in child"
        end
      
        # Implemented in child classes, this defines what must be done to process a template.
        #
        def process_template(template)
          raise "Define in child"
        end
  
        # Produces the destination path of this template, in the servers directory for
        # the given domain.
        #
        # ==== Examples
        #
        # If the source file is:
        # 
        #   app/views/authorize.html.haml
        #
        # The destination file will be:
        #
        #   servers/staging/views/authorize.html.haml
        #
        def destination_path
          # just the file, with no directory
          filename = File.basename(@file)
        
          # just the filename, with no extension
          filename = convert_filename(filename)
        
          # just the directory, with no file 
          directory = File.dirname(@file)
        
          # replace the app directory with the server directory
          relative_directory = directory.gsub!("#{paths[:base_path]}/app", server_path)
        
          # make the directory if it doesn't exist
          FileUtils.mkdir_p(relative_directory)
        
          "#{relative_directory}/#{filename}"
        end
      
        # Path to the servers directory for the current domain.
        #
        def server_path
          "#{servers_path}/#{@domain}"
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
          
          # puts "\n\n\nBase write_template_without_layout: #{result}, #{path}"
          
          File.open(path, "w") do |f|
            f.write(result)
          end
          verbose "Finished writing #{path}.\n"
          
          result
        end
  
        # Writes the input string to the destination file, passing it through the
        # application template.
        #
        # The application layout can be either Haml or ERB.
        #
        def write_template_with_layout(result)
          # puts "Base write_template_with_layout"
          @content = result
          layout = result
          
          application_layout = "#{paths[:base_path]}\/app\/views\/layouts\/application.html"
          haml_layout = application_layout + ".haml"
        
          if File.exists?(haml_layout)
            template = File.read(haml_layout)
            layout = process_haml(template, haml_layout)
          end
        
          write_template_without_layout(layout)
        end
  
        # Write this processed template to its destination file.
        #
        # Overwrite this method in child class to define whether the class 
        # uses a template or not.
        #
        def write_template(result)
          # puts "Base write_template"
          write_template_with_layout(result)
        end
        
        def servers_path
          "#{paths[:base_path]}/servers"
        end
      end

      class View < Base
        # TODO: Refactor this.  Right now it includes all the YMDP::ApplicationView and other helper files
        # into the same namespace where we're processing the templates.  It does this so it can
        # send its 'binding' into the ERB or Haml template and the template will be able to 
        # process methods like "render :partial => 'sidebar'" and so on. 
        #
        # All the methods which are meant to be run from inside a view need to be refactored into
        # their own class, which can be sent into the template as a binding.
        # 
        include ActionView::Helpers::TagHelper
  
        include ApplicationHelper if defined?(ApplicationHelper)
    
        include YMDP::ApplicationView
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
          # puts "View process_template"
          ERB.new(template, 0, "%<>").result(binding)
        end
  
        # Process this template with Haml.
        #
        def process_haml(template, filename=nil)
          # puts "View process_haml"
          options = {}
          if filename
            options[:filename] = filename
          end
          Haml::Engine.new(template, options).render(self)
        end
  
        # Write this template with the application layout applied.
        #
        # Validate the resulting HTML file if that option is turned on.
        #
        def write_template(result)
          # puts "View write_template"
          result = super(result)
          YMDP::Validator::HTML.validate(destination_path) if CONFIG.validate_html?
          
          result
        end
      end

      # Process templates for JavaScript files.
      # 
      # JavaScript files support ERB tags.
      #
      class JavaScript < View
        # Write the processed template without any layout.
        #
        # Run the JavaScript compressor on the file if that option is turned on.
        #
        def write_template(result)
          filename = @file.split("/").last
          tmp_filename = "./tmp/#{filename}"
          F.save_to_file(result, tmp_filename)
          result = YMDP::Compressor::JavaScript.compress(tmp_filename) if CONFIG.compress_embedded_js?
          write_template_without_layout(result)
        end
      end

      # Process Yahoo! Resource Bundle format translation files.
      #
      # Convert them to a hash and write the hash to a JSON file.
      #
      # Each language can have as many YRB translation files (with an extension of ".pres")
      # as necessary.  The files are concatenated together and converted into a single JSON file
      # for each language.
      #
      class YRB < Base
        # Base directory for translations for this domain.
        #
        def directory
          directory = "#{paths[:base_path]}/servers/#{@domain}/assets/yrb"
          FileUtils.mkdir_p(directory)
          directory
        end
  
        # The destination of the compiled JSON file.
        #
        def destination_path
          filename = convert_filename(@file.split("/").last)
          "#{directory}/#{filename}"
        end  
  
        # JSON values of the compiled translations.
        #
        def to_json
          processed_template
        end
  
        # Turn it back into a hash.
        #
        def to_hash
          yrb
        end
        
        # Parse YRB file
        #
        def yrb
          ::YRB.load_file(@file)
        end
  
        # Convert the hash to Yaml if you should want to do that.
        #
        def to_yaml
          h = {}
          to_hash.each do |k,v|
            k = k.downcase
            h[k] = "#{v}"
          end
          h.to_yaml
        end
  
        # This function is the file which is written to the destination--in this
        # case, the JSON file.
        #
        def processed_template
          yrb.to_json
        end
  
        # Validate the JSON file.
        #
        def validate
          YMDP::Validator::JSON.validate(destination_path)
        end
  
        private
      
        # Strip off the ".pres" extension from original YRB files.
        #
        def base_filename(filename)    
          filename.gsub(/\.pres/, "")
        end
  
        # Take the base filename and add the ".json" extension.
        #
        def convert_filename(filename)
          "#{base_filename(filename)}.json"
        end
  
        # Write JSON file to its destination.
        #
        def write_template(result)
          $stdout.puts destination_path if CONFIG.verbose?
          write_template_without_layout(result)
        end
      end
    end
  end
end