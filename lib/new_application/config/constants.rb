LOCALE_CODES = ["en-US","de-DE","en-AA","en-AU","en-MY","en-NZ","en-PH","en-SG","es-ES","es-MX","fr-FR","id-ID","it-IT","ko-KR","pt-BR","vi-VN","zh-Hans-CN","zh-Hant-HK","zh-Hant-TW"] unless defined?(LOCALE_CODES)

LOCALES = {
    "en-US" => "English (United States)",
    "en-AA" => "English (Asia)",
    "en-AU" => "English (Australia)",
    "en-MY" => "English (Malaysia)",
    "en-NZ" => "English (New Zealand)",
    "en-PH" => "English (Phillippines)",
    "en-SG" => "English (Singapore)",
    "de-DE" => "German",
    "es-ES" => "Spanish (Spain)",
    "es-MX" => "Spanish (Mexico)",
    "fr-FR" => "French",
    "id-ID" => "Indonesian",
    "it-IT" => "Italian",
    "ko-KR" => "Korean",
    "pt-BR" => "Portuguese",
    "vi-VN" => "Vietnamese",
    "zh-Hans-CN" => "Chinese (China)",
    "zh-Hant-HK" => "Chinese (Hong Kong)",
    "zh-Hant-TW" => "Chinese (Taiwan)"
} unless defined?(LOCALES)

SORTED_LOCALES = LOCALES.sort do |a,b|
  a[1] <=> b[1]
end unless defined?(SORTED_LOCALES)

YMDP_ROOT = "." unless defined?(YMDP_ROOT)

def file_not_found(filename)
  puts
  puts "Create #{filename} with the following command:\n\n  ./script/config" 
  puts
  
  raise "File not found: #{filename}"  
end

servers = "#{YMDP_ROOT}/config/servers.yml"
config = "#{YMDP_ROOT}/config/config.yml"

if File.exists?(servers)
  SERVERS = YAML.load_file("#{YMDP_ROOT}/config/servers.yml") unless defined?(SERVERS)
else
  file_not_found(servers)
end

if File.exists?(config)
  CONFIG = YAML.load_file("#{YMDP_ROOT}/config/config.yml")["config"] unless defined?(CONFIG)
else
  file_not_found(config)
end

TMP_DIR = "./tmp" unless defined?(TMP_DIR)
