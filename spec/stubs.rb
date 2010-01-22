def stub_io
  stub_screen_io
  stub_file_io
  stub_file_utils
  stub_yaml
  stub_yrb
  stub_growl
end

def stub_screen_io
  $stdout.stub!(:puts)
  $stdout.stub!(:print)    
end

def stub_file_io(unprocessed_file="")
  @file ||= mock('file').as_null_object
  @file.stub!(:read).and_return(unprocessed_file)
  @file.stub!(:write)
  @file.stub!(:puts)
  
  File.stub!(:new).and_return(@file)
  File.stub!(:exists?).and_return(false)
  File.stub!(:open).and_yield(@file) 
  File.stub!(:read).and_return(unprocessed_file)
  File.stub!(:readlines).and_return(["first\n", "second\n"])
end

def stub_file_utils
  FileUtils.stub!(:rm)
  FileUtils.stub!(:rm_rf)
  FileUtils.stub!(:cp_r)
  FileUtils.stub!(:mkdir_p)
  F.stub!(:concat_files)
  F.stub!(:get_line_from_file).and_return("")
  F.stub!(:save_to_file)
  F.stub!(:save_to_tmp_file)
  F.stub!(:execute).and_return("")
end

def stub_yaml(output_hash={})
  YAML.stub!(:load_file).and_return(output_hash)
end

def stub_yrb(output_hash={})
  YRB.stub!(:load_file).and_return(output_hash)
end

def stub_erb(processed_file="")
  @erb ||= mock('erb').as_null_object
  @erb.stub!(:result).and_return(processed_file)
  ERB.stub!(:new).and_return(@erb)
end

def stub_haml_class
  eval %(
  module Haml
    class Engine
    end
  end
  )
end

def stub_haml(processed_file)
  @haml = mock('haml').as_null_object
  @haml.stub!(:render).and_return(processed_file)
  Haml::Engine.stub!(:new).and_return(@haml)
end

def stub_git_helper
  @git_helper = mock('git_helper').as_null_object
  YMDP::GitHelper.stub!(:new).and_return(@git_helper)
end

def stub_timer
  @timer = mock('timer').as_null_object
  @timer.stub!(:time).and_yield
  Timer.stub!(:new).and_return(@timer)
end

def stub_growl
  @g = Object.new
  Growl.stub(:new).and_return(@g)
  @g.stub(:notify).as_null_object  
end

def reset_constant(constant, value)
  Object.send(:remove_const, constant)
  Object.const_set(constant, value)
end

def stub_config
  @config = mock('config')
  @config.stub!(:[]).with("doctype").and_return("HTML 4.0 Transitional")
  @config.stub!(:validate_html?).and_return(false)
  @config.stub!(:compress_embedded_js?).and_return(false)
  @config.stub!(:verbose?).and_return(false)
  reset_constant(:CONFIG, @config)
end