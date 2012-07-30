require 'rubygems'
require 'epic'

module YMDP
  # Contains all the functions which are available from inside a view file, whether that view
  # is HTML, JavaScript or CSS.
  #
  module ApplicationView
    
    extend self
    
    # Returns an array of the country codes of all languages supported by the application, 
    # which is determined by the language-specific folders in "app/assets/yrb".
    #
    # ==== Examples
    #
    #   supported_languages    
    #   # => ["en-US", "de-DE", "es-ES", "es-MX"]
    #
    def supported_languages
      YAML.load_file("./config/idiom.yml")["locales"].keys
    end

    def translations
      @translations ||= {}
      
      Dir["./config/locales/**/*.yml"].each do |file|
        @translations.merge!(YAML.load_file(file)) do |key, old, new|
          old.merge new
        end
      end

      @translations
    end

    # Returns an array of country codes of English-speaking countries supported
    # by the application, based on the language-specific folders located in "app/assets/yrb".
    #
    # ==== Examples
    #
    #   english_languages    
    #   # => ["en-US", "en-AU", "en-SG", "en-MY"]
    #
    def english_languages
      supported_languages.select do |lang|
        lang =~ /^en/
      end
    end
    
    # Includes a JavaScript file in a view.  If the filename is a full path, the 
    # JavaScript file will be linked as an external asset.  If not, the file will
    # linked as a local asset located in the YMDP application's assets directory.
    #
    # === Local JavaScript Assets
    #
    #   javascript_include("application.js")
    # 
    # will produce: 
    #
    #   <script src='/om/assets/3ifh3b2kjf_1/assets/javascripts/application.js' 
    #   type='text/javascript charset='utf-8'></script>
    #
    # === External JavaScript Assets
    #
    #   javascript_include("http://www.myserver.com/javascripts/application.js")
    #
    # will produce:
    #
    #   <script src='http://www.myserver.com/javascripts/application.js' type='text/javascript
    #   charset='utf-8'></script>
    #
    def javascript_include(filename, options={})
      if filename == :defaults
        render_default_javascripts(options)
        filename = "defaults.js"
      end
      unless filename =~ /^http/
        filename = "#{@assets_directory}/javascripts/#{filename}"
      end
      "<script src='#{filename}' type='text/javascript' charset='utf-8'></script>"
    end
    
    def combo(filenames, options={})
      paths = filenames.map do |filename|
        "javascripts/#{filename}"
      end.join("&")
      "<script src=\"/yahoo/mail/combo?#{paths}\"></script>"
    end
    
    # Renders a link to include Firebug Lite for debugging JavaScript in Internet Explorer.
    # 
    def include_firebug_lite
      javascript_include "http://getfirebug.com/releases/lite/1.2/firebug-lite-compressed.js"
    end
  
    # Renders a partial into the current view. HTML partial names must be preceded with an underscore.
    #
    # == Rendering an HTML partial
    #
    # HTML partials are located in <tt>app/views</tt>. HTML view files can be Haml or ERB. 
    # Haml is recommended and takes preference. HTML partials are named <tt>_<i>filename</i>.html.haml</tt>
    # or <tt>_<i>filename</i>.html.erb</tt>.
    #
    #   render :partial => 'sidebar'
    #
    # will find <tt>app/views/_sidebar.html.haml</tt> or <tt>app/views/_sidebar.html.erb</tt>
    # and render its contents into the current view.
    #
    # Specify a full path to indicate a specific template.
    #
    #   render :partial => 'sidebar.html.erb'
    #
    # will find <tt>app/views/_sidebar.html.erb'</tt> and render it even if 
    # <tt>app/views/_sidebar.html.haml</tt> exists.
    #
    #   render :partial => 'shared/sidebar'
    #
    # will find <tt>app/views/shared/_sidebar.html.haml</tt> and render its contents into the current view.
    #
    # == Rendering a JavaScript partial
    #
    # You can render a single JavaScript file or send an array to concatenate a set of JavaScript
    # files together asone script block.
    #
    # === Rendering a single JavaScript partial
    #
    # JavaScript partials are located in <tt>app/javascripts</tt> and are named <tt><i>filename</i>.js</tt>
    #
    #   render :javascript => 'application'
    #
    # will find <tt>app/javascripts/application.js</tt> and render its contents into the current view 
    # in an inline script block.
    #
    #   render :javascript => 'shared/sidebar'
    #
    # will find <tt>app/javascripts/shared/sidebar.js</tt> and render its contents into the current
    # view in an inline script block.
    #
    # == Rendering a stylesheet partial
    #
    # Stylesheets are located at <tt>app/stylesheets</tt> and are named <tt>_filename_.css</tt>
    #
    #
    # === Rendering multiple partials
    #
    # Pass an array to <tt>render</tt> to combine multiple files into a single
    # inline block.  This is useful for compression and validation, as it allows a set of 
    # files to be compressed or validated in a single context.
    # 
    #   render :javascript => ['application', 'flash', 'debug']
    #
    # will combine the contents of <tt>app/javascripts/application.js</tt>, 
    # <tt>app/javascripts/application.js</tt>, and <tt>app/javascripts/application.js</tt>
    # into a single script block in the current view.
    #
    # Pass a <tt>:filename</tt> parameter to set the name of the combined file.  Currently the
    # combined file only exists on disc while it's being compressed and/or validated, but
    # in the future this may be expanded to save multiple files as a single external asset.
    # 
    #   render :javascript => ['application', 'flash', 'debug'], :filename => 'javascripts'
    #
    # Currently the <tt>:filename</tt> parameter is simply a convenience.
    #
    # Multiple partials of any type can be rendered.
    # 
    # For example:
    #
    #   render :partial => ['header', 'footer', 'sidebar'], :filename => 'html_layouts'
    #
    # will find <tt>app/views/_header.html.haml</tt>, <tt>app/views/_footer.html.haml</tt>,
    # and <tt>app/views/_sidebar.html.haml</tt> and write them to a temporary file called
    # <tt>tmp/html_layouts</tt> before rendering that file into the current view.
    #
    # This feature is intended mainly for JavaScript and CSS.
    #
    # For example:
    #
    #   render :stylesheet => ['application', 'colors'], :filename => 'styles'
    #
    # will render <tt>app/stylesheets/application.css</tt> and <tt>app/stylesheets/colors.css</tt>
    # as a single temporary file called <tt>tmp/styles</tt> before rendering that file into 
    # the current view.
    #
    # If compression and validation options are turned on, the resulting temporary file will be
    # compressed and/or validated before being rendered into the current view.  This will result
    # in a more efficient compression and a more effective validation. 
    #
    def render(params)
      output = []
      
      unless params.has_key?(:tags)
        params[:tags] = true
      end
        
      output << render_html_partial(params)
      output << render_javascript_partial(params) if params[:javascript]
      output << render_stylesheet_partial(params) if params[:stylesheet]
      
      output.flatten.join("\n")
    end
  
    private
    
    # Renders an HTML, Haml or ERB partial.
    #    
    def render_html_partial(params)
      output = []
      
      if params[:partial]
        Array(params[:partial]).each do |partial|
          output << render_partial(partial)
        end
      end
      output     
    end

    # Renders an HTML partial.
    #
    def render_partial(filename)
      output = ''
      path = find_partial(filename)

      if path && File.exists?(path)
        template = File.read(path)
        if path =~ /haml$/
          output = process_haml(template, path)
        else
          output = process_erb(template)
        end
      else
        raise "Could not find partial: #{filename}"
      end
      output    
    end
    
    # Searches all the possible paths to find a match for this partial name.
    #
    def find_partial(full_path)
      path = nil
      ["views", "views/shared"].each do |dir|
        
        p = full_path.split("/")
        filename = p.pop
        
        filename = "_#{filename}"
        p.push(filename)
        
        final_path = p.join("/")
        
        basic_path = "#{BASE_PATH}/app/#{dir}/#{final_path}.html"
        
        ["", ".haml", ".erb"].each do |extension|
          if File.exists?(basic_path + extension)
            path ||= basic_path + extension
          end
        end
      end
      
      path
    end
    
    def render_default_javascripts(options={})
      library_path = options[:library] || configuration.javascript_library || "jquery"
      
      # Javascripts need to be loaded in a certain order, this is why we don't just load everything at once
      #
      default_javascripts = ['application', 'params', 'browser', 'data', 'ajax', 'user', 'init', 'reporter', 'debug', 'tag_helper', 'launcher', 'logger', 'i18n', 'flash', 'ab_testing', 'education', 'authorization']
      
      filenames = filter_filenames(default_javascripts, options)
      
      filenames = filenames.map do |filename|
        File.join(File.dirname(__FILE__), "..", "javascripts", library_path, "#{filename}.js")
      end
      
      output = combine_files(filenames)
      write_javascript_asset(output, "defaults")
    end
    
    def filter_filenames(filenames, options={})
      if options[:only]
        filenames = filenames.select do |filename|
          options[:only].include?(filename)
        end
      end
      if options[:except]
        filenames = filenames.reject do |filename|
          options[:except].include?(filename)
        end
      end
      filenames
    end
    
    def render_javascript_partial(params)
      filename = params[:filename] || Array(params[:javascript]).join("_")
      
      if configuration.external_assets["javascripts"]
        tags = false
      else
        tags = params[:tags]
      end
      
      output = []
      
      # Render a JavaScript partial.
      #
      if params[:javascript]
        content = render_javascripts(Array(params[:javascript]), params[:filename])
        unless content.blank?
          output << "<script type='text/javascript'>" if tags
          output << content
          output << "</script>" if tags
        end
      end
      
      output = output.join("\n")

      if configuration.external_assets["javascripts"] && params[:tags]
        write_javascript_asset(output, filename)
        
        "<script type='text/javascript' src='#{assets_directory}/javascripts/#{filename}.js'></script>"
      else
        output
      end
    end
    
    def write_javascript_asset(output, filename)
      path = "#{server_path}/assets/javascripts/#{filename}.js"
      
      $stdout.puts "Writing #{path}"

      File.open(path, "w") do |f|
        f.write(output)
      end
    end
    
    def write_stylesheet_asset(output, filename)
      path = "#{server_path}/assets/stylesheets/#{filename}.css"
      
      $stdout.puts "Writing #{path} oh yeah"

      output = Array(output).join("\n")
      
      File.open(path, "w") do |f|
        f.write(output)
      end
    end
    
    # Renders a JavaScript partial.
    #
    def render_javascripts(filenames, combined_filename=nil)
      filenames_str = combined_filename || filenames.join().gsub("/", "_")
      
      filenames.map! do |filename|
        filename.gsub!(/\.js$/, "")
        "#{BASE_PATH}/app/javascripts/#{filename}.js"
      end
      
      output = combine_files(filenames)
      tmp_filename = "#{TMP_PATH}/#{filenames_str}.js"
      
      validate = F.save_to_file(output, tmp_filename)
      
      if validate && configuration.validate["embedded_js"]["build"] && !js_validator.validate(tmp_filename)
        raise "JavaScript Errors embedded in #{display_path(tmp_filename)}"
      end
      
      output
    end
    
    def js_validator
      @js_validator ||= Epic::Validator::JavaScript.new
    end
    
    # Render a CSS partial.
    #
    def render_stylesheet_partial(params)
      filename = params[:filename] || Array(params[:stylesheet]).join("_")
      external_asset = params[:tags] && configuration.external_assets["stylesheets"]
      output = []
      if params[:stylesheet]
        content = render_stylesheets(Array(params[:stylesheet]), params[:filename])
        unless content.blank?
          output << "<style type='text/css'>" unless external_asset
          output << content
          output << "</style>" unless external_asset
        end
      end
      
      if external_asset
        write_stylesheet_asset(output, filename)
        
        "<link rel='stylesheet' type='text/css' href='#{assets_directory}/stylesheets/#{filename}.css'></link>"
      else
        output
      end
    end
    
    # Renders a CSS partial.
    #
    def render_stylesheets(filenames, combined_filename=nil)
      filenames_str = combined_filename || filenames.join().gsub("/", "_")
      tmp_filename = "#{TMP_PATH}/#{filenames_str}.css"
      
      filenames.map! do |filename|
        filename.gsub!(/\.css$/, "")
        f = "#{BASE_PATH}/app/stylesheets/#{filename}.css"
        if !File.exists?(f)
          f = "#{BASE_PATH}/app/stylesheets/#{filename}"
        end
        f
      end
      
      output = combine_files(filenames)
      
      validate = F.save_to_file(output, tmp_filename)
      
      output
    end
    
    # Concatenates all files into one long string.
    #
    def combine_files(filenames)
      output = []
      filenames.each do |filename|
        output << render_without_compression(filename, false)
      end
      output.join("\n")
    end
    
    # Renders together a set of files without 
    # compression, so they can be compressed as a single block.
    #
    def render_without_compression(path="", tags=true)
      path ||= ""
      output = ""

      if File.exists?("#{path}.coffee")
        path = "#{path}.coffee"
        $stdout.puts("Parsing #{path}")
        template = File.read(path)
        output = process_coffee(template)
      elsif File.exists?("#{path}.scss")
        path = "#{path}.scss"
        $stdout.puts("Parsing #{path}")
        template = File.read(path)
        output = process_scss(template)
      elsif File.exists?(path)
        $stdout.puts("Parsing #{path}")
        template = File.read(path)
        output = process_erb(template)
      end
      
      output
    end
  end
  
  class View
    include YMDP::ApplicationView

    def initialize(assets_directory)
      @assets_directory = assets_directory
    end  
  end
end
