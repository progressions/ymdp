require 'ymdp/base'
require 'ymdp/support/file'
require 'w3c_validators'


module YMDP
  module Validator
    class Base < YMDP::Base
    end
    
    class HTML < Base
      class << self
        def validator
          @validator ||= W3CValidators::MarkupValidator.new
        end
        
        def validate(path)
          $stdout.print "   #{path}  validating . . . "
          doctype = configuration.validate["html"]["doctype"]
          validator.set_doctype!(doctype)

          results = validator.validate_file(path)
          
          valid = results.errors.length <= 0
          
          if valid
            $stdout.puts "OK"
          else
            $stdout.puts "validation errors"
            results.errors.each do |err|
              $stdout.puts
              $stdout.puts err.to_s
            end
          end
          
          valid
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
        configuration.jslint_settings
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

          jslint_path = File.expand_path("#{File.dirname(__FILE__)}/jslint.js")
          raise "#{jslint_path} does not exist" unless File.exists?(jslint_path)
          results = F.execute("java org.mozilla.javascript.tools.shell.Main #{jslint_path} #{js_fragment_path}", :return => true)

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