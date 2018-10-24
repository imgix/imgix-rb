require 'test_helper'

class PurgeTest < Imgix::Test
  def test_runtime_error_without_secure_url_token
    assert_raises(RuntimeError) {
      Imgix::Client.new(host: 'demo.imgix.net', include_library_param: false)
      .purge('https://demo.imgix.net/images/demo.png?s=2c7c157eaf23b06a0deb2f60b81938c4')
    }
  end
  
  def test_successful_purge
    stub_request(:post, "https://api.imgix.com/v2/image/purger").
      with(
        body: {"url"=>"https://demo.imgix.net/images/demo.png?s=2c7c157eaf23b06a0deb2f60b81938c4"}).
      to_return(status: 200)

    Imgix::Client.new(host: 'demo.imgix.net', include_library_param: false, secure_url_token: '10adc394')
    .purge('https://demo.imgix.net/images/demo.png?s=2c7c157eaf23b06a0deb2f60b81938c4')
    
    assert_requested :post, 'https://api.imgix.com/v2/image/purger',
      body:  'url=https%3A%2F%2Fdemo.imgix.net%2Fimages%2Fdemo.png%3Fs%3D2c7c157eaf23b06a0deb2f60b81938c4',
      headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic MTBhZGMzOTQ6', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'},
      times: 1
  end
end