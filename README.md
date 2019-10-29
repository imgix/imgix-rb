# Imgix

Official Ruby Gem for signing [imgix](http://imgix.com) URLs. Tested under 2.3.0, 2.2.4, 2.1.8, jruby-9.0.5.0, and rbx-2.11.

[![Build Status](https://travis-ci.org/imgix/imgix-rb.svg?branch=master)](https://travis-ci.org/imgix/imgix-rb)

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

Initialize a client with a `:host` and your `:secure_url_token`. By default, HTTPS URLs are generated, but you can toggle that by passing `use_https: false`.

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

## Srcset Generation

The imgix gem allows for generation of custom `srcset` attributes, which can be invoked through `Imgix::Path#to_srcset`. By default, the `srcset` generated will allow for responsive size switching by building a list of image-width mappings.

```rb
client = Imgix::Client.new(host: 'your-subdomain.imgix.net', secure_url_token: 'your-token', include_library_param: false)
path = client.path('/images/demo.png')

srcset = path.to_srcset
```

Will produce the following attribute value, which can then be served to the client:

```html
https://your-subdomain.imgix.net/images/demo.png?w=100&s=efb3e4ae8eaa1884357f40510b11787c 100w,
https://your-subdomain.imgix.net/images/demo.png?w=116&s=1417ebeaaaecff39533408cb44893eda 116w,
https://your-subdomain.imgix.net/images/demo.png?w=134&s=4e45e67c087df930b9ddc8cf5be869d0 134w,
                                            ...
https://your-subdomain.imgix.net/images/demo.png?w=7400&s=a5dd7dda1dbac613f0475f1ffd90ef79 7400w,
https://your-subdomain.imgix.net/images/demo.png?w=8192&s=9fbd257c53e770e345ce3412b64a3452 8192w
```

In cases where enough information is provided about an image's dimensions, `to_srcset` will instead build a `srcset` that will allow for an image to be served at different resolutions. The parameters taken into consideration when determining if an image is fixed-width are `w`, `h`, and `ar`. By invoking `to_srcset` with either a width **or** the height and aspect ratio (along with `fit=crop`, typically) provided, a different `srcset` will be generated for a fixed-size image instead.

```rb
client = Imgix::Client.new(host: 'your-subdomain.imgix.net', secure_url_token: 'your-token', include_library_param: false)
path = client.path('/images/demo.png')

srcset = path.to_srcset(h:800, ar:'3:2', fit:'crop')
```

Will produce the following attribute value:

```html
https://your-subdomain.imgix.net/images/demo.png?h=800&ar=3%3A2&fit=crop&dpr=1&s=f97f2dccf85beac33a3824b57ef4ddc6 1x,
https://your-subdomain.imgix.net/images/demo.png?h=800&ar=3%3A2&fit=crop&dpr=2&s=e1727167fef53cdb0a89dd66b8672410 2x,
https://your-subdomain.imgix.net/images/demo.png?h=800&ar=3%3A2&fit=crop&dpr=3&s=7718db8457345419c30214f1d1a3a5d3 3x,
https://your-subdomain.imgix.net/images/demo.png?h=800&ar=3%3A2&fit=crop&dpr=4&s=000c50a7f97ccdbb9bb2f00bc5241ed4 4x,
https://your-subdomain.imgix.net/images/demo.png?h=800&ar=3%3A2&fit=crop&dpr=5&s=970b6fc12a410f3dd2959674dd1f4120 5x
```

For more information to better understand `srcset`, we highly recommend [Eric Portis' "Srcset and sizes" article](https://ericportis.com/posts/2014/srcset-sizes/) which goes into depth about the subject.

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
