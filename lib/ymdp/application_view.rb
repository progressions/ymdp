require 'processor/compressor'
require 'processor/validator'

module YMDP
  # Contains all the functions which are available from inside a view file, whether that view
  # is HTML, JavaScript or CSS.
  #
  module ApplicationView
    include YMDP::FileSupport
    include YMDP::Compressor
    
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
      dirs = Dir["#{BASE_PATH}/app/assets/yrb/*"].map do |path|
        filename = path.split("/").last
        
        filename
      end
      
      dirs.unshift(dirs.delete("en-US"))
      
      raise "Default YRB key en-US not found" unless dirs.include?("en-US") 
      
      dirs
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
    def javascript_include(filename)
      unless filename =~ /^http/
        filename = "#{@assets_directory}/javascripts/#{filename}"
      end
      "<script src='#{filename}' type='text/javascript' charset='utf-8'></script>"
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
    # === Rendering multiple JavaScript partials
    #
    # Pass an array to <tt>render</tt> to combine multiple JavaScript files into a single
    # inline block.  This is useful for compression and validation, as it allows a set of 
    # JavaScript files to be compressed or validated in a single context.
    # 
    #   render :javascript => ['application', 'flash', 'debug']
    #
    # will combine the contents of <tt>app/javascripts/application.js</tt>, 
    # <tt>app/javascripts/application.js</tt>, and <tt>app/javascripts/application.js</tt>
    # into a single script block in the current view.
    #
    # Pass a <tt>:filename</tt> parameter to set the name of the combined file.  Currently the
    # combined file only exists on disc while it's being compressed and/or validated, but
    # in the future this may be expanded to save multiple JavaScripts as a single external asset.
    #
    # Currently the <tt>:filename</tt> parameter is simply a convenience.
    #
    # == Rendering a stylesheet partial
    #
    # Stylesheets are located at <tt>app/stylesheets</tt> and are named <tt>_filename_.css</tt>
    #
    def render(params)
      output = []
      tags = true
      if params[:tags] == false
        tags = false
      end
      if params[:partial]
        params[:partial].to_a.each do |partial|
          output << render_partial(partial)
        end
      end
      if params[:javascript]
        output << "<script type='text/javascript'>" if tags
        output << render_javascripts(params[:javascript].to_a, params[:filename])
        output << "</script>" if tags
      end
      if params[:stylesheet]
        params[:stylesheet].to_a.each do |stylesheet|
          output << render_stylesheet(stylesheet, tags)
        end
      end
      output.join("\n")
    end
  
    private

    # Internal use only. Renders an HTML partial.
    #
    def render_partial(filename)
      output = ''
      path = nil
      
      ["views", "views/shared"].each do |dir|
        basic_path = "#{BASE_PATH}/app/#{dir}/_#{filename}.html"
        
        ["", ".haml", ".erb"].each do |extension|
          if File.exists?(basic_path + extension)
            path ||= basic_path + extension
          end
        end
      end

      if path
      
        File.open(path) do |f|
          template = f.read
          if path =~ /haml$/
            output = process_haml(template, path)
          else
            output = process_template(template)
          end
        end
      else
        raise "Could not find partial: #{filename}"
      end
      output    
    end
  
    # Internal use only. Renders a stylesheet partial.
    #
    def render_stylesheet(filename, tags=false)
      unless filename =~ /\.css$/
        filename = "#{filename}.css"
      end
      path = "#{BASE_PATH}/app/stylesheets/#{filename}"
    
      output = ''
      if File.exists?(path)
        tmp_filename = save_processed_template(path)
        if CONFIG.compress_css?
          output = YMDP::Compressor::Stylesheet.compress(tmp_filename)
        else
          File.open(path) do |f|
            template = f.read
            output = process_template(template)          
          end
        end
    
        if tags
          "<style type='text/css'>\n" + output + "\n</style>"
        else
          output
        end
      else
        ""
      end
    end
    
    # Internal use only. Renders a JavaScript partial.
    #
    def render_javascripts(filenames, combined_filename=nil)
      output = []
      
      # concatenate all javascript files into one long string
      #
      filenames.each do |filename|
        output << render_without_compression(filename, false)
      end
      output = output.join("\n")
      
      filenames_str = combined_filename || filenames.join()
      tmp_filename = "./tmp/#{filenames_str}.js"
      
      # use the saved file if it already exists
      unless File.exists?(tmp_filename)
        save_to_file(output, tmp_filename)
        validate_filename = tmp_filename
      end
        
      # return compressed javascript or else don't
      output = YMDP::Compressor::JavaScript.compress(tmp_filename) || output
      
      YMDP::Validator::JavaScript.validate(validate_filename) if validate_filename
      
      output
    end
    
    # Internal use only. Renders together a set of JavaScript files without 
    # compression, so they can be compressed as a single block.
    #
    def render_without_compression(filename, tags=true)
      unless filename =~ /\.js$/
        filename = "#{filename}.js"
      end
      path = "#{BASE_PATH}/app/javascripts/#{filename}"
  
      output = ''
    
      if File.exists?(path)
        File.open(path) do |f|
          template = f.read
          output = process_template(template)
        end

        if tags
          "<script type='text/javascript'>\n" + output + "\n</script>"
        else
          output
        end
      else
        ""
      end
    end
    
    # Internal use only. Processes the template (with HAML or ERB) and saves it to the tmp folder
    #
    def save_processed_template(path)
      filename = path.split("/").last
      tmp_filename = "#{TMP_PATH}/#{filename}"

      unless File.exists?(tmp_filename)      
        File.open(path) do |f|
          template = f.read
          output = process_template(template)

          save_to_file(output, tmp_filename)
        end
      end
    
      tmp_filename      
    end
  end
end