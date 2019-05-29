# Imgix

Official Ruby Gem for signing [imgix](http://imgix.com) URLs. Tested under 2.3.0, 2.2.4, 2.1.8, jruby-9.0.5.0, and rbx-2.11.

[![Build Status](https://travis-ci.org/imgix/imgix-rb.png?branch=master)](https://travis-ci.org/imgix/imgix-rb)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'imgix'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install imgix


## Usage

Simply initialize a client with a `:host` and your `:secure_url_token`. By default, HTTPS URLs are generated, but you can toggle that by passing `use_https: false`.

Call `Imgix::Client#path` with the resource path to get an `Imgix::Path` object back. You can then manipulate the path parameters, and call `Imgix#Path#to_url` when you're done.

``` ruby
client = Imgix::Client.new(host: 'your-subdomain.imgix.net', secure_url_token: 'your-token')

client.path('/images/demo.png').to_url(w: 200)
#=> https://your-subdomain.imgix.net/images/demo.png?w=200&s=2eadddacaa9bba4b88900d245f03f51e

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


## Multiple Parameters

When the imgix api requires multiple parameters you have to use the method rather than an accessor.

For example to use the noise reduction:

``` ruby
path.noise_reduction(50,50)
```


## Purge Cache

If you need to remove or update an image on imgix, you can purge it from our cache by initializing a client with your api_key, then calling Imgix::Client#purge with the resource path.

```ruby
client = Imgix::Client.new(host: 'your-subdomain.imgix.net', api_key: 'your-key')
client.purge('/images/demo.png')
```

To learn more about purging assets with imgix, [see our docs](https://docs.imgix.com/setup/purging-images).

## URL encoding and signed ImgIX URLs

Some important third parties (like Facebook) apply URL escaping to query string components, which can cause correctly signed ImgIX URLs to to be transformed into incorrectly signed ones. We URL encode the query part of the URL before signing, so you don't have to worry about this.

## What is the `ixlib` param on every request?

For security and diagnostic purposes, we sign all requests with the language and version of library used to generate the URL.

This can be disabled by including `include_library_param: false` in the instantiation Hash parameter for `Imgix::Client`:

```ruby
client = Imgix::Client.new(host: 'your-subdomain.imgix.net', include_library_param: false )
```

## Contributing

See the [contributing guide](Contributing.markdown).
