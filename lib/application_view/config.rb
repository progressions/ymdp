module ApplicationView
  module Config
    def compress_embedded_js?
      CONFIG["compress"]["embedded_js"]
    end
    
    def compress_js_assets?
      CONFIG["compress"]["js_assets"]
    end
    
    def compress_css?
      CONFIG["compress"]["css"]
    end
    
    def validate_embedded_js?
      CONFIG["validate"]["embedded_js"][YMDP_ENV]
    end
    
    def validate_js_assets?
      CONFIG["validate"]["js_assets"][YMDP_ENV]
    end
    
    def validate_json_assets?
      CONFIG["validate"]["json_assets"][YMDP_ENV]
    end
    
    def validate_html?
      CONFIG["validate"]["html"][YMDP_ENV]
    end
    
    def obfuscate?
      CONFIG["compress"]["obfuscate"]
    end
    
    def verbose?
      CONFIG["verbose"]
    end
  end
end