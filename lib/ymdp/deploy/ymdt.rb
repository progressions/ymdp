module YMDT
  class System
    def self.execute(command, params={})
      if params[:return]
        `#{command}`
      else
        system command
      end
    end
  end
  
  class Base
    attr_accessor :username, :password, :script_path
  
    def initialize(params={})
      @username = params[:username]
      @password = params[:password]
      unless @username
        raise ArgumentError.new("username required")
      end
      unless @password
        raise ArgumentError.new("password required")
      end
      @script_path = params[:script_path] || "./script/ymdt"
    end
    
    def put(params={})
      invoke(:put, params)
    end
    
    def get(params={})
      invoke(:get, params)
    end
    
    def create(params={})
      raise ArgumentError.new("application_id required") unless params[:application_id]
      invoke(:get, params)
    end
    
    def ls(params={})
      invoke(:ls, {:return => true}.merge(params))
    end
    
    def upgrade(params={})
      invoke(:upgrade, params)
    end
  
    # prepares the commands to correctly reference the application and path
    #
    def invoke(command, params={})
      command_string = compile_command(command, params)
      output_command(command_string)
      execute(command_string, params)
    end
    
    private
    
    def output_command(command_string)
      $stdout.puts
      $stdout.puts StringMasker.new(command_string, :username => username, :password => password).to_s
    end
    
    def compile_command(command, params)
      full_path = nil
      
      # construct relative path to the application's location in the servers directory
      #
      if params[:application]
        full_path = "#{SERVERS_PATH}/" << params[:application]
        full_path = full_path << "/" << params[:path] if params[:path]
      end
      
      # construct command line 
      #
      options = []
      
      # execute script
      #
      options << script_path
      
      # command (:put, :get, etc)
      #
      options << command
      
      # path
      #
      options << "\"#{full_path}\"" if full_path
      
      # optional sync flag MUST BE PLACED HERE
      #
      options << "-s" if params[:sync]
      
      # optional application ID flag
      #
      options << "-a#{params[:application_id]}" if params[:application_id]
      
      # username and password
      
      options << "-u#{username}"
      options << "-p#{password}"
      
      options.join(" ") 
    end
    
    # execute the command, or not, and return the results, or not
    #
    def execute(command, params={})
      unless params[:dry_run]
        if params[:return]
          System.execute(command, :return => true)
        else
          $stdout.puts
          System.execute(command)
        end
      end
    end
  end
end