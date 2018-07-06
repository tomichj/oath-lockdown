# Oath::Ironclad

An authentication system built on top of the [Oath](https://github.com/halogenandtoast/oath) authentication library.

Oath-ironclad provides Oath with new warden hooks and strategies. 

## Installation

Add this line to your application's Gemfile:

    gem 'oath-ironclad'

And then execute:

    $ bundle

## Install

Install oath-ironclad with the install generator:

    rails g oath:ironclad:install

This will install:
* localization in english at `app/config/locales/oath.ironclad.en.yml`
* an initializer at `app/config/initializers/oath-ironclad.rb` with all values commented out.
* database migrations for the user table to add brute force and tracking columns 



## Contributing

1. [Fork it](http://github.com/tomichj/oath-ironclad/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
