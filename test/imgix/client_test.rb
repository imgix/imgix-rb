require 'test_helper'

describe Imgix::Client do
  describe '#host_for_cycle' do
    let(:client) { Imgix::Client.new(hosts: ['host1', 'host2']) }

    it 'returns host value in calling cycle' do
      client.host_for_cycle.must_equal "host1"
      client.host_for_cycle.must_equal "host2"
      client.host_for_cycle.must_equal "host1"
    end
  end
end
