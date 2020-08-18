# frozen_string_literal: true

require "test_helper"
require "json"

class PurgeTest < Imgix::Test
  def test_runtime_error_without_api_key
    assert_raises(RuntimeError) do
      mock_client(api_key: nil).purge(mock_image_url)
    end
  end

  def test_successful_purge
    stub_request(:post, endpoint).with(
      body: json_request_body(mock_image_url),
      headers: mock_headers
    ).to_return(
      status: 200,
      body: "",
      headers: {}
    )

    mock_client(api_key: mock_api_key).purge("/images/demo.png")

    assert_requested(
      :post,
      endpoint,
      body: json_request_body(mock_image_url),
      headers: mock_headers,
      times: 1
    )
  end

  private

  def mock_client(api_key: "")
    Imgix::Client.new(
      domain: "demo.imgix.net",
      api_key: api_key,
      include_library_param: false
    )
  end

  def mock_headers
    {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Authorization" => "Bearer #{mock_api_key}",
      "Content-Type" => "application/json",
      "User-Agent" => "imgix rb-#{Imgix::VERSION}"
    }
  end

  def mock_image_url
    "https://demo.imgix.net/images/demo.png"
  end

  def mock_api_key
    "ak_10adc394-10adc394-10adc394-10adc394-10adc394-10adc394-10adc394__"
  end

  def json_request_body(url)
    {
      data: {
        attributes: {
            url: url
        },
        type: "purges"
      }
    }.to_json
  end

  def endpoint
    "https://api.imgix.com/api/v1/purge"
  end
end
