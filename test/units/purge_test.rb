require 'test_helper'

class PurgeTest < Imgix::Test
  def test_runtime_error_without_api_token
    assert_raises(RuntimeError) {
      Imgix::Client.new(host: 'demo.imgix.net', include_library_param: false)
      .purge('https://demo.imgix.net/images/demo.png')
    }
  end
  
  def test_successful_purge
    stub_request(:post, "https://api.imgix.com/v2/image/purger").
      with(
        body: {"url"=>"https://demo.imgix.net/images/demo.png"}).
      to_return(status: 200)

    Imgix::Client.new(host: 'demo.imgix.net', include_library_param: false, api_token: '10adc394')
    .purge('/images/demo.png')
    
    assert_requested :post, 'https://api.imgix.com/v2/image/purger',
      body:  'url=https%3A%2F%2Fdemo.imgix.net%2Fimages%2Fdemo.png',
      headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic MTBhZGMzOTQ6', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'},
      times: 1
  end
end