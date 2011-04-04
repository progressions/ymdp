# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ymdp}
  s.version = "0.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Coleman"]
  s.date = %q{2011-04-04}
  s.description = %q{Framework for developing applications in the Yahoo! Mail Development Platform.}
  s.email = %q{progressions@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".base",
    ".document",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "History.txt",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "features/data/app/assets/yrb/en-US/keys_en-US.pres",
    "features/data/app/javascripts/application.js",
    "features/data/app/stylesheets/application.css",
    "features/data/app/views/layouts/application.html.haml",
    "features/data/app/views/page.html.haml",
    "features/data/config/config.yml",
    "features/data/config/content.yml",
    "features/data/config/jslint.js",
    "features/data/config/servers.yml",
    "features/step_definitions/ymdp_steps.rb",
    "features/support/env.rb",
    "features/ymdp.feature",
    "lib/ymdp.rb",
    "lib/ymdp/base.rb",
    "lib/ymdp/commands/build.rb",
    "lib/ymdp/commands/generate.rb",
    "lib/ymdp/compiler/base.rb",
    "lib/ymdp/compiler/domains.rb",
    "lib/ymdp/compiler/git_helper.rb",
    "lib/ymdp/compiler/options.rb",
    "lib/ymdp/compiler/template.rb",
    "lib/ymdp/configuration/config.rb",
    "lib/ymdp/configuration/constants.rb",
    "lib/ymdp/generator/templates/javascript.js",
    "lib/ymdp/generator/templates/stylesheet.css",
    "lib/ymdp/generator/templates/translation.pres",
    "lib/ymdp/generator/templates/view.html.haml",
    "lib/ymdp/javascripts/ab_testing.js",
    "lib/ymdp/javascripts/ajax.js",
    "lib/ymdp/javascripts/application.js",
    "lib/ymdp/javascripts/browser.js",
    "lib/ymdp/javascripts/data.js",
    "lib/ymdp/javascripts/debug.js",
    "lib/ymdp/javascripts/education.js",
    "lib/ymdp/javascripts/flash.js",
    "lib/ymdp/javascripts/help.js",
    "lib/ymdp/javascripts/i18n.js",
    "lib/ymdp/javascripts/init.js",
    "lib/ymdp/javascripts/launcher.js",
    "lib/ymdp/javascripts/logger.js",
    "lib/ymdp/javascripts/params.js",
    "lib/ymdp/javascripts/reporter.js",
    "lib/ymdp/javascripts/tag_helper.js",
    "lib/ymdp/javascripts/user.js",
    "lib/ymdp/tasks/build.rake",
    "lib/ymdp/tasks/keys.rake",
    "lib/ymdp/tasks/ymdp.rake",
    "lib/ymdp/view/application.rb",
    "lib/ymdp/view/application_view.rb",
    "lib/ymdp/view/asset_tag_helper.rb",
    "lib/ymdp/view/tag_helper.rb",
    "spec/application_spec.rb",
    "spec/application_view_spec.rb",
    "spec/compiler_spec.rb",
    "spec/compiler_template_spec.rb",
    "spec/configuration_spec.rb",
    "spec/default_settings.rb",
    "spec/domains_spec.rb",
    "spec/file_spec.rb",
    "spec/git_helper_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/stubs.rb",
    "spec/ymdp_base_spec.rb",
    "spec/ymdp_spec.rb",
    "ymdp.gemspec"
  ]
  s.homepage = %q{http://github.com/progressions/ymdp}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.0}
  s.summary = %q{Framework for developing applications in the Yahoo! Mail Development Platform}
  s.test_files = [
    "spec/application_spec.rb",
    "spec/application_view_spec.rb",
    "spec/compiler_spec.rb",
    "spec/compiler_template_spec.rb",
    "spec/configuration_spec.rb",
    "spec/default_settings.rb",
    "spec/domains_spec.rb",
    "spec/file_spec.rb",
    "spec/git_helper_spec.rb",
    "spec/spec_helper.rb",
    "spec/stubs.rb",
    "spec/ymdp_base_spec.rb",
    "spec/ymdp_spec.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, [">= 1.2.6"])
      s.add_runtime_dependency(%q<polyglot>, [">= 0"])
      s.add_runtime_dependency(%q<treetop>, [">= 0"])
      s.add_runtime_dependency(%q<cucumber>, [">= 0"])
      s.add_runtime_dependency(%q<haml>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<mime-types>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-growl>, [">= 0"])
      s.add_runtime_dependency(%q<grit>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<sishen-rtranslate>, [">= 0"])
      s.add_runtime_dependency(%q<progressions-basepath>, [">= 0"])
      s.add_runtime_dependency(%q<progressions-g>, [">= 0"])
      s.add_runtime_dependency(%q<timer>, [">= 0"])
      s.add_runtime_dependency(%q<serenity>, [">= 0"])
      s.add_runtime_dependency(%q<natural_time>, [">= 0"])
      s.add_runtime_dependency(%q<ymdp_generator>, [">= 0"])
      s.add_runtime_dependency(%q<ymdt>, [">= 0"])
      s.add_runtime_dependency(%q<yrb>, [">= 0"])
      s.add_runtime_dependency(%q<idiom>, [">= 0"])
      s.add_runtime_dependency(%q<epic>, [">= 0"])
      s.add_runtime_dependency(%q<haml>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-growl>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<sishen-rtranslate>, [">= 0"])
      s.add_runtime_dependency(%q<progressions-basepath>, [">= 0"])
      s.add_runtime_dependency(%q<progressions-g>, [">= 0"])
      s.add_runtime_dependency(%q<bundler>, [">= 0"])
      s.add_runtime_dependency(%q<timer>, [">= 0"])
      s.add_runtime_dependency(%q<serenity>, [">= 0"])
      s.add_runtime_dependency(%q<ymdp_generator>, [">= 0"])
      s.add_runtime_dependency(%q<ymdt>, [">= 0"])
      s.add_runtime_dependency(%q<yrb>, [">= 0"])
      s.add_runtime_dependency(%q<epic>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.6"])
      s.add_dependency(%q<polyglot>, [">= 0"])
      s.add_dependency(%q<treetop>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<haml>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<mime-types>, [">= 0"])
      s.add_dependency(%q<ruby-growl>, [">= 0"])
      s.add_dependency(%q<grit>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<sishen-rtranslate>, [">= 0"])
      s.add_dependency(%q<progressions-basepath>, [">= 0"])
      s.add_dependency(%q<progressions-g>, [">= 0"])
      s.add_dependency(%q<timer>, [">= 0"])
      s.add_dependency(%q<serenity>, [">= 0"])
      s.add_dependency(%q<natural_time>, [">= 0"])
      s.add_dependency(%q<ymdp_generator>, [">= 0"])
      s.add_dependency(%q<ymdt>, [">= 0"])
      s.add_dependency(%q<yrb>, [">= 0"])
      s.add_dependency(%q<idiom>, [">= 0"])
      s.add_dependency(%q<epic>, [">= 0"])
      s.add_dependency(%q<haml>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<ruby-growl>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<sishen-rtranslate>, [">= 0"])
      s.add_dependency(%q<progressions-basepath>, [">= 0"])
      s.add_dependency(%q<progressions-g>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<timer>, [">= 0"])
      s.add_dependency(%q<serenity>, [">= 0"])
      s.add_dependency(%q<ymdp_generator>, [">= 0"])
      s.add_dependency(%q<ymdt>, [">= 0"])
      s.add_dependency(%q<yrb>, [">= 0"])
      s.add_dependency(%q<epic>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.6"])
    s.add_dependency(%q<polyglot>, [">= 0"])
    s.add_dependency(%q<treetop>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<haml>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<mime-types>, [">= 0"])
    s.add_dependency(%q<ruby-growl>, [">= 0"])
    s.add_dependency(%q<grit>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<sishen-rtranslate>, [">= 0"])
    s.add_dependency(%q<progressions-basepath>, [">= 0"])
    s.add_dependency(%q<progressions-g>, [">= 0"])
    s.add_dependency(%q<timer>, [">= 0"])
    s.add_dependency(%q<serenity>, [">= 0"])
    s.add_dependency(%q<natural_time>, [">= 0"])
    s.add_dependency(%q<ymdp_generator>, [">= 0"])
    s.add_dependency(%q<ymdt>, [">= 0"])
    s.add_dependency(%q<yrb>, [">= 0"])
    s.add_dependency(%q<idiom>, [">= 0"])
    s.add_dependency(%q<epic>, [">= 0"])
    s.add_dependency(%q<haml>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<ruby-growl>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<sishen-rtranslate>, [">= 0"])
    s.add_dependency(%q<progressions-basepath>, [">= 0"])
    s.add_dependency(%q<progressions-g>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<timer>, [">= 0"])
    s.add_dependency(%q<serenity>, [">= 0"])
    s.add_dependency(%q<ymdp_generator>, [">= 0"])
    s.add_dependency(%q<ymdt>, [">= 0"])
    s.add_dependency(%q<yrb>, [">= 0"])
    s.add_dependency(%q<epic>, [">= 0"])
  end
end

