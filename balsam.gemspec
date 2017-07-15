# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "balsam/version"

Gem::Specification.new do |spec|
  spec.name          = "balsam"
  spec.version       = Balsam::VERSION
  spec.authors       = ["Zhu Ran"]
  spec.email         = ["zhuran94@163.com"]

  spec.summary       = %q{book scraper}
  spec.description   = %q{book scraper}
  spec.homepage      = "http://reading.zhuran.tw"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  puts spec.files

  spec.files         = `git ls-files`.split($\).reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables   = ["balsam"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "bunny", ">= 2.6.3"
  spec.add_development_dependency "nokogiri", ">= 1.8.0"
end
