module ApplicationView
  module FileSupport
    def confirm_overwrite(path)
      if File.exists?(path)
        puts "File exists: #{display_path(path)}"
        print "  overwrite? (y/n)"
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