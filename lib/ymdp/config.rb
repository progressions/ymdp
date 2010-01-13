module YMDP
  module Config
    def config(*args)
      c = CONFIG
      
      missing_option_index = 0
      
      args.each_with_index do |arg, i|
        if c.is_a?(Hash) && c.has_key?(arg)
          c = c[arg]
        else
          missing_option_index = i
          raise "Configuration option not found."
        end
      end
      
      c
    rescue 
      puts "The following configuration option was not found in config.yml:"
      (0..missing_option_index).each do |i|
        puts args[i]
      end
      puts
      puts "Are you sure your config.yml is up to date?"
      puts
      raise "Configuration option not found."
    end
        
    def compress_embedded_js?
      config("compress", "embedded_js")
    end
    
    def compress_js_assets?
      config("compress", "js_assets")
    end
    
    def compress_css?
      config("compress", "css")
    end
    
    def validate_embedded_js?
      config("validate", "embedded_js", YMDP_ENV)
    end
    
    def validate_js_assets?
      config("validate", "js_assets", YMDP_ENV)
    end
    
    def validate_json_assets?
      config("validate", "json_assets", YMDP_ENV)
    end
    
    def validate_html?
      config("validate", "html", YMDP_ENV)
    end
    
    def obfuscate?
      config("compress", "obfuscate")
    end
    
    def verbose?
      config("verbose")
    end
    
    def growl?
      config("growl")
    end
  end
end