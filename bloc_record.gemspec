Gem::Specification.new do |s|
	s.name = 'bloc_record'
	s.version = '0.0.0'
	s.date = '2017-12-11'
	s.summary = 'BlocRecord ORM'
	s.description = 'An ActiveRecord-esque ORM adaptor'
	s.authors = ['Anthony Zardis']
	s.email = 'anthonyzardis@gmail.com'
	s.files = Dir['lib/**/*.rb']
	s.require_paths = ['lib']
	s.homepage = 'http://rubygems.org/gems/bloc_record'
	s.license = 'MIT'
	s.add_runtime_dependency 'sqlite3', '~> 1.3.7'
end