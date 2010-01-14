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
    gem.add_development_dependency "haml", ">= 0"
    gem.add_development_dependency "json", ">= 0"
    gem.add_development_dependency "hpricot", ">= 0"
    gem.add_development_dependency "ruby-growl", ">= 0"
    gem.add_development_dependency "activesupport", ">= 0"
    gem.add_development_dependency "sishen-rtranslate", ">= 0"
    gem.add_development_dependency "progressions-basepath", ">= 0"
    gem.add_development_dependency "progressions-g", ">= 0"
    gem.add_development_dependency "bundler", ">= 0"
    gem.add_development_dependency "timer", ">= 0"
    gem.add_development_dependency "serenity", ">= 0"
    gem.add_development_dependency "ymdp_generator", ">= 0"
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
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "translator #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
