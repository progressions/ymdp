require 'support/file'

module YMDP
  module Validator
    class Base
      extend YMDP::Config
      extend YMDP::FileSupport
    end
    
    class HTML < Base
      def self.validate(path)
        html_display_path = display_path(path)

        doctype = CONFIG["doctype"] || "HTML 4.0 Transitional"

        resp = post_file_to_w3c_validator(path, doctype)
        html = resp.read_body
        if html.include? "[Valid]"
          $stdout.puts "   #{html_display_path}  validating . . . OK"
        else 
          log_path = "#{TMP_PATH}/#{File.basename(path)}_errors.html"
          $stdout.puts "   #{html_display_path} is not valid HTML, writing to #{display_path(log_path)}"
          $stdout.puts
          $stdout.puts "     To view errors:"
          $stdout.puts "     open #{display_path(log_path)}"
          $stdout.puts
          File.open(log_path,'w') { |f| f.puts html }
          $stdout.puts "     Viewing errors..."
  
          g("HTML validation errors found")
          system "open #{log_path}"
          raise "Invalid HTML"
        end
      end
    end
    
    class JavaScript < Base
      def self.validate?
        validate_embedded_js?
      end
      
      def self.validate(filename)
        if validate?
          validate_javascript(filename)
        end
      end
      
      def self.use_jslint_settings?
        !jslint_settings.blank?
      end
      
      def self.jslint_settings
<<-JSLINT
/*jslint bitwise: true, browser: true, evil: true, eqeqeq: true, immed: true, newcap: true, onevar: false, plusplus: true, regexp: true, undef: true, sub: true */
/*global YAHOO, openmail, OpenMailIntl, _gat, unescape, $, $$, $A, $H, $R, $w, $div, Event, Effect, Behavior, Try, PeriodicalExecuter, Element, identify, Sortable, window, I18n, Identity, Logger, OIB, Tags, ABTesting, Flash, Debug */
JSLINT
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

          results = `java org.mozilla.javascript.tools.shell.Main ./script/jslint.js #{js_fragment_path}`

          if results =~ /jslint: No problems found/
            $stdout.puts "OK"
          else
            $stdout.puts "errors found!"
            results.split("\n").each do |result|
              if result =~ /line (\d+) character (\d+): (.*)/
                line_number = $1.to_i
                error = "Error at #{fragment_display_path} line #{line_number-jslint_settings_count} character #{$2}: #{$3}"
                error += get_line_from_file(js_fragment_path, line_number)
          
                $stdout.puts error
              end
            end
            message = "Javascript Errors embedded in #{display}"
            g(message)
            raise message
          end
        end
      end
    end
    
    class JSON < JavaScript
      def self.validate?
        validate_json_assets?
      end
      
      def pre_process(output)
        output
      end
      
      def self.jslint_settings
      end
    end
  end
end