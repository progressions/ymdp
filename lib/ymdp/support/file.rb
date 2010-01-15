module YMDP
  module FileSupport
    # Concatenate together the contents of the input_path into the output_file.
    #
    def concat_files(input_path, output_file)
      File.open(output_file, "a") do |output|
        Dir[input_path].each do |path|
          File.open(path) do |f|
            output.puts f.read
          end
        end
      end        
    end
    
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
    
    # friendlier display of paths
    def display_path(path)
      path = File.expand_path(path)
      path.gsub(BASE_PATH, "")
    end
    
    # saves the output string to the filename given
    #
    def save_to_file(output, filename)
      unless File.exists?(filename)      
        File.open(filename, "w") do |w|
          w.write(output)
        end
      end
    end
  
    # given a path and line number, returns the line and two lines previous
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

class F
  extend YMDP::FileSupport
  
  def self.execute(command, params={})
    if params[:return]
      `#{command}`
    else
      system command
    end
  end
end
