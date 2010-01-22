if ARGV[0] == "view"
  p = {
    :template_path => File.join(File.dirname(__FILE__), "..", "generator", "templates"),
    :application_path => APPLICATION_PATH
  }
  YMDP::Generator::Base.new(p).generate(ARGV[1])
  Dir["#{BASE_PATH}/app/assets/yrb/en-US/new_#{ARGV[1]}_en-US.pres"].each do |path|
    Idiom::Base.translate(:source => path)
  end  
end
