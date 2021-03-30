$LOAD_PATH << 'lib'
require 'imgix'
require 'benchmark/ips'

client = Imgix::Client.new(domain: 'domain.com', secure_url_token: 'token')
path = client.path("/img.jpg")

Benchmark.ips do |x|
  x.report('Imgix::Path#to_url') do
    path.to_url({ auto: 'compress,format', fit: 'crop', crop: 'top', w: 590, h: 332 })
  end
end
