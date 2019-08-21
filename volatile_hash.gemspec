Gem::Specification.new do |s|
    s.name        = 'volatile_hash'
    s.version     = '0.0.5'
    s.date        = '2014-01-17'
    s.summary     = "Implements LRU and TTL caches"
    s.description = "Implements key-based cache that can have a least-recently-used or time-to-live expiration strategy"
    s.authors     = ["Satya P"]
    s.email       = 'github@thesatya.com'
    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.require_paths = ["lib"]

    s.homepage    = 'http://github.com/satyap/volatile_hash'

    s.add_development_dependency 'rspec', '~> 2.8.0'
    s.add_development_dependency 'rr', '~> 1.0.4'
    s.add_development_dependency 'rake', '~> 0.9.2'
end
