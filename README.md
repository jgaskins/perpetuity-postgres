# Perpetuity::Postgres

This is the PostgreSQL adapter for [Perpetuity](https://github.com/jgaskins/perpetuity), a Data Mapper-pattern persistence gem. The Data Mapper pattern puts persistence logic into mapper objects and keeps it out of your domain models. This keeps your domain models lightweight and focused.

## Installation

Add this line to your application's Gemfile:

    gem 'perpetuity-postgres'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install perpetuity-postgres

## Usage

To configure Perpetuity to use your PostgreSQL database, you can use the same parameters as you would with the MongoDB adapter, except substitute `:postgres` in for `:mongodb`:

```ruby
require 'perpetuity-postgres' # Unnecessary if using Rails
Perpetuity.data_source :postgres, 'my_perpetuity_database'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
