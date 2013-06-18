# Imgix

Ruby Gem for signing [imgix](http://imgix.com) URLs.

## Installation

Add this line to your application's Gemfile:

    gem 'imgix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install imgix

## Usage

``` ruby
client = Imgix::Client.new(host: 'your-subdomain.imgix.net', token: 'your-token', secure: true)
client.sign_path('/images/demo.png?w=200')
#=> http://foo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
