require 'translator/base'

if ARGV[0] == "view"
  p = {
    :template_path => File.join(File.dirname(__FILE__), "..", "generator", "templates"),
    :application_path => APPLICATION_PATH
  }
  YMDP::Generator::Base.new(p).generate(ARGV[1])
  YMDP::Translator::YRB.translate
end
