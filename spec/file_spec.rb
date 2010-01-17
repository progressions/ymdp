require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "F" do
  before(:each) do
    stub_file_io
  end
  
  describe "concat_files" do
    before(:each) do
      Dir.stub!(:[]).with("./dir/*").and_return(["./dir/first.html", "./dir/second.html"])
    end
    
    it "should get the directory" do
      Dir.should_receive(:[]).with("./dir/*").and_return([])
      F.concat_files("./dir/*", "destination")
    end
    
    it "should read each file in the directory" do
      File.should_receive(:read).and_return("first", "second")
      F.concat_files("./dir/*", "destination")
    end
    
    it "should write the contents of each file in the directory" do
      File.stub!(:read).and_return("first", "second")
      @file.should_receive(:puts).with("first")
      @file.should_receive(:puts).with("second")
      F.concat_files("./dir/*", "destination")
    end
    
    it "should write to the destination file" do
      File.should_receive(:open).with("destination", "a").and_yield(@file)
      F.concat_files("./dir/*", "destination")
    end
  end
  
  describe "save_to_file" do
    before(:each) do
      @output = "output"
      @destination_path = "@destination"
    end
    
    it "should check the existence of destination_path" do
      File.should_receive(:exists?).with(@destination_path)
      F.save_to_file(@output, @destination_path)
    end
    
    it "should return false if it exists" do
      File.stub!(:exists?).with(@destination_path).and_return(true)
      F.save_to_file(@output, @destination_path).should == false
    end
    
    it "should open the destination path" do
      File.should_receive(:open).with(@destination_path, "w").and_return(@file)
      F.save_to_file(@output, @destination_path)
    end
    
    it "should write to the destination file" do
      @file.should_receive(:write).with(@output)
      F.save_to_file(@output, @destination_path)
    end
    
    it "should return true" do
      F.save_to_file(@output, @destination_path).should be_true
    end
  end
  
  describe "get_line_from_file" do
    before(:each) do
      @path = "path"
      @lines = ["first\n", "second\n", "third\n", "fourth\n", "fifth\n", "sixth\n", "seventh\n"]
      File.stub!(:readlines).with(@path).and_return(@lines)
    end
    
    it "should read lines from file" do
      File.should_receive(:readlines).and_return(@lines)
      F.get_line_from_file(@path, 7)
    end
    
    it "should get the previous three lines" do
      F.get_line_from_file(@path, 7).should == "\nfifth\nsixth\nseventh\n\n"
    end
  end
  
  # I'm not sure how to test the ` method because it calls system calls that don't seem
  # reachable.
  #
  describe "execute" do
    it "should call system" do
      Kernel.should_receive(:system).with("ls")
      F.execute("ls")
    end
    
    it "should call system" do
      Kernel.should_receive(:system).with("ls")
      F.execute("ls", :reutrn => false)
    end
    
    it "should not call system" do
      Kernel.should_not_receive(:system)
      F.execute("ls", :return => true)
    end
  end
end