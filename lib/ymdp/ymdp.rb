require 'config'
require 'processor/compressor'
require 'processor/validator'
require 'support/file'

class Application
  def self.current_view?(view)
    current_view.downcase == view.downcase
  end
  
  def self.current_view
    @@current_view
  end
  
  def self.current_view= view
    @@current_view = view
  end
end

module YMDP
  module Base
    include YMDP::Config
    include YMDP::FileSupport
    include YMDP::Compressor
    
    extend self
    
    def supported_languages
      dirs = Dir["#{BASE_PATH}/app/assets/yrb/*"].map do |path|
        filename = path.split("/").last
        
        filename
      end
      
      dirs.unshift(dirs.delete("en-US"))
      
      raise "Default YRB key en-US not found" unless dirs.include?("en-US") 
      
      dirs
    end
    
    def english_languages
      supported_languages.select do |lang|
        lang =~ /^en/
      end
    end
    
    def javascript_include(filename)
      unless filename =~ /^http/
        filename = "#{@assets_directory}/javascripts/#{filename}"
      end
      "<script src='#{filename}' type='text/javascript' charset='utf-8'></script>"
    end
    
    def include_firebug_lite
      javascript_include "http://getfirebug.com/releases/lite/1.2/firebug-lite-compressed.js" if @domain != "my"
    end
  
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
  
    def render_stylesheet(filename, tags=false)
      unless filename =~ /\.css$/
        filename = "#{filename}.css"
      end
      path = "#{BASE_PATH}/app/stylesheets/#{filename}"
    
      output = ''
      if File.exists?(path)
        tmp_filename = save_processed_template(path)
        if compress_css?
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
    
    def render_without_compression(filename, tags=true)
      unless filename =~ /\.js$/
        filename = "#{filename}.js"
      end
      path = "#{YMDP_ROOT}/app/javascripts/#{filename}"
  
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
    
    # processes the template (with HAML or ERB) and saves it to the tmp folder
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