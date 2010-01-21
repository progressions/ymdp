require 'ymdp/base'
require 'support/file'
require 'processor/w3c'
require 'processor/form_post'

module YMDP
  module Validator
    class Base < YMDP::Base
    end
    
    class HTML < Base
      def self.validate(path)
        html_display_path = display_path(path)

        log_path = validation_errors(path)
        if log_path
          g("HTML validation errors found")
          F.execute "open #{log_path}"
          raise "Invalid HTML"
        else
          $stdout.puts "   #{html_display_path}  validating . . . OK"
        end
      end
      
      def self.validation_errors(path)
        html_display_path = display_path(path)
        doctype = CONFIG["doctype"] || "HTML 4.0 Transitional"

        resp = W3CPoster.post_file_to_w3c_validator(path, doctype)
        html = resp.read_body
        if html.include? "[Valid]"
          false
        else
          log_path = "#{TMP_PATH}/#{File.basename(path)}_errors.html"
          $stdout.puts "   #{html_display_path} is not valid HTML, writing to #{display_path(log_path)}"
          $stdout.puts
          $stdout.puts "     To view errors:"
          $stdout.puts "     open #{display_path(log_path)}"
          $stdout.puts
          
          File.open(log_path,'w') do |f|
             f.puts html
           end
           
          $stdout.puts "     Viewing errors..."    
          log_path
        end  
      end
    end
    
    class JavaScript < Base
      def self.validate(filename)
        validate_javascript(filename)
      end
      
      def self.use_jslint_settings?
        !jslint_settings.blank?
      end
      
      def self.jslint_settings
        YMDP::Base.jslint_settings
      end
      
      def self.jslint_settings_count
        jslint_settings.to_s.split("\n").size
      end
      
      def self.pre_process(content)
        content
      end
    
      def self.validate_javascript(path)
        display = display_path(path)
        $stdout.print "   #{display}  validating . . . "
        output = ""
      
        File.open(path) do |f|
          output = f.read
        end
        
        output = pre_process(output)
        
        js_fragment_path = File.expand_path("#{TMP_PATH}/#{File.basename(path)}_fragment")
        fragment_display_path = display_path(js_fragment_path)
    
        unless File.exists?(js_fragment_path)
          File.open(js_fragment_path,'w') do |f|
            f.puts jslint_settings if use_jslint_settings?
            f.puts output
          end

          results = F.execute("java org.mozilla.javascript.tools.shell.Main ./script/jslint.js #{js_fragment_path}", :return => true)

          if results =~ /jslint: No problems found/
            $stdout.puts "OK"
          else
            $stdout.puts "errors found!"
            results.split("\n").each do |result|
              if result =~ /line (\d+) character (\d+): (.*)/
                line_number = $1.to_i
                error = "Error at #{fragment_display_path} line #{line_number-jslint_settings_count} character #{$2}: #{$3}"
                error += F.get_line_from_file(js_fragment_path, line_number)
          
                $stdout.puts error
              end
            end
            message = "JavaScript Errors embedded in #{display}"
            g(message)
            raise message
          end
        end
      end
    end
    
    class JSON < JavaScript
      def self.pre_process(output)
        output
      end
      
      def self.jslint_settings
      end
    end
    
    class Stylesheet < Base
      def self.validate(filename)
        true
      end
    end
  end
end