$:.push File.expand_path("../lib", __FILE__)
require "spiffy_stores_api/version"

Gem::Specification.new do |s|
  s.name = %q{spiffy_stores_api}
  s.version = SpiffyStoresAPI::VERSION
  s.author = "Spiffy Stores"

  s.summary = %q{The SpiffyStores API gem is a lightweight gem for accessing the Spiffy Stores admin REST web services}
  s.description = %q{The SpiffyStores API gem allows Ruby developers to programmatically access the admin section of SpiffyStores stores. The API is implemented as JSON or XML over HTTP using all four verbs (GET/POST/PUT/DELETE). Each resource, like Order, Product, or Collection, has its own URL and is manipulated in isolation.}
  s.email = %q{brian@spiffy.com.au}
  s.homepage = %q{https://www.spiffystores.com.au}

  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.rdoc_options = ["--charset=UTF-8"]
  s.summary = %q{SpiffyStoresAPI is a lightweight gem for accessing the Spiffy Stores admin REST web services}
  s.license = "MIT"

  s.required_ruby_version = ">= 2.2"

  s.add_runtime_dependency("activeresource", ">= 3.0.0")
  s.add_runtime_dependency("rack")

  s.add_development_dependency("mocha", ">= 0.9.8")
  s.add_development_dependency("fakeweb")
  s.add_development_dependency("minitest", ">= 4.0")
  s.add_development_dependency("rake")
end
