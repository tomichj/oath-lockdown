# Oath::Lockdown

An authentication system for Rails built on [Oath].

[Oath] is a fantastic authorization toolkit. `Oath::Lockdown` enhances Oath, adding:

* "remember me" capabilities
* brute force penetration detection
* session idle timeout
* session max lifetime
* basic auditing/tracking
* csrf rotation on signon


## Installation

### Install the gem

Add this line to your application's Gemfile:

    gem 'oath-lockdown'

And then execute:

    $ bundle

### Use The Install Generator

Use the install generator:

    rails g oath:lockdown:install

This will install:
* an initializer at `app/config/initializers/oath-lockdown.rb`
* localization in english at `app/config/locales/oath.lockdown.en.yml`
* database migrations for the user table, adding columns for: brute force, tracking, and rememberable
** if you won't be using any of those features, you can remove the migration

Now apply the migrations:

    rails db:migrate

### Tweak the configuration

The config parameters you'll typically want to tweak are already enumerated in 
`app/config/initializers/oath-lockdown.rb`. Open it up and tweak the settings.

Configuration parameters are described in detail here: [Configuration](lib/oath/lockdown/configuration.rb)


## Contributing

1. [Fork it](http://github.com/tomichj/oath-lockdown/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[Oath]: https://github.com/halogenandtoast/oath
