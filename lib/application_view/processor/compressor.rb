require 'support/file'

module ApplicationView
  module Compressor
    class Base
      extend ApplicationView::Config
      extend ApplicationView::FileSupport
  
      def self.compress(path, options={})
        compressed_display_path = display_path(path)
        compressed_path = "#{path}.min"
      
        options["type"] ||= "js"
      
        unless File.exists?(compressed_path)
          $stdout.print "   #{compressed_display_path}  compressing . . . "
          compressed = ''
        
          if !obfuscate?
            options["nomunge"] = ""
          end
          if verbose?
            options["verbose"] = ""
          end
          options["charset"] = "utf-8"
        
          if options["type"].to_s == "js" && !options["preserve_semi"]
            options["preserve-semi"] = ""
          end
        
          options_string = options.map {|k,v| "--#{k} #{v}"}.join(" ")
      
          result = `java -jar ./script/yuicompressor-2.4.2.jar #{options_string} #{path} -o #{compressed_path} 2>&1`
        
          result.split("\n").each do |line|
            if line =~ /\[ERROR\] (\d+):(\d+):(.*)/
              line_number = $1.to_i
              error = "Error at #{compressed_display_path} line #{line_number} character #{$2}: #{$3}"
              error += get_line_from_file(path, line_number)
        
              $stdout.puts error
              growl(error)
            end
          end
        
          if result =~ /ERROR/
            raise "JavaScript errors in #{compressed_display_path}"
          else
            $stdout.puts "OK"
          end
        end

        if File.exists?(compressed_path)
          File.open(compressed_path) do |c|
            compressed = c.read
          end
        else
          raise "File does not exist: #{compressed_display_path}"
        end
      
        compressed      
      end
    end
    
    class Stylesheet < Base
      def self.compress(path)
        if compress_css?
          super(path, "type" => "css")
        end
      end
    end
    
    class JavaScript < Base      
      def self.compress(filename)
        if compress_embedded_js?
          super(filename, "type" => "js")
        end
      end
    end
  end
end