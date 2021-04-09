# frozen_string_literal: true

require "test_helper"

class PathTest < Imgix::Test
  def test_creating_a_path
    path = client.path("/images/demo.png")
    assert_equal "https://demo.imgix.net/images/demo.png?s=2c7c157eaf23b06a0deb2f60b81938c4", path.to_url

    path = client.path("images/demo.png")
    assert_equal "https://demo.imgix.net/images/demo.png?s=2c7c157eaf23b06a0deb2f60b81938c4", path.to_url
  end

  def test_signing_path_with_param
    url = "https://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e"
    path = client.path("/images/demo.png").w(200)
    assert_equal url, path.to_url
  end

  def test_resetting_defaults
    url = "https://demo.imgix.net/images/demo.png?w=200&s=da421114ca238d1f4a927b889f67c34e"
    path = client.path("/images/demo.png")
    assert_equal url, path.defaults.width(200).to_url
  end

  # Test path.w(value) and path.width(value) produce the same URL.
  def test_aliases_w_and_width
    expected = "https://demo.imgix.net/image.png?w=720"
    actual_w = unsigned_client.path("image.png").w(720)
    actual_width = unsigned_client.path("image.png").width(720)
    assert_equal expected, actual_w.to_url, actual_width.to_url
  end

  # Test mark64 is an alias for watermark64.
  def test_aliases_mark_watermark
    expected = "https://static.imgix.net/lorie.png?" \
      "h=480&w=320&mark64=aHR0cHM6Ly9hc3NldHMuaW1naXgubmV0L3ByZXNza2l0L2" \
      "ltZ2l4LXByZXNza2l0LnBkZj9wYWdlPTQmZm09cG5n"

    mark_img_url = "https://assets.imgix.net/presskit/imgix-presskit.pdf?page=4&fm=png"

    client = Imgix::Client.new(
      domain: "static.imgix.net",
      include_library_param: false
    )

    actual = client.path("lorie.png").h(480).w(320).mark64(mark_img_url)
    assert_equal expected, actual.to_url
  end

  def test_path_with_multiple_params
    url = "https://demo.imgix.net/images/demo.png?h=200&w=200&s=d570a1ecd765470f7b34a69b56718a7a"
    path = client.path("/images/demo.png").h(200).w(200)
    assert_equal url, path.to_url
  end

  def test_relative_path_with_params
    url = "https://demo.imgix.net/images/demo.png?h=200&w=200&s=d570a1ecd765470f7b34a69b56718a7a"
    path = client.path("images/demo.png").h(200).w(200)
    assert_equal url, path.to_url
  end

  def test_file_path_with_reserved_delimiters
    url = "https://demo.imgix.net/%20%3C%3E%5B%5D%7B%7D%7C%5C%5C%5E%25.jpg?h=200&w=200&s=c53e7dc75b2d8fb70006f12357881622"
    path = client.path("/ <>[]{}|\\\\^%.jpg").h(200).w(200)
    assert_equal url, path.to_url
  end

  def test_path_with_multi_value_param_safely_encoded
    url = "https://demo.imgix.net/images/demo.png?markalign=middle%2Ccenter&s=f0d0e28a739f022638f4ba6dddf9b694"
    path = client.path("/images/demo.png").markalign("middle,center")

    assert_equal url, path.to_url
  end

  def test_param_keys_are_escaped
    ix_url = unsigned_client.path("demo.png").to_url({ "hello world" => "interesting" })

    assert_equal "https://demo.imgix.net/demo.png?hello%20world=interesting", ix_url
  end

  def test_param_values_are_escaped
    ix_url = unsigned_client.path("demo.png").to_url({ hello_world: "/foo\"> <script>alert(\"hacked\")</script><" })

    assert_equal "https://demo.imgix.net/demo.png?hello_world=%2Ffoo%22%3E%20%3Cscript%3Ealert%28%22hacked%22%29%3C%2Fscript%3E%3C", ix_url
  end

  def test_base64_param_variants_are_base64_encoded
    ix_url = unsigned_client.path("~text").to_url({txt64: "I cannøt belîév∑ it wors! 😱"})

    assert_equal "https://demo.imgix.net/~text?txt64=SSBjYW5uw7h0IGJlbMOuw6l24oiRIGl0IHdvcu-jv3MhIPCfmLE", ix_url
  end

  def test_domain_is_required
    assert_raises(ArgumentError) { Imgix::Client.new }
  end

  def test_token_is_optional
    client = Imgix::Client.new(domain: "demo.imgix.net", include_library_param: false)
    url = "https://demo.imgix.net/images/demo.png"
    path = client.path("/images/demo.png")

    assert_equal url, path.to_url
  end

  def test_https_is_optional
    client = Imgix::Client.new(domain: "demo.imgix.net", include_library_param: false, use_https: false)
    url = "http://demo.imgix.net/images/demo.png"
    path = client.path("/images/demo.png")

    assert_equal url, path.to_url
  end

  def test_full_url
    path = "https://google.com/cats.gif"

    assert_equal "https://demo.imgix.net/#{CGI.escape(path)}?s=e686099fbba86fc2b8141d3c1ff60605", client.path(path).to_url
  end

  def test_full_url_with_a_space
    path = "https://my-demo-site.com/files/133467012/avatar icon.png"
    assert_equal "https://demo.imgix.net/#{CGI.escape(path)}?s=35ca40e2e7b6bd208be2c4f7073f658e", client.path(path).to_url
  end

  def test_include_library_param
    client = Imgix::Client.new(domain: "demo.imgix.net") # enabled by default
    url = client.path("/images/demo.png").to_url

    assert_equal "ixlib=rb-#{Imgix::VERSION}", URI(url).query
  end

  def test_configure_library_param
    library = "sinatra"
    version = Imgix::VERSION
    client = Imgix::Client.new(domain: "demo.imgix.net", library_param: library, library_version: version) # enabled by default
    url = client.path("/images/demo.png").to_url

    assert_equal "ixlib=#{library}-#{version}", URI(url).query
  end

  private

  def client
    @client ||= Imgix::Client.new(domain: "demo.imgix.net", secure_url_token: "10adc394", include_library_param: false)
  end

  def unsigned_client
    @unsigned_client ||= Imgix::Client.new(domain: "demo.imgix.net", include_library_param: false)
  end
end
