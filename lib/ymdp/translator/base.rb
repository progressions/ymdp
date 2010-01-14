require 'rubygems'
require 'rtranslate'
require 'timer'
require 'compiler/template_compiler'

module YMDP
  module Yaml
    module Support
      FILENAME_REGEXP = /(.*)_(..-..)\.yml$/
      
      def language_path(lang)
        "#{BASE_PATH}/app/assets/yrb/#{lang}"
      end

      def base_filename(path)
        filename = path.split("/").last
        filename =~ FILENAME_REGEXP
        $1
      end

      def language(path)
        filename = path.split("/").last
        filename =~ FILENAME_REGEXP
        $2
      end

      def destination_path(filename, lang)
        filename ||= base_filename(filename)
        "#{language_path(lang)}/#{filename}_#{lang}.yml"
      end
    end
  end
  
  module YRB
    module Support
      FILENAME_REGEXP = /(.*)_(..-..)\.pres$/
      
      def language_path(lang)
        "#{BASE_PATH}/app/assets/yrb/#{lang}"
      end

      def base_filename(path)
        filename = path.split("/").last
        filename =~ FILENAME_REGEXP
        $1
      end
  
      def language(path)
        filename = path.split("/").last
        filename =~ FILENAME_REGEXP
        $2
      end
  
      def destination_path(filename, lang)
        filename ||= base_filename(filename)
        "#{language_path(lang)}/#{filename}_#{lang}.pres"
      end
    end
  end
  
  module Translator
    module Support
      # Mapping of the way Yahoo! Mail represents country codes with the way Google Translate does.
      #
      # The key is the Yahoo! Mail representation, and the value is the code Google Translate would expect.
      #
      LOCALES = {
        "de-DE" => "de",
        "en-MY" => "en",
        "en-SG" => "en",
        "es-MX" => "es",
        "it-IT" => "it",
        "vi-VN" => "vi",
        "zh-Hant-TW" => "zh-TW",
        "en-AA" => "en",
        "en-NZ" => "en",
        "en-US" => "en",
        "fr-FR" => "fr",
        "ko-KR" => "ko",
        "zh-Hans-CN" => "zh-CN",
        "en-AU" => "en",
        "en-PH" => "en",
        "es-ES" => "es",
        "id-ID" => "id",
        "pt-BR" => "PORTUGUESE",
        "zh-Hant-HK" => "zh-CN",
      }
    end
    
    #
    # Finds English language translation keys which have not been translated 
    # and translates them through Google Translate.
    #
    class Base
      include YMDP::FileSupport
      extend YMDP::FileSupport
      include YMDP::Translator::Support

      def self.original_translations
        Dir["#{language_path('en-US')}/#{all_source_files}"]
      end
      
      def self.all_source_files
        raise "Define in child"
      end
      
      def self.template
        raise "Define in child"
      end
      
      def self.translate
        time do
          original_translations.each do |path|
            puts "Processing #{display_path(path)}"
            template.new(path).copy
          end
        end
      end
      
      # instance methods
      
      attr_accessor :path, :lang, :filename
    
      def initialize(path)
        @path = path
        @lang = language(path)
        @filename = base_filename(path)
      end
      
      def copy
        copy_lines_to_all_locales
      end
      
      def non_english_locales
        @non_english_locales ||= LOCALES.select do |lang, code|
          lang !~ /^en/
        end
      end
      
      def non_us_locales
        @non_us_locales ||= LOCALES.select do |lang, code|
          lang != "en-US"
        end
      end

      def copy_lines_to_all_locales
        non_us_locales.each do |lang, code|
          destination = destination_path(filename, lang)
          new_content = each_line do |line|
            copy_and_translate_line(line, lang)
          end
          write_content(destination, new_content)
          clear_all_keys
        end
      end
      
      def write_content(destination, content)
        unless content.blank?
          puts "Writing to #{display_path(destination)}"
          puts content
          puts
          File.open(destination, "a") do |f|
            f.puts
            f.puts new_translation_message
            f.puts content
          end
        end        
      end
      
      def new_translation_message
        now = Time.now
        
        date = now.day
        month = now.month
        year = now.year
        
        timestamp = "#{date}/#{month}/#{year}"
        output = []
        output << "# "
        output << "# Keys translated automatically on #{timestamp}."
        output << "# "
        
        output.join("\n")
      end
      
      def each_line
        output = []
        File.open(path, "r") do |f|
          f.readlines.each do |line|
            new_line = yield line
            output << new_line
          end
        end
        output.flatten.join("\n")
      end
      
      def all_keys(lang)
        unless @all_keys
          @all_keys = {}
          Dir["#{language_path(lang)}/#{all_source_files}"].each do |p|
            @all_keys = @all_keys.merge(parse_template(p))
          end
        end
        @all_keys
      end
      
      def self.all_source_files
        raise "Define in child"
      end
      
      def parse_template(p)
        raise "Define in child"
      end
      
      def clear_all_keys
        @all_keys = nil
      end
    
      def copy_and_translate_line(line, lang)
        line = line.split("\n").first
        if comment?(line) || line.blank?
          nil
        else
          translate_new_key(line, lang)
        end
      end
      
      def translate_new_key(line, lang)
        k, v = key_and_value_from_line(line)
        if k && !all_keys(lang).has_key?(k)
          format(k, translate(v, lang))
        else
          nil
        end        
      end
      
      def translate(value, lang)
        code = LOCALES[lang]
        value = pre_process(value, lang)
        translation = Translate.t(value, "ENGLISH", code)
        post_process(translation, lang)
      end
      
      def pre_process(value, lang)
        while value =~ /(\{\{[^\{]*\}\})/
          vars << $1
          value.sub!(/(\{\{[^\{]*\}\})/, "[#{index}]")
          index += 1
        end
        value
      end
      
      def post_process(value, lang)
         if lang =~ /zh/
          value.gsub!("<strong>", "")
          value.gsub!("</strong>", "")
        end
  
        value.gsub!(/^#{194.chr}#{160.chr}/, "")
  
        value.gsub!(" ]", "]")
        value.gsub!("«", "\"")
        value.gsub!("»", "\"")
        value.gsub!(/\"\.$/, ".\"")
        value.gsub!(/\\ \"/, "\\\"")
        value.gsub!(/<\/ /, "<\/")
        value.gsub!(/(“|”)/, "\"")
        value.gsub!("<strong> ", "<strong>")
        value.gsub!(" </strong>", "</strong>")
        value.gsub!("&quot;", "\"")
        value.gsub!("&#39;", "\"")
        value.gsub!("&gt; ", ">")
        
        value.gsub!("\"", "'")
        value.gsub!(" \"O", " \\\"O")
  
        while value =~ /\[(\d)\]/
          index = $1.to_i
          value.sub!(/\[#{index}\]/, vars[index])
        end
    
        value.gsub!(/\((0)\)/, "{0}")
        value.gsub!(/\((1)\)/, "{1}")
        value.gsub!(/\((2)\)/, "{2}")
        value.gsub!("（0）", "{0}")
  
        value.strip
      end
      
      def format(key, value)
        raise "Define in child"
      end
      
      def key_and_value_from_line(line)
        raise "Define in child"
      end
    
      def comment?(line)
        raise "Define in child"
      end    
    end
    
    # Usage: 
    #   YMDP::Translator::Yaml.new().translate
    #
    class Yaml < Base
      include YMDP::Yaml::Support
      extend YMDP::Yaml::Support
      
      def self.template
        Yaml
      end
      
      def self.all_source_files
        "*.yml"
      end
      
      def all_source_files
        "*.yml"
      end
      
      def parse_template(path)
        YAML.load_file(path)
      end
      
      def format(key, value)
        "#{key}: #{value}"
      end
      
      def key_and_value_from_line(line)
        if line =~ /^([^\:]+):(.*)/
          return $1, $2.strip
        else
          return nil, nil
        end
      end
    
      def comment?(line)
        line =~ /^[\s]*#/
      end
    end
    
    # Usage: 
    #   YMDP::Translator::YRB.new().translate
    #
    class YRB < Base
      include YMDP::YRB::Support
      extend YMDP::YRB::Support
      
      def self.template
        YRB
      end
      
      def self.all_source_files
        "*.pres"
      end
      
      def all_source_files
        "*.pres"
      end
      
      def parse_template(p)
        YRBTemplate.new(p).to_hash
      end
      
      def format(key, value)
        "#{key}=#{value}"
      end
      
      def translate(value, lang)
        unless value.blank?
          super(value, lang)
        end
      end
      
      def key_and_value_from_line(line)
        if line =~ /^([^\=]+)=(.+)/
          return $1, $2
        else
          return nil, nil
        end
      end
    
      def comment?(line)
        line =~ /^[\s]*#/
      end
    end
  end
end