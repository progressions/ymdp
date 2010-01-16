module YMDP
  # Some useful methods that make working with files easier.
  #
  module FileSupport
    # Concatenates together the contents of all the files in the <tt>source_path</tt> 
    # into the <tt>destination_path</tt>.
    #
    def concat_files(source_path, destination_path)
      File.open(destination_path, "a") do |output|
        Dir[source_path].each do |path|
          File.open(path) do |f|
            output.puts f.read
          end
        end
      end
    end
    
    # If the file at <tt>path</tt> exists, prompt the user to overwrite it. If the file doesn't
    # exist, return true.
    #
    def confirm_overwrite(path)
      if File.exists?(path)
        $stdout.puts "File exists: #{File.expand_path(path)}"
        $stdout.print "  overwrite? (y/n)"
        answer = $stdin.gets
        
        answer =~ /^y/i
      else
        true
      end          
    end
    
    # Parses out the <tt>BASE_PATH</tt> constant from filenames to display them in a 
    # friendlier way.
    # 
    # TODO: Refactor this so it doesn't use a constant.
    #
    def display_path(path)
      path = File.expand_path(path)
      path.gsub(BASE_PATH, "")
    end
    
    # Saves the <tt>output</tt> string to the <tt>destination_path</tt> given
    #
    def save_to_file(output, destination_path)
      unless File.exists?(destination_path)      
        File.open(destination_path, "w") do |w|
          w.write(output)
        end
      end
    end
  
    # Given a <tt>path</tt> and <tt>line_number</tt>, returns the line and two lines previous
    #
    # Used for displaying validation errors.
    #
    def get_line_from_file(path, line_number)
      line_number = line_number.to_i
      output = ""
      lines = []
    
      File.open(path) do |f|
        lines = f.readlines
      end
  
      output += "\n"
  
      3.times do |i|
        line = lines[line_number-(3-i)]
        output += line if line
      end
  
      output += "\n"      
    
      output
    end
  end
end

# Provide a wrapper around system calls so they can be mocked in tests.
#
class F
  extend YMDP::FileSupport
  
  # Execute a system command. If the parameter <tt>:return</tt> is true, execute the command
  # with the backtick (`) command and return the results.  Otherwise, just execute the command
  # and let the output go to the screen.
  #
  def self.execute(command, params={})
    if params[:return]
      `#{command}`
    else
      system command
    end
  end
end
