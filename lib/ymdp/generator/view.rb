require 'support/file'
require 'translator/base'
require 'erb'

module YMDP
  module Generator
    module Snippets
      def launcher_method(view)
        view = view.downcase
        class_name = view.capitalize
<<-OUTPUT

Launcher.launch#{class_name} = function() {
  Launcher.launchTab("#{view}", "#{class_name}");
};
OUTPUT
      end
    end
    
    module Templates
      class Base
        include YMDP::FileSupport
        
        attr_accessor :view
        
        def initialize(view)
          @view = view
        end
        
        def generate
          write_processed_template
        end
        
        def template_dir
          "#{APPLICATION_PATH}/generator/templates"
        end
  
        def process_template(template)
          ERB.new(template, 0, "%<>").result(binding)
        end
        
        def processed_template
          result = ""
          File.open(full_template_path) do |f|
            template = f.read
            result = process_template(template)
          end
          result          
        end
        
        def write_processed_template
          write_to_file
        end
        
        def destination_path
          "#{destination_dir}/#{destination_filename}"
        end
        
        def full_template_path
          "#{template_dir}/#{template_filename}"
        end
        
        def write_processed_template
          if confirm_overwrite(destination_path)
            append_to_file(destination_path, processed_template)
          end
        end
        
        def append_to_file(file, content)
          File.open(file, "a") do |f|
            puts "  #{display_path(file)} writing . . ."
            f.puts content
          end
        end
      end
      
      class View < Base
        def template_filename
          "view.html.haml"
        end
        
        def destination_filename
          "#{view}.html.haml"
        end
        
        def destination_dir
          "#{BASE_PATH}/app/views"
        end
      end
    
      class JavaScript < Base
        def template_filename
          "javascript.js"  
        end
        
        def destination_dir
          "#{BASE_PATH}/app/javascripts"
        end
        
        def destination_filename
          "#{view}.js"
        end
      end
    
      class Stylesheet < Base
        def template_filename
          "stylesheet.css"
        end
        
        def destination_dir
          "#{BASE_PATH}/app/stylesheets"
        end
        
        def destination_filename
          "#{view}.css"
        end
      end
    
      class Translation < Base
        def template_filename
          "translation.pres"
        end
        
        def destination_dir
          "#{BASE_PATH}/app/assets/yrb/en-US"
        end
        
        def destination_filename
          "new_#{view}_en-US.pres"
        end
      end
      
      class Modifications < Base
        include Snippets
        
        def generate
          content = launcher_method(view)
          append_to_file(destination_path, content)
        end
        
        def destination_dir
          "#{BASE_PATH}/app/javascripts"
        end
        
        def destination_filename
          "launcher.js"
        end
      end
    end
    
    class View
      attr_accessor :view
      
      def initialize(args)
        @view = args.first
      end
      
      def generate
        puts "Create a new view: #{view}"
        
        Templates::View.new(view).generate
        Templates::JavaScript.new(view).generate
        Templates::Stylesheet.new(view).generate
        Templates::Translation.new(view).generate
        Templates::Modifications.new(view).generate
        YMDP::Translator::YRB.translate
      end
    end
  end
end