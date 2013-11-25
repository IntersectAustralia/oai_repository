$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "oai_repository/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "oai_repository"
  s.version     = OaiRepository::VERSION
  s.authors     = ["Sean McCarthy", "Diego Alonso de Marcos"]
  s.email       = ["sean@intersect.org.au", "diego@intersect.org.au"]
  s.homepage    = "https://github.com/IntersectAustralia/oai_repository"
  s.summary     = "A Rails (3.1+) Engine to provide an OAI repository"
  s.description = "An Engine for Rails (3.1+) that allows you to make your application an OAI-PMH Data Provider. See http://www.openarchives.org/pmh/ and http://www.openarchives.org/OAI/openarchivesprotocol.html#Repository"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails"
  s.add_dependency "oai"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
end
