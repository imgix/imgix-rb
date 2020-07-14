# frozen_string_literal: true

require 'test_helper'

class ParamHelpers < Imgix::Test
  def test_param_helpers_emits_dep_warning
    msg = "Warning: `ParamHelpers.rect` has been deprecated and " \
          "will be removed in the next major version.\n"

    assert_output(nil,msg){
        ||
        client = Imgix::Client.new(host: 'test.imgix.net')
        client.path('/images/demo.png').rect(x: 0, y: 50, width: 200, height: 300)
    }
  end
end