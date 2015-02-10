Gem::Specification.new do |s|
  s.name        = 'vcautils'
  s.version     = '0.5'
  s.executables << 'vcaexplorer'
  s.date        = '2015-02-05'
  s.summary     = "VMware vCloud Air Utilities"
  s.description = "A set of tools to programmatically access VMware vCloud Air"
  
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'httparty', '~> 0.13.3'
  s.add_runtime_dependency 'xml-fu', '~> 0.2.0'
  s.add_runtime_dependency 'awesome_print', '~> 1.6', '>= 1.6.1'
  s.add_runtime_dependency 'gon-sinatra', '~> 0.1.2'
  s.add_runtime_dependency 'json', '~> 1.8', '>= 1.8.2'
  s.add_runtime_dependency 'sinatra', '~> 1.4', '>= 1.4.5'


  s.authors     = ["Massimo Re Ferrè"]
  s.email       = 'massimo@it20.info'
  s.files       = ["lib/vcaexplorer.rb", "lib/modules/vcautilscore.rb"]
  s.homepage    = 'http://it20.info'
  s.license     = 'Apache License'
end
