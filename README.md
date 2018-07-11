# Oath::Ironclad

An authentication system built on top of the [Oath](https://github.com/halogenandtoast/oath) authentication library.

Oath-ironclad provides Oath with new warden hooks and strategies. 

## Installation

### Install the gem

Add this line to your application's Gemfile:

    gem 'oath-ironclad'

And then execute:

    $ bundle

### Use The Install Generator

Install oath-ironclad with the install generator:

    rails g oath:ironclad:install

This will install:
* localization in english at `app/config/locales/oath.ironclad.en.yml`
* an initializer at `app/config/initializers/oath-ironclad.rb` with all values commented out.
* database migrations for the user table, adding columns for: brute force, tracking, and rememberable
** if you won't be using any of those features, you can remove the migration

Now apply the migrations:

    rails db:migrate

### Tweak the configuration

The config parameters you'll typically want to tweak are already enumerated in 
`app/config/initializers/oath-ironclad.rb`. Open it up and tweak the settings.

Configuration parameters are described in detail here: [Configuration](lib/oath/ironclad/configuration.rb)



## Contributing

1. [Fork it](http://github.com/tomichj/oath-ironclad/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
