# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'folio_lsp'
  s.version     = '0.0.1'
  s.date        = '2019-10-28'
  s.summary     = "FOLIO LSP"
  s.description = "Facilitates common FOLIO LSP API calls"
  s.authors     = ["Eric Frierson"]
  s.email       = 'efrierson@ebsco.com'
  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.files        += Dir.glob('lib/**/*')
  s.homepage    = 'https://github.com/EBSCO-GSS/ruby_folio'
  s.license     = 'MIT'
end