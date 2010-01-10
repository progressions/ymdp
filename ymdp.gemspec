# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ymdp}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Coleman"]
  s.date = %q{2010-01-10}
  s.description = %q{Framework for developing applications in the Yahoo! Mail Development Platform.}
  s.email = %q{progressions@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/application_view/application_view.rb",
     "lib/application_view/asset_tag_helper.rb",
     "lib/application_view/commands/generate.rb",
     "lib/application_view/compiler/template_compiler.rb",
     "lib/application_view/config.rb",
     "lib/application_view/generator/base.rb",
     "lib/application_view/generator/templates/javascript.js",
     "lib/application_view/generator/templates/stylesheet.css",
     "lib/application_view/generator/templates/translation.pres",
     "lib/application_view/generator/templates/view.html.haml",
     "lib/application_view/generator/view.rb",
     "lib/application_view/helpers.rb",
     "lib/application_view/processor/compressor.rb",
     "lib/application_view/processor/processor.rb",
     "lib/application_view/processor/validator.rb",
     "lib/application_view/support/file.rb",
     "lib/application_view/support/form_post.rb",
     "lib/application_view/support/g.rb",
     "lib/application_view/support/growl.rb",
     "lib/application_view/support/timer.rb",
     "lib/application_view/support/w3c.rb",
     "lib/application_view/tag_helper.rb",
     "lib/application_view/translator/base.rb",
     "lib/application_view/translator/blank.rb",
     "lib/application_view/translator/ymdp_translate.rb",
     "lib/ymdp.rb",
     "test/helper.rb",
     "test/test_ymdp.rb",
     "ymdp.gemspec"
  ]
  s.homepage = %q{http://github.com/progressions/ymdp}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Framework for developing applications in the Yahoo! Mail Development Platform}
  s.test_files = [
    "test/helper.rb",
     "test/test_ymdp.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

