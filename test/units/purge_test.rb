# frozen_string_literal: true

require "test_helper"

class PurgeTest < Imgix::Test
  def test_runtime_error_without_api_key
    assert_raises(RuntimeError) do
      mock_client(api_key: nil).purge(mock_image)
    end
  end

  def test_successful_purge
    stub_request(:post, endpoint).with(body: body).to_return(status: 200)

    mock_client(api_key: "10adc394").purge("/images/demo.png")

    assert_requested(
      :post,
      endpoint,
      body: "url=https%3A%2F%2Fdemo.imgix.net%2Fimages%2Fdemo.png",
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
      "Authorization" => "Bearer MTBhZGMzOTQ6",
      "Content-Type" => "application/json",
      "User-Agent" => "imgix rb-#{Imgix::VERSION}"
    }
  end

  def mock_image
    "https://demo.imgix.net/images/demo.png"
  end

  def endpoint
    "https://api.imgix.com/api/v1/purge"
  end

  def body
    { "url" => mock_image }
  end
end
