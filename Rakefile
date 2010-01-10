require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ymdp"
    gem.summary = "Framework for developing applications in the Yahoo! Mail Development Platform"
    gem.description = "Framework for developing applications in the Yahoo! Mail Development Platform."
    gem.email = "progressions@gmail.com"
    gem.homepage = "http://github.com/progressions/ymdp"
    gem.authors = ["Jeff Coleman"]
    # gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "haml", ">= 0"
    gem.add_development_dependency "json", ">= 0"
    gem.add_development_dependency "hpricot", ">= 0"
    gem.add_development_dependency "ruby-growl", ">= 0"
    gem.add_development_dependency "activesupport", ">= 0"
    gem.add_development_dependency "sishen-rtranslate", ">= 0"
    gem.add_development_dependency "progressions-basepath", ">= 0"
    gem.add_development_dependency "bundler", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ymdp #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
