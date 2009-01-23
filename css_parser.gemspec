# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{css_parser}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["maiha"]
  s.date = %q{2009-01-23}
  s.description = %q{hpricot helper that scrapes html easily by parser class defined css selector}
  s.email = %q{maiha@wota.jp}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "lib/css_parser.rb", "spec/spec_helper.rb", "spec/css_parser_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/maiha/css_parser}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{hpricot helper that scrapes html easily by parser class defined css selector}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.1"])
      s.add_runtime_dependency(%q<dsl_accessor>, [">= 0.1"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.1"])
      s.add_dependency(%q<dsl_accessor>, [">= 0.1"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.1"])
    s.add_dependency(%q<dsl_accessor>, [">= 0.1"])
  end
end
