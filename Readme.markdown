# Imgix

Unofficial Ruby Gem for signing [imgix](http://imgix.com) URLs.


## Installation

Add this line to your application's Gemfile:

    gem 'imgix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install imgix


## Usage

Simply initialize a client with a host and your token. You can optionally generate secure URLs.

Now call `sign_path` on your client to get a signed URL.

``` ruby
client = Imgix::Client.new(:host => 'your-subdomain.imgix.net', :token => 'your-token', :secure => true)
client.sign_path('/images/demo.png?w=200')
#=> https://your-subdomain.imgix.net/images/demo.png?w=200&s=2eadddacaa9bba4b88900d245f03f51e
```

## Supported Ruby Versions

Imgix is tested under 1.8.7, 1.9.2, 1.9.3, 2.0.0, JRuby 1.7.2 (1.9 mode), and Rubinius 2.0.0 (1.9 mode).

[![Build Status](https://travis-ci.org/soffes/imgix-rb.png?branch=master)](https://travis-ci.org/soffes/imgix-rb)


## Contributing

See the [contributing guide](Contributing.markdown).
