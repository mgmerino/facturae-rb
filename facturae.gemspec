# frozen_string_literal: true

require_relative "lib/facturae/version"

Gem::Specification.new do |spec|
  spec.name = "facturae"
  spec.version = Facturae::VERSION
  spec.authors = ["manu"]
  spec.email = ["mgmerino@gmail.com"]

  spec.summary = "Ruby gem for generating Facturae 3.2.2 electronic invoices with XAdES-BES signatures"
  spec.description = "Generate electronic invoices following the Facturae 3.2.2 Spanish standard. " \
                     "Includes model-based validation, XML generation, and XAdES-BES digital signing support."
  spec.homepage = "https://github.com/mgmerino/facturae-rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mgmerino/facturae-rb"
  spec.metadata["changelog_uri"] = "https://github.com/mgmerino/facturae-rb/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "nokogiri", "~> 1.11"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
