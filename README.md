<!-- ix-docs-ignore -->
![imgix logo](https://assets.imgix.net/sdk-imgix-logo.svg)

`imgix-rb` is a client library for generating image URLs with [imgix](https://www.imgix.com/). It is tested under Ruby versions `2.3.0`, `2.2.4`, `2.1.8`, `jruby-9.2.11.0`, and `rbx-3.107`.

[![Gem Version](https://img.shields.io/gem/v/imgix.svg)](https://rubygems.org/gems/imgix)
[![Build Status](https://travis-ci.org/imgix/imgix-rb.svg?branch=main)](https://travis-ci.org/imgix/imgix-rb)
![Downloads](https://img.shields.io/gem/dt/imgix)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/imgix/imgix-rb/blob/main/LICENSE)

---
<!-- /ix-docs-ignore -->

- [Installation](#installation)
- [Usage](#usage)
- [Srcset Generation](#srcset-generation)
  - [Fixed image rendering](#fixed-image-rendering)
  - [Custom Widths](#custom-widths)
  - [Width Tolerance](#width-tolerance)
  - [Minimum and Maximum Width Ranges](#minimum-and-maximum-width-ranges)
  - [Variable Qualities](#variable-qualities)
- [Multiple Parameters](#multiple-parameters)
- [Purge Cache](#purge-cache)
- [URL encoding and signed imgix URLs](#url-encoding-and-signed-imgix-urls)
- [What is the `ixlib` param on every request?](#what-is-the-ixlib-param-on-every-request)
- [Contributing](#contributing)

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

Initialize a client with a `:domain` and your `:secure_url_token`. By default, HTTPS URLs are generated, but you can toggle that by passing `use_https: false`.

Call `Imgix::Client#path` with the resource path to get an `Imgix::Path` object back. You can then manipulate the path parameters, and call `Imgix#Path#to_url` when you're done.

``` ruby
client = Imgix::Client.new(domain: 'your-subdomain.imgix.net', secure_url_token: 'your-token')

client.path('/images/demo.png').to_url(w: 200)
#=> https://your-subdomain.imgix.net/images/demo.png?w=200&s=2eadddacaa9bba4b88900d245f03f51e


## Srcset Generation

The imgix gem allows for generation of custom `srcset` attributes, which can be invoked through `Imgix::Path#to_srcset`. By default, the `srcset` generated will allow for responsive size switching by building a list of image-width mappings.

```rb
client = Imgix::Client.new(domain: 'your-subdomain.imgix.net', secure_url_token: 'your-token', include_library_param: false)
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

### Fixed image rendering

In cases where enough information is provided about an image's dimensions, `to_srcset` will instead build a `srcset` that will allow for an image to be served at different resolutions. The parameters taken into consideration when determining if an image is fixed-width are `w`, `h`, and `ar`. By invoking `to_srcset` with either a width **or** the height and aspect ratio (along with `fit=crop`, typically) provided, a different `srcset` will be generated for a fixed-size image instead.

```rb
client = Imgix::Client.new(domain: 'your-subdomain.imgix.net', secure_url_token: 'your-token', include_library_param: false)
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

### Custom Widths

In situations where specific widths are desired when generating `srcset` pairs, a user can specify them by passing an array of integers via `widths` to the `options` keyword argument.

```rb
@client ||= Imgix::Client.new(domain: 'testing.imgix.net', include_library_param: false)
.path('image.jpg')
.to_srcset(options: { widths: [100, 500, 1000, 1800] })
```

Will generate the following `srcset` of width pairs:

```html
https://testing.imgix.net/image.jpg?w=100 100w,
https://testing.imgix.net/image.jpg?w=500 500w,
https://testing.imgix.net/image.jpg?w=1000 1000w,
https://testing.imgix.net/image.jpg?w=1800 1800w
```

Please note that in situations where a `srcset` is being rendered as a [fixed image](#fixed-image-rendering), any custom `widths` passed in will be ignored. Additionally, if both `widths` and a `width_tolerance` are passed to the `options` parameter in the `to_srcset` method, the custom widths list will take precedence.

### Width Tolerance

The `srcset` width tolerance dictates the maximum tolerated size difference between an image's downloaded size and its rendered size. For example: setting this value to 0.1 means that an image will not render more than 10% larger or smaller than its native size. In practice, the image URLs generated for a width-based srcset attribute will grow by twice this rate. A lower tolerance means images will render closer to their native size (thereby reducing rendering artifacts), but a large srcset list will be generated and consequently users may experience lower rates of cache-hit for pre-rendered images on your site.

By default this rate is set to 8 percent, which we consider to be the ideal rate for maximizing cache hits without sacrificing visual quality. Users can specify their own width tolerance by passing a positive numeric value to `width_tolerance` within the `options` keyword argument:

```rb
client = Imgix::Client.new(domain: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
client.path('image.jpg').to_srcset(options: { width_tolerance: 0.20 })
```

In this case, the `width_tolerance` is set to 20 percent, which will be reflected in the difference between subsequent widths in a srcset pair:

```
https://testing.imgix.net/image.jpg?w=100 100w,
https://testing.imgix.net/image.jpg?w=140 140w,
https://testing.imgix.net/image.jpg?w=196 196w,
							...
https://testing.imgix.net/image.jpg?w=8192 8192w
```

### Minimum and Maximum Width Ranges

If the exact number of minimum/maximum physical pixels that an image will need to be rendered at is known, a user can specify them by passing an integer via `min_srcset` and/or `max_srcset` to the `options` keyword parameters:

```rb
client = Imgix::Client.new(domain: 'testing.imgix.net', include_library_param: false)
client.path('image.jpg').to_srcset(options: { min_srcset: 500, max_srcset: 2000 })
```

Will result in a smaller, more tailored srcset.

```
https://testing.imgix.net/image.jpg?w=500 500w,
https://testing.imgix.net/image.jpg?w=580 580w,
https://testing.imgix.net/image.jpg?w=672 672w,
https://testing.imgix.net/image.jpg?w=780 780w,
https://testing.imgix.net/image.jpg?w=906 906w,
https://testing.imgix.net/image.jpg?w=1050 1050w,
https://testing.imgix.net/image.jpg?w=1218 1218w,
https://testing.imgix.net/image.jpg?w=1414 1414w,
https://testing.imgix.net/image.jpg?w=1640 1640w,
https://testing.imgix.net/image.jpg?w=1902 1902w,
https://testing.imgix.net/image.jpg?w=2000 2000w
```

Remember that browsers will apply a device pixel ratio as a multiplier when selecting which image to download from a `srcset`. For example, even if you know your image will render no larger than 1000px, specifying `options: { max_srcset: 1000 }` will give your users with DPR higher than 1 no choice but to download and render a low-resolution version of the image. Therefore, it is vital to factor in any potential differences when choosing a minimum or maximum range.

Also please note that according to the [imgix API](https://docs.imgix.com/apis/url/size/w), the maximum renderable image width is 8192 pixels.

### Variable Qualities

This gem will automatically append a variable `q` parameter mapped to each `dpr` parameter when generating a [fixed-image](https://github.com/imgix/imgix-rb#fixed-image-rendering) srcset. This technique is commonly used to compensate for the increased filesize of high-DPR images. Since high-DPR images are displayed at a higher pixel density on devices, image quality can be lowered to reduce overall filesize without sacrificing perceived visual quality. For more information and examples of this technique in action, see [this blog post](https://blog.imgix.com/2016/03/30/dpr-quality).

This behavior will respect any overriding `q` value passed in as a parameter. Additionally, it can be disabled altogether by passing `options: { disable_variable_quality: true }` to `Imgix:Path#to_srcset`.

This behavior specifically occurs when a [fixed-size image](https://github.com/imgix/imgix-rb#fixed-image-rendering) is rendered, for example:

```rb
srcset = Imgix::Client.new(domain: 'testing.imgix.net', include_library_param: false)
.path('image.jpg')
.to_srcset(w:100)
```

will generate a srcset with the following `q` to `dpr` mapping:

```html
https://testing.imgix.net/image.jpg?w=100&dpr=1&q=75 1x,
https://testing.imgix.net/image.jpg?w=100&dpr=2&q=50 2x,
https://testing.imgix.net/image.jpg?w=100&dpr=3&q=35 3x,
https://testing.imgix.net/image.jpg?w=100&dpr=4&q=23 4x,
https://testing.imgix.net/image.jpg?w=100&dpr=5&q=20 5x
```

## Purge Cache

If you need to remove or update an image on imgix, you can purge it from our cache by initializing a client with your [api key](http://dashboard.imgix.com/api-keys), then calling `Imgix::Client#purge` with the resource path.

```ruby
client = Imgix::Client.new(domain: 'your-subdomain.imgix.net', api_key: 'your-key')
client.purge('/images/demo.png')
```

To learn more about purging assets with imgix, [see our docs](https://docs.imgix.com/setup/purging-images).

## URL encoding and signed imgix URLs

Some important third parties (like Facebook) apply URL escaping to query string components, which can cause correctly signed imgix URLs to to be transformed into incorrectly signed ones. We URL encode the query part of the URL before signing, so you don't have to worry about this.

## What is the `ixlib` param on every request?

For security and diagnostic purposes, we sign all requests with the language and version of library used to generate the URL.

This can be disabled by including `include_library_param: false` in the instantiation Hash parameter for `Imgix::Client`:

```ruby
client = Imgix::Client.new(domain: 'your-subdomain.imgix.net', include_library_param: false )
```

## Contributing

See the [contributing guide](Contributing.markdown).
