include YMDP::Config

begin
  CATEGORIES = YAML.load_file("./config/categories.yml")["categories"] unless defined?(CATEGORIES)
rescue
  CATEGORIES = {} unless defined?(CATEGORIES)
end

Dir.mkdir(TMP_DIR) rescue Errno::EEXIST

def set_application_variables(application)
  @application = application
  @application_id = SERVERS[@application]["application_id"]
  @assets_id = SERVERS[@application]["assets_id"]
  @dir = @application
rescue
end

def create_from_servers
  SERVERS.keys.each do |key|
    yield key.to_sym, "set_#{key}".to_sym
  end
end

def create_from_default_server
  yield @default_server
end

def create_from_categories(task_name)
  CATEGORIES.keys.each do |category|
    desc "#{task_name.to_s.capitalize} the #{category}"
    task category.to_sym => ["set_#{category}", task_name]
  end
end

# rake deploy app=staging PATH=views/settings
# rake deploy app=my 

@username = CONFIG["username"]
@password = CONFIG["password"]

unless @username
  puts
  puts "Enter your username in ./config/config.yml" 
  puts
  raise "Username not found."
end

unless @password
  puts
  puts "Enter your password in ./config/config.yml" 
  puts
  raise "Password not found."
end


@default_server = CONFIG["default_server"] || "staging"
@application = ENV["app"] || @default_server
set_application_variables(@application)
@path = ENV["path"] || ENV["p"] || ""
@dry_run = ENV["dry_run"]
@confirm = ENV["confirm"]
@build_message = ENV["build"]
@view = ENV["view"]
@lang = ENV["lang"]

@sync = ENV["sync"]

@validate_html = (ENV["validate_html"] || CONFIG["validate_html"].to_s) != "false"
@validate_js_assets = (ENV["validate_js_assets"] || CONFIG["validate_js_assets"].to_s) != "false"
@validate_json_assets = (ENV["validate_json_assets"] || CONFIG["validate_json_assets"].to_s) != "false"
@validate_embedded_js = (ENV["validate_embedded_js"] || CONFIG["validate_embedded_js_deploy"].to_s) != "false"

create_from_servers do |key, set_task|
  task set_task do
    set_application_variables(key.to_s)
  end
end

desc "Default task shows documentation"
task :default do
  docs = <<-DOCS
USAGE: rake TASK [app={application}] [path={path}], [dry_run=true], [dir={directory}], [application_id={app_id}] [skip_validation=true]

GETTING STARTED:

  1. First, copy the config.yml.example file to config.yml with the command:
  
    ./script/config
    
  2. Enter the correct username and password in ./config/config.yml

  3. Download local copies of all our remote applications from YMDP:
  
    rake create:all
  
  4. Edit the HTML template in the subdirectories "app/views" and "app/assets".
  
  5. To build the views and javascript files from edited templates, and commit the changes:
  
    ./script/build -m "<commit_message>" 

  6. To deploy your local changes to the staging server:
  
    rake deploy:views
    rake deploy:javascripts

DOCS
  puts docs
end

desc "Some more help"
task :help do
  docs = <<-DOCS
      
#{please_install_rhino}

FOR HELP:

  To list reference for all tasks:

    rake tasks

  To get help for a specific command (this is still in progress):
  
    rake create:help
    rake deploy:help
    rake validate:help

DOCS
  puts docs
end

desc "Show usage for tasks"
task :tasks do
  docs = <<-DOCS
USAGE: rake TASK [app={application}] [path={path}], [dry_run=true], [dir={directory}], [application_id={app_id}]

VALID TASKS:

  create          creates a new local copy of an existing YMDP application
  deploy          deploys local copy of YMDP application to remote server
  validate        validates javascript assets

The "create" and "deploy" tasks can be subtasked with the name of a server:

  create:my       create a new local copy of the production application
  deploy:staging  deploy local changes to the staging application
  
The "validate" task can be subtasked with "all" to validate all the javascripts for the given server:

  validate:all    validates all our javascript assets for the given server (including JSON)

DOCS
  # TODO: add more documentation

  puts docs
end

def time(message="")
  Timer.new(:title => "YMDP").time(message) do
    yield
  end
end

desc "Deploys application to YMDP servers"
task :deploy do
  time("Deployed #{@application}: #{@path}") do
    deploy(@application, @path)
  end
end

desc "Deploys application to YMDP servers, matching a path"
task :deploy_path do
  time("Deployed #{@application}: #{@path}") do
    deploy_path(@application, @path)
  end
end

task :deploy_yrb do
  time("Deployed #{@application}: #{@path}") do
    deploy_yrb(@application, @path, {:lang => @lang, :view => @view})
  end
end

desc "List files"
task :list_assets do
  puts list(@application, @path)
end
    
desc "Quality-control to determine if all the assets have the same ID"
task :check_assets do
  report_asset_ids(@application, @path)
end

desc "Update remote assets which don't match the correct asset ID"
task :fix_assets do
  fix_assets(@application, @path)
end

desc "Validates all javascripts"
task :validate => "validate:all"


namespace :check_assets do
  create_from_servers do |key, set_task|
    desc "Check asset IDs on #{key} server"
    task key => [set_task, :check_assets]
  end
end

namespace :fix_assets do
  create_from_servers do |key, set_task|
    desc "Update remote assets which don't match the correct asset ID on #{key} server"
    task key => [set_task, :fix_assets]
  end
end

namespace :list_assets do
  create_from_servers do |key, set_task|
    desc "List files from #{key} application"
    task key => [set_task, :list]
  end

  create_from_servers do |key, set_task|
    namespace key do
      desc "Lists views from the #{key} server"
      task :views => [set_task, :set_views, :list_assets]
  
      desc "Lists all assets from the #{key} server"
      task :assets => [set_task, :set_assets, :list_assets]
  
      desc "Lists javascript assets from the #{key} server"
      task :javascripts => [set_task, :set_javascripts, :list_assets]
  
      desc "Lists image assets from the #{key} server"
      task :images => [set_task, :set_images, :list_assets]
    
      desc "Lists YRB bundles from the #{key} server"
      task :yrb => [set_task, :set_yrb, :list_assets]
  
      desc "Lists everything except images from the the #{key} server"
      task :code => ["list_assets:#{key}:views", :skip_validation, "list_assets:#{key}:javascripts", "list_assets:#{key}:yrb"]
    end
  end
  
  create_from_categories(:list)
end

namespace :validate do
  create_from_servers do |key, set_task|
    namespace key do
      desc "Validates all javascripts (excluding prototype/scriptaculous)"
      task :javascripts => [set_task, "validate:javascripts"]
      
      desc "Validates all JSON"
      task :json => [set_task, "validate:json"] do
      end
      
      desc "Validates all HTML"
      task :html => [set_task,"validate:html"] do
      end

      desc "Validates all embedded JavaScript"
      task :embedded_js => [set_task,"validate:embedded_js"] do
      end
      
      desc "Validates all javascripts and JSON and HTML"
      task :all => [set_task, "validate:all"]
    end
  end

  desc "Validates all javascripts (excluding prototype/scriptaculous)"
  task :javascripts do
    puts "\nValidating external JavaScript assets in #{@application}..."
    Dir["#{BASE_PATH}/servers/#{@application}/assets/javascripts/*.js"].each do |path|
      YMDP::Validator::JavaScript.validate(path)
    end
  end

  desc "Validates all JSON"
  task :json do
    puts "\nValidating JSON in #{@application}..."
    Dir["./servers/#{@application}/assets/yrb/*json"].each do |json|
      filename = json.split("/").last
      path = "#{BASE_PATH}/servers/#{@application}/assets/yrb/#{filename}"
      YMDP::Validator::JSON.validate(path)
    end    
  end

  desc "Validates all HTML"
  task :html do
    puts "\nValidating HTML in #{@application}..."
    `rm -rf #{TMP_DIR}`
    Dir.mkdir(TMP_DIR) rescue Errno::EEXIST
    Dir["./servers/#{@application}/views/*"].each do |filename|
      YMDP::Validator::HTML.validate(filename) if filename =~ /#{@path}/
    end    
  end

  desc "Validates all JavaScript inside HTML"
  task :embedded_js do
    if @path =~ /views/
      validate_path = @path.gsub(/views\/$/, "/*")
    else
      validate_path = "views/*"
    end
    puts "\nValidating embedded JavaScript in #{@application}..."
    Dir["./servers/#{@application}/views/*"].each do |filename|
      validated_embedded_js(filename) if filename =~ /#{@path}/
    end
  end

  desc "Validates all javascripts and JSON"
  task :all => ["validate:javascripts", "validate:json", "validate:html", "validate:embedded_js"]
end

task :set_yrb do
  @path = "assets/yrb/"
end

task :set_sync do
  @sync = true
end

desc "Syncs default server"
task :sync => [:set_sync, :deploy]

namespace :sync do
  create_from_servers do |key, set_task|
    desc "Syncs application with #{key} server"
    task key => [set_task, :set_sync, :deploy]
  end

  create_from_servers do |key, set_task|
    namespace key do
      desc "Syncs views to the #{key} server"
      task :views => [set_task, :set_views, :set_sync, :deploy]
  
      desc "Syncs all assets to the #{key} server"
      task :assets => [set_task, :set_assets, :set_sync, :deploy]
  
      desc "Syncs javascript assets to the #{key} server"
      task :javascripts => [set_task, :set_javascripts, :set_sync, :deploy]
  
      desc "Syncs image assets to the #{key} server"
      task :images => [set_task, :set_images, :set_sync, :deploy]
    
      desc "Syncs YRB bundles to the #{key} server"
      task :yrb => [set_task, :set_yrb, :set_sync, :deploy_yrb]
  
      desc "Syncs everything except images to the the #{key} server"
      task :code => [set_task, "deploy:#{key}:views", :skip_validation, "deploy:#{key}:javascripts", "deploy:#{key}:yrb"]
    end
  end
  
  task :yrb => [:set_yrb, :set_sync, :deploy_yrb]
  
  create_from_categories(:sync)
end

namespace :deploy do
  desc "Show shows documentation"
  task :help do
    docs = <<-DOCS
  USAGE: rake deploy [app={application}] [path={path}], [dry_run=true], [dir={directory}], [application_id={app_id}]

  Deploys the local application to the remote YMDP servers. Validates javascript assets beforehand, aborting the deploy in case of validation errors. 

  Run without options, the default is to deploy everything to the staging server.

  Specify the application to deploy to:
    rake deploy app=staging
    rake deploy app=my
    rake deploy app=alpha
  
    NOTE: use subtasks to simplify specifying the application:
      rake deploy:my
      rake deploy:alpha
      rake deploy:staging
    
      VALID SUBTASKS: my, alpha, staging

  Specify files to deploy:
    rake deploy path=views
    rake deploy path=views/settings
    rake deploy path=assets/javascripts/application.js
  
    NOTE: use subtasks to simplify the subset of files to deploy,
      rake deploy:views
      rake deploy:javascripts
    
      VALID SUBTASKS: views, assets, javascripts, images, yrb


  DOCS
    # TODO: add more documentation

    puts docs
  end
  
  create_from_servers do |key, set_task|
    desc "Deploys application to #{key} server"
    task key => [set_task, :deploy]
  end
  
  create_from_servers do |key, set_task|
    namespace key do
      desc "Deploys views to the #{key} server"
      task :views => [set_task, :set_views, :deploy]
  
      desc "Deploys all assets to the #{key} server"
      task :assets => [set_task, :set_assets, :deploy]
  
      desc "Deploys javascript assets to the #{key} server"
      task :javascripts => [set_task, :set_javascripts, :deploy]
  
      desc "Deploys image assets to the #{key} server"
      task :images => [set_task, :set_images, :deploy]
    
      desc "Deploys YRB bundles to the #{key} server"
      task :yrb => [set_task, :set_yrb, :deploy_yrb]
  
      desc "Deploys everything except images to the the #{key} server"
      task :code => [set_task, "deploy:#{key}:views", :skip_validation, "deploy:#{key}:javascripts", "deploy:#{key}:yrb"]
    end
  end
  
  task :yrb => [:set_yrb, :deploy_yrb]
  
  create_from_categories(:deploy)
end


# rake create app=my path=./my
# rake create app=staging path=staging

desc "Creates a new local copy of a YMDP application"
task :create do
  puts "about to create_directory for #{@application}"
  time("Created") do
    create_directory_from_application(@application, @path)
  end
end

# rake create:my path=./my
# rake create:staging path=staging

namespace :create do
  desc "Create all applications"
  task :all do
    time("Created all applications") do
      SERVERS.each do |key, values|
        create_directory_from_application(values["server"])
      end
    end
  end
  
  create_from_servers do |key, set_task|
    desc "Creates local application from #{key} server"
    task key do
      @application = key.to_s
      Rake::Task["create"].invoke
    end
  end
end



# TASKS TO SET UP ENVIRONMENT

CATEGORIES.each do |name, path|
  task "set_#{name}" do
    @path = "#{path}/#{@path}"
  end
end


# END OF RAKE TASKS

def invoke_ymdt(command_string, application, path="", return_results=false)
  dir = "./servers/" << application
  path = dir << "/" << path
    
  command = []  
  command << command_string
  command << "\"#{path}\""
  command << "-s" if @sync

  ymdt_command(command, return_results)
end

def ymdt_command(commands, return_results=false)
  command = []
  # command << "php"
  command << "./script/ymdt"
  
  command << commands
  
  command << "-u#{@username}"
  command << "-p#{@password}"
  command_string = command.join(" ")
  
  display_string = command_string.dup
  display_string.gsub!(@username, "[username]")
  display_string.gsub!(@password, "[password]")
  
  puts
  puts display_string

  unless @dry_run
    if return_results
      `#{command_string}`
    else
      puts
      system command_string
    end
  end
end

def validated_embedded_js(path)
  # jslint only accepts files, later we can hack it to accept stdin pipes
  doc = open(path) { |f| 
    Hpricot(f) 
  }
  
  js_fragment_path = TMP_DIR + "/#{File.basename(path)}_js_fragment"

  File.open(js_fragment_path,'w') do |f|
    (doc / "script").each { |js| f.puts js.inner_html + "\n\n" }
  end

  YMDP::Validator::JavaScript.validate(js_fragment_path)
  system "rm #{js_fragment_path}"
end

def deploy(application, path)
  puts "\nDeploying #{application}: #{path}"

  Rake::Task["validate:html"].invoke if validate_html?
  Rake::Task["validate:embedded_js"].invoke if validate_embedded_js?
  Rake::Task["validate:#{application}:javascripts"].invoke if validate_js_assets?
  Rake::Task["validate:#{application}:json"].invoke if validate_json_assets?

  invoke_ymdt("put", application, path)
end

def deploy_path(application, path)
  puts "\nDeploying #{application}: #{path}"

  Rake::Task["validate:html"].invoke if validate_html?
  Rake::Task["validate:embedded_js"].invoke if validate_embedded_js?
  Rake::Task["validate:#{application}:javascripts"].invoke if validate_js_assets?
  Rake::Task["validate:#{application}:json"].invoke if validate_json_assets?

  dir = "./servers/#{application}"

  if path =~ /\/$/
    deploy(application, path)
  else
    path =~ /^(.*)\/.*$/
    short_path = $1

    full_path = "#{dir}/#{short_path}/**"

    Dir[full_path].each do |file|
      new_path = file.gsub(/#{dir}\//, "")
  
      if file =~ Regexp.new(path)
        puts file
        invoke_ymdt("put", application, new_path)
      end
    end
  end
end

def deploy_yrb(application, path, options={})
  lang = options[:lang]
  view = options[:view]
  
  if lang
    new_path = "#{path}/keys_#{lang}.json"
    deploy_path(application, new_path)
  else
    deploy_path(application, path)
  end
end

def list(application, path)
  invoke_ymdt("ls", application, path, true)
end

def check_asset_ids(application, path)
  result = list(application, path)
  
  lines = result.split("\n")
  wrong_lines = []
  
  lines.each do |line|
    if line =~ /om\/assets\/(.*)\//
      match = $1
      
      if match =~ /#{@assets_id}/
        puts line
      else
        wrong_lines << line
      end
    end
  end
  
  wrong_lines
end

def report_asset_ids(application, path)
  time("Listed asset ids") do
    wrong_ids = []
    wrong_lines = check_asset_ids(application, path)
  
    puts
  
    if wrong_lines.any?
      message = "Some assets do not have the specified asset ID of #{@assets_id}"
      puts message
      wrong_lines.each do |line|
        if line =~ /om\/assets\/(.*)\//
          match = $1
          if match !~ /#{@assets_id}/
            wrong_id = match.split("/").first
            wrong_ids << wrong_id unless wrong_ids.include?(wrong_id)
          end
        end
        puts line
      end
      puts
      puts "The above assets do not have the specified asset ID of #{@assets_id}"
      puts
      if wrong_ids.any?
        puts "Here are the other asset IDs used:"
        wrong_ids.each do |wrong_id|
          puts "  " + wrong_id;
          first_index = @assets_id.split("_").last
          second_index = wrong_id.split("_").last
          if second_index.to_i > first_index.to_i 
            puts
            puts "  This index is higher than the stored application ID."
            puts "  You can update your servers.yml with the following settings:"
            puts
            puts "servers:"
            puts "  #{@application}:"
            puts "    dir: #{@dir}"
            puts "    application_id: #{@application_id}"
            puts "    assets_id: #{wrong_id}"
          else
            puts
            puts "  This index is lower than the stored application ID."
            puts 
            puts "  Run rake fix_assets:#{application} to update remote assets"
          end
        end
      end
    else
      message = "All assets have the specified asset ID of #{@assets_id}"
    end
  end
end

def fix_assets(application, path)
  time("Fixed assets") do
    Rake::Task["validate:all"].invoke unless @skip_validation
    @skip_validation = true
  
    wrong_lines = check_asset_ids(application, path)
  
    if wrong_lines.any?
      wrong_lines.each do |line|
        filename = line.split(" ")[0]
      
        puts deploy(application, filename)
      end
    else
      message = "All assets are up to date"
    end
  end
end

def create_directory_from_application(application, path="")
  time("Done creating #{application}: #{path}") do
    puts "Creating #{application}: #{path}"
    application_id = SERVERS[application]["application_id"]
  
    dir = "./servers/#{application}"
  
    if path == ""
      path = dir
    else
      path = "./" << path
    end
  
    command = []
  
    command << "get"
    command << path
    command << "-a#{application_id}"
  
    ymdt_command(command)
  end  
end

def please_install_rhino
  output = <<-DOC
NOTE: 

You must have Rhino installed in your classpath to validate javascripts, which is required to deploy.  Download Rhino from:
  
  http://www.mozilla.org/rhino/download.html

To put Rhino into your Java classpath, run:
  
  mkdir -p ~/Library/Java/Extensions/
  cp rhino****/js.jar ~/Library/Java/Extensions/
DOC
end
