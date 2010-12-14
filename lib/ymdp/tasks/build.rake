require 'ymdp'

@server_names = []

SERVERS.each do |k,v|
  @server_names << k
end

@message = ENV["m"] || ENV["M"]

def message
  unless @message
    $stdout.print "Enter a commit message: "
    @message = $stdin.gets
    @message.gsub!("\n", "")
  end
  @message
end

desc "Compile the application to the #{CONFIG['default_server']} server"
task :b => :build

desc "Compile the application to the #{CONFIG['default_server']} server"    
task :build do
  system "#{BASE_PATH}/script/build -m \"#{message}\" -d #{CONFIG['default_server']}"
end

namespace :build do
  desc "Compile the application to all servers"
  task :all => @server_names
  
  @server_names.each do |name|
    desc "Compile the application to the #{name} server"
    task name.to_sym do
      system "#{BASE_PATH}/script/build -m \"#{message}\" -d #{name}"
    end
  end
end

