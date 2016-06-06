$:.push File.expand_path('../lib', __FILE__)

require 'ivr/version'

Gem::Specification.new do |s|
  s.name = 'ivr'
  s.version = Ivr::VERSION
  s.authors = [ 'Origami Call' ]
  s.email = [ 'info@origamicall.com' ]
  s.homepage = 'http://www.origamicall.com'
  s.summary = 'IVR'

  s.files = Dir[ "{app,config,db,lib}/**/*", 'Rakefile', 'README.rdoc' ]
  s.test_files = Dir[ 'test/**/*' ]
end