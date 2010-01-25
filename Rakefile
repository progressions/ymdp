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
    gem.add_development_dependency "rspec", ">= 1.2.6"
    gem.add_development_dependency "cucumber", ">= 0"
    gem.add_runtime_dependency "haml", ">= 0"
    gem.add_runtime_dependency "json", ">= 0"
    gem.add_runtime_dependency "hpricot", ">= 0"
    gem.add_runtime_dependency "ruby-growl", ">= 0"
    gem.add_runtime_dependency "activesupport", ">= 0"
    gem.add_runtime_dependency "sishen-rtranslate", ">= 0"
    gem.add_runtime_dependency "progressions-basepath", ">= 0"
    gem.add_runtime_dependency "progressions-g", ">= 0"
    gem.add_runtime_dependency "bundler", ">= 0"
    gem.add_runtime_dependency "timer", ">= 0"
    gem.add_runtime_dependency "serenity", ">= 0"
    gem.add_runtime_dependency "ymdp_generator", ">= 0"
    gem.add_runtime_dependency "ymdt", ">= 0"
    gem.add_runtime_dependency "yrb", ">= 0"
    gem.add_runtime_dependency "w3c_validators", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ['-c']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov_opts = ['--exclude', '.gem,Library,spec', '--sort', 'coverage']
  spec.rcov = true
end

task :bundle do
  YMDP_TEST = true
  require 'vendor/gems/environment'
  Bundler.require_env
end

task :spec => [:bundle, :check_dependencies]

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "YMDP #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "--format pretty"
end
