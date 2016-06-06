$:.push File.expand_path('../lib', __FILE__)

require 'company/version'

Gem::Specification.new do |s|
  s.name = 'company'
  s.version = Company::VERSION
  s.authors = [ 'Origami Call' ]
  s.email = [ 'info@origamicall.com' ]
  s.homepage = 'http://www.origamicall.com'
  s.summary = 'Web corporativa'

  s.files = Dir[ "{app,config,db,lib}/**/*", 'Rakefile', 'README.rdoc' ]
  s.test_files = Dir[ 'test/**/*' ]
end