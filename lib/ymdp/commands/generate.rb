if ARGV[0] == "view"
  p = {
    :template_path => File.join(File.dirname(__FILE__), "..", "generator", "templates"),
    :application_path => "#{BASE_PATH}/app"
  }
  YMDP::Generator::Base.new(p).generate(ARGV[1])
  Idiom::Base.translate("#{BASE_PATH}/app")
end
