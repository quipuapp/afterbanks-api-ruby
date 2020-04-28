# Ruby client for Afterbanks API

[![CircleCI](https://circleci.com/gh/quipuapp/afterbanks-api-ruby.svg?style=shield)](https://circleci.com/gh/quipuapp/afterbanks-api-ruby)

This is a Ruby client for the Afterbanks' API

Changelog
---------

* v.0.1.0 First vull version, including resource wrapping (for banks, accounts, transactions and the user) and separate exceptions for each different code.

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

TODO
----

* Full usage for each resource
* Proper explanation of the `Afterbanks:Error` and its subclasses

About Afterbanks
------------

* [Public site](https://www.afterbanks.com)
* [Documentation](https://app.swaggerhub.com/apis/Afterbanks/afterbanks-api-extendida)
