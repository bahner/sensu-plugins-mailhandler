Gem::Specification.new do |s|
  s.name                = 'sensu-plugins-mailhandler'
  s.version             = '0.0.2'
  s.date                = '2016-07-20'
  s.summary             = 'Handler to easily send email'
  s.description         = 'Handler to pretty print an event and send it as email.'
  s.authors             = ['Lars Bahner']
  s.email               = 'lars.bahner@gmail.com'
  s.files               = `git ls-files`.split($\)
  s.executables         = 'mailhandler.rb'
  s.homepage            = 'http://github.com/bahner/sensu-plugins-mailhandler'
  s.license             = 'MIT'
end
