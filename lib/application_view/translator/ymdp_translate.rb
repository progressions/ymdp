class YmdpTranslate
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


  def self.translate(value, ymdp_lang) 
    error_results = []
    
    lang = YmdpTranslate::LOCALES[ymdp_lang] || "en"
    return value if lang =~ /en-/
    
    index = 0
    vars = []
    value ||= ""
    while value =~ /(\{\{[^\{]*\}\})/
      vars << $1
      value.sub!(/(\{\{[^\{]*\}\})/, "[#{index}]")
      index += 1
    end
    result = Translate.t(value, "ENGLISH", lang)
  
    if lang =~ /zh/
      result.gsub!("<strong>", "")
      result.gsub!("</strong>", "")
    end
  
    result.gsub!(" ]", "]")
    result.gsub!("«", "\"")
    result.gsub!("»", "\"")
    result.gsub!(/\"\.$/, ".\"")
    result.gsub!(/\\ \"/, "\\\"")
    result.gsub!(/<\/ /, "<\/")
    result.gsub!(/(“|”)/, "\"")
    result.gsub!("<strong> ", "<strong>")
    result.gsub!(" </strong>", "</strong>")
    result.gsub!("&quot;", "\"")
    result.gsub!("&#39;", "\"")
    result.gsub!("&gt; ", ">")
  
    result.gsub!("l\"a", "l'a")
    result.gsub!("l\"o", "l'o")
    result.gsub!("l\"e", "l'e")
    result.gsub!("L\"e", "L'e")
    result.gsub!("l\"i", "l'i")
    result.gsub!("l\"h", "l'h")
    result.gsub!("c\"e", "c'e")
    result.gsub!("d\"u", "d'u")
    result.gsub!("d\"a", "d'a")
    result.gsub!("d\"e", "d'e")
    result.gsub!("u\"e", "u'e")
    result.gsub!("d\"o", "d'o")
    result.gsub!("D\"o", "D'o")
    result.gsub!("n\"a", "n'a")
    result.gsub!("n\"é", "n'é")
    result.gsub!("j\"a", "j'a")
    result.gsub!("S\"i", "S'i")
    result.gsub!(" \"O", " \\\"O")  
  
    while result =~ /\[(\d)\]/
      index = $1.to_i
      result.sub!(/\[#{index}\]/, vars[index])
    end
    
    result.gsub!("(0)", "{0}")
    result.gsub!("（0）", "{0}")
  
    if result =~ /#{160.chr}/
      result.gsub!(/^#{194.chr}#{160.chr}/, "")
    end
  
    result.strip
  end
end
