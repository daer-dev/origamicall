$:.push File.expand_path('../lib', __FILE__)

require 'libs/version'

Gem::Specification.new do |s|
  s.name = 'libs'
  s.version = Libs::VERSION
  s.authors = [ 'Origami Call' ]
  s.email = [ 'info@origamicall.com' ]
  s.homepage = 'http://www.origamicall.com'
  s.summary = 'Libs'

  s.files = Dir[ "{app,config,db,lib}/**/*", 'Rakefile', 'README.rdoc' ]
  s.test_files = Dir[ 'test/**/*' ]
end