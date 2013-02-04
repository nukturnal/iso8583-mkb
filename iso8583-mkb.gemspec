# -*- encoding: utf-8 -*-
require File.expand_path('../lib/iso8583-mkb/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Sergey Gridasov"]
  gem.email         = ["grindars@gmail.com"]
  gem.description   = %q{ISO8583 implementation for Credit Bank of Moscow}
  gem.summary       = %q{ISO8583 implementation for MKB}
  gem.homepage      = "https://github.com/smartkiosk/iso8583-mkb"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "iso8583-mkb"
  gem.require_paths = ["lib"]
  gem.version       = ISO8583::MKB::VERSION

  gem.add_dependency 'iso8583'
  gem.add_dependency 'eventmachine'
end
