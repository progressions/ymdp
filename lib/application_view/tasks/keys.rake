require 'lib/init'

require 'translator/base'

@key = ENV["key"] || ""
@key = @key.upcase

ASSETS_ROOT = "#{YMDP_ROOT}/app/assets"
YRB_ROOT = "#{ASSETS_ROOT}/yrb"

namespace :keys do
  task :add_new do
    Dir["./app/assets/yrb/*.pres"].each do |path|
      # system "cat app/assets/new/keys_en-US.pres >> app/assets/yrb/keys_en-US.pres"
      new_path = path.gsub("yrb", "new")
      system "cat #{new_path} >> #{path}"
    end
  end
  
  task :new_since do
    @date = ENV["date"]
    if @date
      change_keys do |line|
        puts line
        if line =~ /#{@date}/
          @on ||= true
        end
        line if @on
      end
    else
      message = "Must define a date with 'date='"
      growl(message)
      raise message
    end
  end
  
  task :combine do
    system "rm #{TMP_DIR}/*"
    each_locale do |path|
      puts path
      filename = path.split("/").last
      lang = "en-US"
      if filename =~ /_(.*)\.pres/
        lang = $1
      end
      
      File.open(path, "r") do |f|
        File.open("#{TMP_DIR}/keys_#{lang}.pres", "a") do |tmp|
          tmp.write(f.read)
        end
      end
    end
    
    system "rm -rf #{YRB_ROOT}/*"
    system "cp #{TMP_DIR}/* #{YRB_ROOT}"
    
    system "rm #{TMP_DIR}/*"
  end
  
  task :destroy do
    system "rm #{TMP_DIR}/*"
    
    raise "Must define a key with 'key='" if @key == ""
    
    change_keys do |line|
      line_array = parse_yrb(line)
      
      if line_array[0] == @key
        line = ""
      end
      
      line
    end
    
    system "rm #{TMP_DIR}/*"
  end
  
  desc "Translate any new keys into non-US languages"
  task :translate do
    ApplicationView::Translator::YRB.translate
  end
  
  task :rename do
    system "rm #{TMP_DIR}/*"
    
    @to = ENV["to"] || ""
    @to = @to.upcase
    
    raise "Must define a key with 'key='" if @key == ""
    raise "Must define a new key name with 'to='" if @to == ""
    
    change_keys do |line|
      line_array = parse_yrb(line)
      
      if line_array[0] == @key
        line = "#{@to}=#{line_array[1]}"
      end
      
      line
    end
    
    system "rm #{TMP_DIR}/*"
  end
  
  # task :unused do
  #   # this probably would be more complicated than it's worth
  #   
  #   keys = []
  #   unused_keys = []
  #   File.open("#{YRB_ROOT}/keys_en-US.pres", "r") do |f|
  #     f.readlines.each do |line|
  #       key = parse_yrb(line).first
  #       keys << key unless key.blank?
  #     end
  #   end
  #   
  #   keys.each do |key|
  #     puts "grep #{key} ./servers/* -R -i"
  #     if `grep #{key} ./servers/* -R -i`.length < 10
  #       puts "OMG"
  #     end
  #   end
  # end
  
  task :list do
    each_locale do |path|
      filename = path.split("/").last
      lang = "en-US"
      if filename =~ /_(.*)\.pres/
        lang = $1
      end
    
      puts lang
      
      File.open(path, "r") do |f|
        f.readlines.each do |line|
          puts line if line =~ /^#{@key}=/
        end
      end
    end
  end
  
  task :convert_to_yml do
    each_locale do |path|
      # puts path
      filename = path.split("/").last
      lang = "en-US"
      if filename =~ /_(.*)\.pres/
        lang = $1
      end
    
      puts "#{lang}:"
      
      File.open(path, "r") do |f|
        f.readlines.each do |line|
          if @key.blank? || line =~ /^#{@key}=/
            k,v = parse_yrb(line)
            puts "      #{k.downcase}: #{v}"
          end
        end
      end
    end
  end
end

def change_keys
  each_locale do |path|
    @on = false
    puts path
    filename = path.split("/").last
    File.open(path, "r") do |f|
      File.open("#{TMP_DIR}/#{filename}", "w") do |tmp|
        f.readlines.each do |line|
          new_line = yield line
          tmp.write new_line
        end
      end
    end
    system "cp #{TMP_DIR}/#{filename} #{path}"
  end
end

def change_keys_with_lang
  each_locale do |path|
    puts path
    filename = path.split("/").last
    lang = "en-US"
    if filename =~ /_(.*)\.pres/
      lang = $1
    end
    File.open(path, "r") do |f|
      File.open("#{TMP_DIR}/#{filename}", "w") do |tmp|
        f.readlines.each do |line|
          new_line = yield line, lang, filename
          tmp.write new_line
        end
      end
    end
    system "cp #{TMP_DIR}/#{filename} #{path}"
  end
end

def parse_yrb(line)
  key = value = nil
  unless line =~ /#/
    tokens = line.split("=")
    key = tokens.shift
    value = tokens.join("=")
  end
  [key, value]
end

def each_locale
  Dir["#{YRB_ROOT}/*.pres"].each do |path|
    yield path
  end  
end

def to_yrb(key, value)
  "#{key}=#{value}\n"
end

def yrb_to_hash(path)
  hash = {}
  File.open(path, "r") do |f|
    f.readlines.each do |line|
      k, v = parse_yrb(line)
      
      if k
        hash[k] = v
      end
    end
  end
  hash
end

