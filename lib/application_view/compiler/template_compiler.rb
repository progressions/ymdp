include Grit

include ApplicationView::Config
include Timer

class GitHelper
  def get_hash(branch)
    branch = get_current_branch || "master"
    repo = Repo.new("#{YMDP_ROOT}/.")
    repo.commits(branch).first.id
  end

  def get_current_branch
    result = `git status`
    if result =~ /# On branch (.*)/
      return $1
    end
  end

  def do_commit(message)
    repo = Repo.new(".")
    repo.add(".")
    puts `git commit -am "#{message}"`
  end
end

module TemplateBuilder
  def initialize(file, domain="staging", git_hash="", message="", verbose=false, subdir=false)
    @verbose = verbose
    @domain = domain
    @server = SERVERS[@domain]["server"]
    @file = file
    @assets_directory = "/om/assets/#{SERVERS[@domain]['assets_id']}"
    @hash = git_hash
    @message = message
    @subdir = subdir
    @version = CONFIG["version"]
    @sprint_name = CONFIG["sprint_name"]
    @view = base_filename(@file.split("/").last)
    Application.current_view = @view
  end

  def build
    unless @file =~ /#{YMDP_ROOT}\/app\/views\/_/
      write_template(processed_template)
    end
  end
  
  def processed_template
    result = ""
    File.open(@file) do |f|
      template = f.read
      if @file =~ /\.haml$/
        result = process_haml(template, @file)
      else
        result = process_template(template)
      end
    end
    result
  end

  private
  
  def process_template(template)
    raise "Define in child"
  end
  
  def output_filename
    filename = convert_filename(@file.split("/").last)
    
    dir = "#{YMDP_ROOT}/servers/#{@domain}"
    directory = @file.gsub(/^\.\/app/, dir).gsub(/\/([^\/]+)$/, '')
    
    FileUtils.mkdir_p(directory)
    "#{directory}/#{filename}"    
  end
  
  def write_template_without_layout(result)
    path = output_filename
    
    File.open(path, "w") do |f|
      f.write(result)
    end
    $stdout.puts "Finished writing #{path}.\n" if @verbose
  end
  
  def write_template_with_layout(result)
    @content = result
    application_layout = "#{YMDP_ROOT}\/app\/views\/layouts\/application.html.haml"
    if File.exists?("#{YMDP_ROOT}\/app\/views\/layouts\/application.html.haml")
      layout = File.open(application_layout) do |f|
        template = f.read
        process_haml(template, application_layout)
      end
    elsif File.exists?("#{YMDP_ROOT}\/app\/views\/layouts\/application.html.erb")
      layout = File.open(application_layout) do |f|
        template = f.read
        process_template(application_layout)
      end
    end
    write_template_without_layout(layout)
  end
  
  def write_template(result)
    write_template_with_layout(result)
  end
end

class YMDPTemplate
  include ActionView::Helpers::TagHelper
  include TemplateBuilder
  include ApplicationHelper
  include ApplicationView::Base
  include ApplicationView::AssetTagHelper
  include ApplicationView::FormTagHelper
  include ApplicationView::LinkTagHelper
  
  attr_accessor :output_buffer
  
  private
  
  def base_filename(filename)
    filename.gsub(/(\.html|\.erb|\.haml)/, "")
  end
  
  def convert_filename(filename)
    base_filename(filename)
  end
  
  def process_template(template)
    ERB.new(template, 0, "%<>").result(binding)
  end
  
  def process_haml(template, filename=nil)
    options = {}
    if filename
      options[:filename] = filename
    end
    Haml::Engine.new(template, options).render(self)
  end
  
  def write_template(result)
    write_template_with_layout(result)
    ApplicationView::Validator::HTML.validate(output_filename) if validate_html?
  end
end

class JSTemplate < YMDPTemplate
  def compress_js(filename)
    if compress_js_assets?
      validate_filename = "#{filename}.min"
      ApplicationView::Compressor::JavaScript.compress(filename)
    end
  end
    
  def write_template(result)
    filename = @file.split("/").last
    tmp_filename = "./tmp/#{filename}"
    save_to_file(result, tmp_filename)
    result = ApplicationView::Compressor::JavaScript.compress(tmp_filename) || result
    write_template_without_layout(result)
  end
end


class YRBTemplate
  include TemplateBuilder
  
  def directory
    directory = "#{BASE_PATH}/servers/#{@domain}/assets/yrb"
    FileUtils.mkdir_p(directory)
    directory
  end
  
  def output_filename
    filename = convert_filename(@file.split("/").last)
    "#{directory}/#{filename}"
  end  
  
  def to_json
    processed_template
  end
  
  def to_hash
    JSON.parse(to_json)
  end
  
  def to_yaml
    h = {}
    to_hash.each do |k,v|
      k = k.downcase
      h[k] = "#{v}"
    end
    h.to_yaml
  end
  
  def processed_template
    super.to_json
  end
  
  def validate
    ApplicationView::Validator::JSON.validate(output_filename)
  end
  
  private
  
  def base_filename(filename)    
    filename.gsub(/\.pres/, "")
  end
  
  def convert_filename(filename)
    "#{base_filename(filename)}.json"
  end
  
  def process_template(template)
    @hash = {}
    lines = template.split("\n")
    lines.each do |line|
      unless line =~ /^[\s]*#/
        line =~ /^([^\=]+)=(.+)/
        key = $1
        value = $2
        unless key.blank?
          if @hash.has_key?(key)
            puts
            puts "Duplicate value in #{output_filename}"
            puts "  #{key}=#{@hash[key]}"
            puts "  #{key}=#{value}"
            puts
            if @hash[key] == value
              puts "  Values are the same but duplicate values still should not exist!"
              puts
            end
            raise "Duplicate key error"
          end
          @hash[key] = value
        end
      end
    end
    @hash
  end
  
  def write_template(result)
    puts output_filename if verbose?
    write_template_without_layout(result)
  end
end

class TemplateCompiler
  attr_accessor :domain, :git_hash, :options
  
  def self.compile
    time do
      system "rm ./tmp/*"
    
      options = parse_options
    
      domain = options[:domain]
      domains = SERVERS.keys

      git = GitHelper.new

      if options[:commit]
        git.do_commit(options[:message])
      end

      git_hash = git.get_hash(options[:branch])

      if domain
        domains = [domain]
      end
    
      process_domains(domains, git_hash, options)
    
      system "rm ./tmp/*"
    end
  rescue StandardError => e
    puts e.message
    puts e.backtrace
  end
  
  def self.parse_options
    options = {
      :commit => false,
      :branch => "master"
    }
    OptionParser.new do |opts|
      options[:commit] = false
      options[:verbose] = verbose?
      opts.banner = "Usage: build.rb [options]"

      opts.on("-d", "--domain [domain]", "Force Domain") do |v|
        options[:domain] = v
      end
      opts.on("-b", "--branch [branch]", "Current Branch") do |v|
        options[:branch] = v
      end
      opts.on("-m", "--message [message]", "Commit Message") do |v|
        options[:commit] = true
        options[:message] = v
      end
      opts.on("-n", "--no-commit", "Don't Commit") do |v|
        options[:commit] = false
      end
      opts.on("-v", "--verbose", "Verbose (show all file writes)") do |v|
        options[:verbose] = true
      end
      opts.on("-r", "--rake [task]", "Execute Rake task") do |v|
        options[:rake] = v
      end
      opts.on("-c", "--compress", "Compress JavaScript and CSS") do |v|
        options[:compress] = v
      end
    end.parse!
    
    options
  end
  
  def self.process_domains(domains, git_hash, options)
    domains.each do |d|
      clean_domain(d)
      
      compiler = self.new(d, git_hash, options)
  
      ["views", "assets"].each do |dir|
        compiler.process("#{YMDP_ROOT}/app/#{dir}/")
      end
      process_yrb(d, git_hash, options)
    end
    
    if options[:rake]
      system "rake #{options[:rake]}"
    end
  end
  
  def self.process_yrb(domain, hash, options)
    puts "Processing ./app/assets/yrb/ for #{domain}"
    ApplicationView::Base.supported_languages.each do |lang|
      process_each_yrb(lang, domain, hash, options)
    end
  end
  
  def self.process_each_yrb(lang, domain, hash, options)
    tmp_file = "#{TMP_DIR}/keys_#{lang}.pres"
    Dir["#{BASE_PATH}/app/assets/yrb/#{lang}/*"].each do |path|
      system "cat #{path} >> #{tmp_file}"
    end
    yrb = YRBTemplate.new(tmp_file, domain, hash, options[:message], options[:verbose])
    yrb.build
    yrb.validate
    system "rm #{tmp_file}"
  end
  
  def self.clean_domain(d)
    dir = "#{YMDP_ROOT}/servers/#{d}"
    system "rm -rf #{dir}/views"
    system "rm -rf #{dir}/assets/javascripts"
    system "rm -rf #{dir}/assets/stylesheets"
    system "rm -rf #{dir}/assets/yrb"
    system "rm #{TMP_DIR}/*"
  end

  def log(text)
    "#{Time.now.to_s} #{text}"
  end
  
  def initialize(domain, git_hash, options)
    @domain = domain
    @git_hash = git_hash
    @options = options
  end
  
  def create_directory(path)
    dest = destination(path)
    
    if File.exists?("#{YMDP_ROOT}/#{path}")
      # puts "     exists #{path}"
    else
      puts "     create #{path}"
      FileUtils.mkdir_p "#{YMDP_ROOT}/#{path}"
    end
  end
  
  def destination(path)
    destination = path.dup
    destination.gsub!("#{YMDP_ROOT}/app", "#{YMDP_ROOT}/servers/#{domain}")
  end

  def process(path)
    puts "Processing #{path} for #{domain}"
    dest = destination("#{path}")
    create_directory("servers/#{domain}")
    Dir["#{path}**/*"].each do |f|
      build_file(f)
    end
    copy_images
  end
  
  def copy_images
    if options[:verbose]
      puts log("Moving images into #{YMDP_ROOT}/servers/#{domain}/assets/images...")
    end
    system "rm -rf #{YMDP_ROOT}/servers/#{domain}/assets/images"
    system "cp -r #{YMDP_ROOT}/app/assets/images #{YMDP_ROOT}/servers/#{domain}/assets"
  end
  
  def build_file(file)
    if file.split("/").last !~ /^_/ && file !~ /\/app\/views\/layouts\//
      if file =~ /(\.haml|\.erb)$/
        YMDPTemplate.new(file, domain, git_hash, options[:message], options[:verbose]).build
      elsif file =~ /\.js$/
        JSTemplate.new(file, domain, hash, options[:message], options[:verbose]).build
      end
    end
  end
end

