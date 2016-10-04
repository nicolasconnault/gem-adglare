Gem::Specification.new do |s|
  s.name        = 'adglare'
  s.version     = '0.0.3'
  s.date        = '2016-10-04'
  s.summary     = "Adglare API Library"
  s.description = "Allows interaction with an AdGlare account, to display ads on multiple sites"
  s.authors     = ["Nicolas Connault"]
  s.email       = 'nicolasconnault@gmail.com'
  s.files       = ["lib/adglare.rb"]
  s.homepage    =
    'http://rubygems.org/gems/adglare'
  s.license       = 'MIT'
  s.requirements = ['curb 0.9+']
  s.add_runtime_dependency 'curb', '~> 0.9', '>= 0.9.3'
end
