# Ruby client for Afterbanks API

[![CircleCI](https://circleci.com/gh/quipuapp/afterbanks-api-ruby.svg?style=shield)](https://circleci.com/gh/quipuapp/afterbanks-api-ruby)

This is a Ruby client for the Afterbanks' API

Installation
---------

Install the gem (`gem install afterbanks-api-ruby`) or include it in your Gemfile and `bundle`.

Configuration
---------

Just set the service key by doing this:

```ruby
Afterbanks.servicekey = 'yourservicekey'
```

Or, if you use it in a Rails application, create an initializer with this content:

```ruby
require 'afterbanks'

Afterbanks.configure do |config|
  config.servicekey = 'yourservicekey'
end
```

You can set a `logger` as well.

Changelog
---------

* v.0.4.0 Add new, opt-in error for missing product, and several internal improvements
* v.0.3.4 Security: upgrade addressable from 2.7.0 to 2.8.0
* v.0.3.3 Transaction and Account are compatible with account ID
* v.0.3.2 Properly handle account ID needed errors
* v.0.3.1 Small spec improvements
* v.0.3.0 Set a higher timeout so it works properly with ING Direct
* v.0.2.3 Better logging
* v.0.2.2 Better naming (fix Caixa Guissona, Caixa Burriana and Banco Pichincha)
* v.0.2.1 Better naming for banks (add Particulares for the proper ones, and use Caixa Enginyers)
* v.0.2.0 Allow adding an (opt-in) random parameter to Afterbanks::Account.list to avoid caching
* v.0.1.1 Fix rake security issue and remove specific Ruby version dependency.
* v.0.1.0 First vull version, including resource wrapping (for banks, accounts, transactions and the user) and separate exceptions for each different code.

TODO
----

* Full usage for each resource
* Proper explanation of the `Afterbanks:Error` and its subclasses

About Afterbanks
------------

* [Public site](https://www.afterbanks.com)
* [Documentation](https://app.swaggerhub.com/apis/Afterbanks/afterbanks-api-extendida)
