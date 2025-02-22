# frozen_string_literal: true

require_relative 'lib/chromate/version'

mode = ENV.fetch('DEPLOY_MODE', 'github')
host = mode == 'github' ? 'https://rubygems.pkg.github.com/Eth3rnit3' : 'https://rubygems.org'
name = mode == 'github' ? 'chromate' : 'chromate-rb'

Gem::Specification.new do |spec|
  spec.name = name
  spec.version = Chromate::VERSION
  spec.authors = ['Eth3rnit3']
  spec.email = ['eth3rnit3@gmail.com']

  spec.summary = 'Chromate is a Ruby library to control Google Chrome with the Chrome DevTools Protocol.'
  spec.description = 'Chromate is a Ruby library to control Google Chrome with the Chrome DevTools Protocol.'
  spec.homepage = 'http://github.com/Eth3rnit3/chromate'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = host

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Eth3rnit3/chromate'
  spec.metadata['changelog_uri'] = 'https://github.com/Eth3rnit3/chromate/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'ffi', '~> 1.17.0'
  spec.add_dependency 'user_agent_parser', '~> 2.18.0'
  spec.add_dependency 'websocket-client-simple', '~> 0.8.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
