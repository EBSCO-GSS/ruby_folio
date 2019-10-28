# Installation

### Build from source
`gem build folio_lsp.gemspec`

### Install from local
`gem install ./folio_lsp-0.0.1.gem`

# Using IRB to test

Use `irb` to fire up the inline ruby environment and then...

Include the gem
`require 'folio_lsp'`

Start a new Okapi session / get Okapi Token
`mySession = EBSCO::FOLIO::Session.new({:user => 'YOUR-OKAPI-USERNAME', :pass => 'YOUR-OKAPI-PASSWORD', :okapi_tenant => 'YOUR-OKAPI-TENANT', :okapi_host => 'YOUR-OKAPI-HOST'})`

Get Item RTAC (example intance ID included)
`itemRTAC = mySession.get_rtac('7f380ee2-67d8-4d00-8435-a3af64b10b31')`
