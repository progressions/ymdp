require 'lib/init'

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

task :b => :build
    
task :build do
  system "#{BASE_PATH}/script/build -m \"#{message}\" -d #{CONFIG['default_server']}"
end

namespace :build do
  task :all => @server_names
  
  @server_names.each do |name|
    task name.to_sym do
      system "#{BASE_PATH}/script/build -m \"#{message}\" -d #{name}"
    end
  end
end

