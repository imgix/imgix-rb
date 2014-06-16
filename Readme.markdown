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

Now, if you have the URL ready to go, you can call `sign_path` to get the Imgix URL back. If you would like to manipulate the path parameters you can call `path` with the resource path to get an Imgix::Path object back.

``` ruby
client = Imgix::Client.new(:host => 'your-subdomain.imgix.net', :token => 'your-token', :secure => true)

client.sign_path('/images/demo.png?w=200')
#=> https://your-subdomain.imgix.net/images/demo.png?w=200&s=2eadddacaa9bba4b88900d245f03f51e

# OR
client.path('/images/demo.png').to_url(w: 200)

# OR
path = client.path('/images/demo.png')
path.width = 200
path.to_url

# OR
client.path('/images/demo.png').width(200).height(300).to_url

# Some other tricks
path.defaults.width(300).to_url # Resets parameters
path.rect(x: 0, y: 50, width: 200, height: 300).to_url # Rect helper
```

# Domain Sharded URLs
Domain sharding enables you to spread image requests across multiple domains. This allows you to bypass the requests-per-host limits of browsers. We recommend 2-3 domain shards maximum if you are going to use domain sharding.

In order to use domain sharding, you need to add multiple domains to your source. You then provide a list of these domains to a builder.


``` ruby
client = Imgix::Client.new(:hosts => ['your-subdomain-1.imgix.net', 'your-subdomain-2.imgix.net'])
```
By default, shards are calculated using a checksum so that the image path always resolves to the same domain. This improves caching in the browser. However, you can also specify cycle that simply cycles through the domains as you request them.


``` ruby
client = Imgix::Client.new(:hosts => ['your-subdomain-1.imgix.net', 'your-subdomain-2.imgix.net'], :shard_strategy => :cycle))
```
# Multiple Parameters
When the imgix api requires multiple parameters you have to use the method rather than an accessor.
For example to use the [noise reduction](http://www.imgix.com/docs/urlapi/enhance#nr-nrs) options

``` ruby
path.noise_reduction(50,50)
```


## Supported Ruby Versions

Imgix is tested under 1.9.2, 1.9.3, 2.0.0, JRuby 1.7.2 (1.9 mode), and Rubinius 2.0.0 (1.9 mode).

[![Build Status](https://travis-ci.org/soffes/imgix-rb.png?branch=master)](https://travis-ci.org/soffes/imgix-rb)


## Contributing

See the [contributing guide](Contributing.markdown).
