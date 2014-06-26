# Qonf

Versitle configuration management.  Pull data from ENV or config files.  Simplest use case:

## Usage

Qonf works well with or without Rails.  If using Rails, Qonf will assume config files are in `Rails.root/config` directory.  Otherwise, you'll need to set the root yourself:

    Qonf.configure do
      self.base_dir = "./config"
    end

Qonf also allows you to use environment based keys, these will come preconfigured for Rails or could be set by other ruby applications:

    Qonf.configure do
      self.env = "staging" # hash under this key will be merged into top-level hash
      self.environments = %w{test staging production} # these will be removed from hash if they are top-level keys
    end

So, if you config is as follows:
    
    # config/names.json
    {
      "test": {
        "name": "Test data"
      },
      "staging": {
        "name": "Bob Jones"
      }
    }

    Qonf.get(:names,:name) # Bob Jones

## Config Files

Config files can be either json or yml.  They are addressed by name and must live in the `base_dir` path (for Rails, this is `Rails.root/config`)

    # config/qonf.json
    {
      "host": "http://google.com"
    }

    Qonf.host # "http://google.com"

YAML can also be used:

    # config/redis.yml
    development:
      host: localhost

    Qonf.get(:redis,:host) # "localhost"

## Installation

Add this line to your application's Gemfile:

    gem 'qonf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qonf

## Testing

Tests are maintained by RSpec.  To run test cases:

    bundle exec rake test

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
