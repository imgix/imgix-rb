$LOAD_PATH << 'lib'
require 'imgix'
require 'benchmark/ips'

client = Imgix::Client.new(domain: 'domain.com', secure_url_token: 'token')

Benchmark.ips do |x|
  x.report('Imgix::Path#initialize') do
    client.path("/img.jpg")
  end
end
