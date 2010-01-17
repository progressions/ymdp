# Provides a wrapper around common calls that interact with the file system.
#
module F

  module_function

  # Concatenates together the contents of all the files in the <tt>source_path</tt> 
  # into the <tt>destination_path</tt>.
  #
  def concat_files(source_path, destination_path)
    File.open(destination_path, "a") do |output|
      Dir[source_path].each do |path|
        output.puts File.read(path)
      end
    end
  end

  # Saves the <tt>output</tt> string to the <tt>destination_path</tt> given.
  #
  # Returns <tt>true</tt> if the destination file was newly created, <tt>false</tt> if
  # it already existed.
  #
  def save_to_file(output, destination_path)
    if File.exists?(destination_path)      
      false
    else
      File.open(destination_path, "w") do |w|
        w.write(output)
      end
      true
    end
  end

  # Given a <tt>path</tt> and <tt>line_number</tt>, returns the line and two lines previous
  #
  # Used for displaying validation errors.
  #
  def get_line_from_file(path, line_number)
    line_number = line_number.to_i
    output = "\n"
    lines = File.readlines(path)

    3.times do |i|
      line = lines[line_number-(3-i)]
      output += line if line
    end

    output += "\n"
    output
  end

  # Execute a system command. If the parameter <tt>:return</tt> is true, execute the command
  # with the backtick (`) command and return the results.  Otherwise, just execute the command
  # and let the output go to the screen.
  #
  def execute(command, params={})
    if params[:return]
      `#{command}`
    else
      Kernel.system command
    end
  end
end
