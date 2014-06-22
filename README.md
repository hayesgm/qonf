# Qonf

Versitle configuration management.  Pull data from ENV or config files.  Simplest use case:

config/qonf.json
```
{
"host": "http://google.com"
}
```

Qonf.host # "http://google.com"

Additionally, you could make a file config/redis.yml

```
development:
  host: localhost
```

Qonf.get(:redis,:host) # "localhost"

## Installation

Add this line to your application's Gemfile:

    gem 'qonf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qonf

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
