require 'support/file'
require 'haml'

module YMDP
  module Renderer
    class Base
    end
    
    class Haml < Base
      def self.scope
        YMDP::ViewHelpers
      end
      
      def self.render(filename)
        options = {}
        ::Haml::Engine.new(filename, options).render(scope)
      end      
    end
    
    class ERB < Base
      def self.scope
        YMDP::ViewHelpers.get_binding
      end
      
      def self.render(filename)
        ::ERB.new(filename, 0, "%<>").result(scope)
      end
    end    
  end
  
  module Processor
    class Base
      extend YMDP::Config
      extend YMDP::FileSupport
      
      def self.render(params)
        output = []
        tags = true
        if params[:tags] == false
          tags = false
        end
        if params[:partial]
          # params[:partial].to_a.each do |partial|
            # output << render_partial(params)
            output << Partial.render(params)
          # end
        end
        # if params[:javascript]
        #   output << "<script type='text/javascript'>" if tags
        #   output << render_javascripts(params)
        #   output << "</script>" if tags
        # end
        # if params[:stylesheet]
        #   # params[:stylesheet].to_a.each do |stylesheet|
        #     output << render_stylesheet(params)
        #   # end
        # end
        output.join("\n")
      end
      
      def self.render_partial(params)
        Partial.render(params)
      end
      
      def self.render_javascripts(params)
        JavaScript.render(params)
      end
      
      def self.render_stylesheet(params)
        Stylesheet.render(params)
      end
    end
    
    class Partial < Base
      def self.render(params)
        filename = params[:partial]
        output = ''
        path = nil
      
        path = find_partial(filename)

        if path
          output = process(path)
        else
          raise "Could not find partial: #{filename}"
        end
        output
      end
      
      def self.process(path)
        output = ""
        
        File.open(path) do |f|
          template = f.read
          if path =~ /haml$/
            output = YMDP::Processor::Haml.render(template, path)
          else
            output = YMDP::Processor::ERB.render(template)
          end
        end
        
        output
      end
      
      def self.find_partial(partial)
        path = nil
        ["views", "views/shared"].each do |dir|
          basic_path = "#{BASE_PATH}/app/#{dir}/_#{partial}.html"
        
          ["", ".haml", ".erb"].each do |extension|
            if File.exists?(basic_path + extension)
              path ||= basic_path + extension
            end
          end
        end        
        path
      end
    end
    
    class JavaScript < Base
      def self.render(params)
        puts "Rendering partial"
      end
    end
    
    class Stylesheet < Base
      def self.render(params)
        puts "Rendering partial"
      end
    end
  end
end