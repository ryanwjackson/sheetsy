# frozen_string_literal: true

require_relative "lib/sheetsy/version"

Gem::Specification.new do |spec|
  spec.name = "sheetsy"
  spec.version = Sheetsy::VERSION
  spec.authors = ["Ryan"]
  spec.email = ["sheetsy@rwj.dev"]

  spec.summary = "Easily convert CSV and Excel sheets to JSON"
  spec.description = "Easily convert CSV and Excel sheets to JSON"
  spec.homepage = "https://github.com/ryanwjackson/sheetsy"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ryanwjackson/sheetsy"
  spec.metadata["changelog_uri"] = "https://github.com/ryanwjackson/sheetsy/blob/main/README.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
