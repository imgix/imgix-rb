# frozen_string_literal: true

require 'test_helper'

class ParamHelpers < Imgix::Test
  def test_param_helpers_emits_dep_warning
    host_warn = "Warning: The identifier `host' has been deprecated and " \
                "will\nappear as `domain' in the next major version, e.g. " \
                "`@host'\nbecomes `@domain', `options[:host]' becomes " \
                "`options[:domain]'.\n"

    assert_output(nil, host_warn) {
        client = Imgix::Client.new(host: 'test.imgix.net')
        rect_warn = "Warning: `ParamHelpers.rect` has been deprecated and " \
                    "will be removed in the next major version.\n"

        assert_output(nil, rect_warn){
            client.path('/images/demo.png').rect(x: 0, y: 50, width: 200, height: 300)
        }
    }
  end
end