# -*- encoding: utf-8 -*-
require File.expand_path('../lib/iso8583-mkb/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Sergey Gridasov"]
  gem.email         = ["grindars@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "iso8583-mkb"
  gem.require_paths = ["lib"]
  gem.version       = ISO8583::MKB::VERSION

  gem.add_dependency 'iso8583'
  gem.add_dependency 'eventmachine'
end
