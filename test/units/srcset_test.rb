# frozen_string_literal: true

require "test_helper"

module SrcsetTest
  RESOLUTIONS = [
    100, 116, 135, 156, 181, 210, 244, 283,
    328, 380, 441, 512, 594, 689, 799, 927,
    1075, 1247, 1446, 1678, 1946, 2257, 2619,
    3038, 3524, 4087, 4741, 5500, 6380, 7401, 8192
  ].freeze

  DPR_QUALITY = [75, 50, 35, 23, 20].freeze
  DPR_MULTIPLIER = ["1x", "2x", "3x", "4x", "5x", ].freeze

  DOMAIN = "testing.imgix.net"
  TOKEN = "MYT0KEN"
  JPG_PATH = "image.jpg"

  def mock_client
    Imgix::Client.new(
      domain: DOMAIN,
      include_library_param: false
    ).path(JPG_PATH)
  end

  def mock_signed_client
    Imgix::Client.new(
      domain: DOMAIN,
      secure_url_token: TOKEN,
      include_library_param: false
    ).path(JPG_PATH)
  end

  def signature_base(params)
    TOKEN + "/" + JPG_PATH + params
  end

  def get_sig_from(src)
    src.slice(src.index("s=") + 2, src.length)
  end

  def get_params_from(src)
    src[src.index("?")..src.index("s=") - 2]
  end

  def get_expected_signature(src)
    # Ensure signature param exists.
    assert_includes src, "s="

    params = get_params_from(src)
    signature_base = signature_base(params)

    Digest::MD5.hexdigest(signature_base)
  end

  class SrcsetDefault < Imgix::Test
    include SrcsetTest

    def test_no_parameters
      srcset = path.to_srcset

      expected_number_of_pairs = 31
      assert_equal expected_number_of_pairs, srcset.split(",").length
    end

    def test_srcset_pair_values
      resolutions = RESOLUTIONS
      srcset = path.to_srcset
      srclist = srcset.split(",").map do |srcset_split|
        srcset_split.split(" ")[1].to_i
      end

      (0..srclist.length - 1).each do |i|
        assert_equal(srclist[i], resolutions[i])
      end
    end

    private

    def path
      @client ||= mock_signed_client
    end
  end

  class SrcsetGivenWidth < Imgix::Test
    include SrcsetTest

    def test_srcset_in_dpr_form
      device_pixel_ratio = 1

      srcset.split(",").map do |src|
        ratio = src.split(" ")[1]
        assert_equal "#{device_pixel_ratio}x", ratio
        device_pixel_ratio += 1
      end
    end

    def test_srcset_has_dpr_params
      i = 1
      srcset.split(",").map do |srcset_split|
        src = srcset_split.split(" ")[0]
        assert_includes src, "dpr=#{i}"
        i += 1
      end
    end

    def test_srcset_signs_urls
      srcset.split(",").map do |srcset_split|
        src = srcset_split.split(" ")[0]
        expected_signature = get_expected_signature(src)

        assert_includes src, expected_signature
      end
    end

    def test_srcset_has_variable_qualities
      i = 0
      srcset.split(",").map do |src|
        assert_includes src, "q=#{DPR_QUALITY[i]}"
        i += 1
      end
    end

    def test_srcset_respects_overriding_quality
      quality_override = 100
      srcset = mock_signed_client.to_srcset(w: 100, q: quality_override)

      srcset.split(",").map do |src|
        assert_includes src, "q=#{quality_override}"
      end
    end

    def test_disable_variable_quality
      srcset = mock_signed_client.to_srcset(
        w: 100,
        options: { disable_variable_quality: true }
      )

      srcset.split(",").map do |src|
        assert(!src.include?("q="))
      end
    end

    def test_respects_quality_param_when_disabled
      quality_override = 100
      srcset = mock_signed_client.to_srcset(
        w: 100, q: 100,
        options: { disable_variable_quality: true }
      )

      srcset.split(",").map do |src|
        assert_includes src, "q=#{quality_override}"
      end
    end

    private

    def srcset
      @client ||= mock_signed_client.to_srcset(w: 100)
    end
  end

  class SrcsetGivenHeight < Imgix::Test
    include SrcsetTest

    def test_srcset_generates_width_pairs
      expected_number_of_pairs = 5
      assert_equal expected_number_of_pairs, srcset.split(",").length
    end

    def test_srcset_pair_values
      resolutions = DPR_MULTIPLIER
      srclist = srcset.split(",").map do |srcset_split|
        srcset_split.split(" ")[1].to_i
      end

      (0..srclist.length - 1).each do |i|
        assert_equal(resolutions[i], srclist[i])
      end
    end

    def test_srcset_respects_height_parameter
      srcset.split(",").map do |src|
        assert_includes src, "h="
      end
    end

    def test_srcset_within_bounds
      min, *max = srcset.split(",")

      # parse out the width descriptor as an integer
      min = min.split(" ")[1].to_i
      max = max[max.length - 1].split(" ")[1].to_i

      assert_operator min, :>=, 100
      assert_operator max, :<=, 8192
    end

    # a 17% testing threshold is used to account for rounding
    def test_srcset_iterates_17_percent
      increment_allowed = 0.17

      # create an array of widths
      widths = srcset.split(",").map do |src|
        src.split(" ")[1].to_i
      end

      prev = widths[0]

      (1..widths.length - 1).each do |i|
        element = widths[i]
        assert_operator (element.to_f / prev.to_f), :<, (1 + increment_allowed)
        prev = element
      end
    end

    def test_srcset_signs_urls
      srcset.split(",").map do |srcset_split|
        src = srcset_split.split(" ")[0]
        expected_signature = get_expected_signature(src)

        assert_includes src, expected_signature
      end
    end

    private

    def srcset
      @client ||= mock_signed_client.to_srcset(h: 100)
    end
  end

  class SrcsetGivenWidthAndHeight < Imgix::Test
    include SrcsetTest

    def test_srcset_in_dpr_form
      device_pixel_ratio = 1
      srcset.split(",").map do |src|
        ratio = src.split(" ")[1]
        assert_equal "#{device_pixel_ratio}x", ratio
        device_pixel_ratio += 1
      end
    end

    def test_srcset_has_dpr_params
      i = 1
      srcset.split(",").map do |srcset_split|
        src = srcset_split.split(" ")[0]
        assert_includes src, "dpr=#{i}"
        i += 1
      end
    end

    def test_srcset_signs_urls
      srcset.split(",").map do |srcset_split|
        src = srcset_split.split(" ")[0]
        expected_signature = get_expected_signature(src)

        assert_includes src, expected_signature
      end
    end

    def test_srcset_has_variable_qualities
      i = 0
      srcset.split(",").map do |src|
        assert_includes src, "q=#{DPR_QUALITY[i]}"
        i += 1
      end
    end

    def test_srcset_respects_overriding_quality
      quality_override = 100
      srcset = mock_signed_client.to_srcset(w: 100, h: 100, q: quality_override)

      srcset.split(",").map do |src|
        assert_includes src, "q=#{quality_override}"
      end
    end

    def test_disable_variable_quality
      srcset = mock_signed_client.to_srcset(
        w: 100, h: 100,
        options: { disable_variable_quality: true }
      )

      srcset.split(",").map do |src|
        assert(!src.include?("q="))
      end
    end

    def test_respects_quality_param_when_disabled
      quality_override = 100
      srcset = mock_signed_client.to_srcset(
        w: 100, h: 100, q: 100,
        options: { disable_variable_quality: true }
      )

      srcset.split(",").map do |src|
        assert_includes src, "q=#{quality_override}"
      end
    end

    private

    def srcset
      @client ||= mock_signed_client.to_srcset(w: 100, h: 100)
    end
  end

  class SrcsetGivenAspectRatio < Imgix::Test
    include SrcsetTest

    def test_srcset_generates_width_pairs
      expected_number_of_pairs = 31
      assert_equal expected_number_of_pairs, srcset.split(",").length
    end

    def test_srcset_pair_values
      srclist = srcset.split(",").map do |srcset_split|
        srcset_split.split(" ")[1].to_i
      end

      (0..srclist.length - 1).each do |i|
        assert_equal(srclist[i], RESOLUTIONS[i])
      end
    end

    def test_srcset_within_bounds
      min, *max = srcset.split(",")

      # parse out the width descriptor as an integer
      min = min.split(" ")[1].to_i
      max = max[max.length - 1].split(" ")[1].to_i

      assert_operator min, :>=, 100
      assert_operator max, :<=, 8192
    end

    # a 17% testing threshold is used to account for rounding
    def test_srcset_iterates_17_percent
      increment_allowed = 0.17

      # create an array of widths
      widths = srcset.split(",").map do |src|
        src.split(" ")[1].to_i
      end

      prev = widths[0]

      (1..widths.length - 1).each do |i|
        element = widths[i]
        assert_operator (element.to_f / prev.to_f), :<, (1 + increment_allowed)
        prev = element
      end
    end

    def test_srcset_signs_urls
      srcset.split(",").map do |srcset_split|
        src = srcset_split.split(" ")[0]
        expected_signature = get_expected_signature(src)

        assert_includes src, expected_signature
      end
    end

    private

    def srcset
      @client ||= mock_signed_client.to_srcset(ar: "3:2")
    end
  end

  class SrcsetGivenAspectRatioAndHeight < Imgix::Test
    include SrcsetTest

    def test_srcset_in_dpr_form
      device_pixel_ratio = 1

      srcset.split(",").map do |src|
        ratio = src.split(" ")[1]
        assert_equal "#{device_pixel_ratio}x", ratio
        device_pixel_ratio += 1
      end
    end

    def test_srcset_has_dpr_params
      i = 1
      srcset.split(",").map do |srcset_split|
        src = srcset_split.split(" ")[0]
        assert_includes src, "dpr=#{i}"
        i += 1
      end
    end

    def test_srcset_signs_urls
      srcset.split(",").map do |srcset_split|
        src = srcset_split.split(" ")[0]
        expected_signature = get_expected_signature(src)

        assert_includes src, expected_signature
      end
    end

    def test_srcset_has_variable_qualities
      i = 0
      srcset.split(",").map do |src|
        assert_includes src, "q=#{DPR_QUALITY[i]}"
        i += 1
      end
    end

    def test_srcset_respects_overriding_quality
      quality_override = 100
      srcset = mock_signed_client.to_srcset(
        w: 100, ar: "3:2", q: quality_override
      )

      srcset.split(",").map do |src|
        assert_includes src, "q=#{quality_override}"
      end
    end

    def test_disable_variable_quality
      srcset = mock_signed_client.to_srcset(
        w: 100, ar: "3:2",
        options: { disable_variable_quality: true }
      )

      srcset.split(",").map do |src|
        assert(!src.include?("q="))
      end
    end

    def test_respects_quality_param_when_disabled
      quality_override = 100
      srcset = mock_signed_client.to_srcset(
        w: 100, h: 100, q: 100,
        options: { disable_variable_quality: true }
      )

      srcset.split(",").map do |src|
        assert_includes src, "q=#{quality_override}"
      end
    end

    private

    def srcset
      @client ||= mock_signed_client.to_srcset(h: 100, ar: "3:2")
    end
  end

  class SrcsetWidthTolerance < Imgix::Test
    include SrcsetTest

    def test_srcset_generates_width_pairs
      expected_number_of_pairs = 15
      assert_equal expected_number_of_pairs, srcset.split(",").length
    end

    def test_srcset_pair_values
      resolutions = [100, 140, 196, 274, 384,
                     538, 753, 1054, 1476, 2066,
                     2893, 4050, 5669, 7937, 8192]

      srclist = srcset.split(",").map do |srcset_split|
        srcset_split.split(" ")[1].to_i
      end

      (0..srclist.length - 1).each do |i|
        assert_equal(srclist[i], resolutions[i])
      end
    end

    def test_srcset_within_bounds
      min, *max = srcset.split(",")

      # parse out the width descriptor as an integer
      min = min.split(" ")[1].to_i
      max = max[max.length - 1].split(" ")[1].to_i
      assert_operator min, :>=, 100
      assert_operator max, :<=, 8192
    end

    # a 41% testing threshold is used to account for rounding
    def test_srcset_iterates_41_percent
      increment_allowed = 0.41

      # create an array of widths
      widths = srcset.split(",").map do |src|
        src.split(" ")[1].to_i
      end

      prev = widths[0]

      (1..widths.length - 1).each do |i|
        element = widths[i]
        assert_operator (element.to_f / prev.to_f), :<, (1 + increment_allowed)
        prev = element
      end
    end

    def test_invalid_tolerance_emits_error
      assert_raises(ArgumentError) do
        mock_client.to_srcset(options: { width_tolerance: "abc" })
      end
    end

    def test_negative_tolerance_emits_error
      assert_raises(ArgumentError) do
        mock_client.to_srcset(options: { width_tolerance: -0.10 })
      end
    end

    def test_with_param_after
      srcset = mock_signed_client.to_srcset(
        options: { width_tolerance: 0.20 },
        h: 1000, fit: "clip"
      )

      assert_includes(srcset, "h=")
      assert(!srcset.include?("width_tolerance="))
    end

    def test_with_param_before
      srcset = mock_signed_client.to_srcset(
        h: 1000, fit: "clip",
        options: { width_tolerance: 0.20 }
      )

      assert_includes(srcset, "h=")
      assert(!srcset.include?("width_tolerance="))
    end

    private

    def srcset
      @client ||= mock_signed_client.to_srcset(
        options: { width_tolerance: 0.20 }
      )
    end
  end

  class SrcsetCustomWidths < Imgix::Test
    include SrcsetTest

    def test_srcset_generates_width_pairs
      expected_number_of_pairs = 4
      assert_equal expected_number_of_pairs, srcset.split(",").length
    end

    def test_srcset_pair_values
      resolutions = [100, 500, 1000, 1800]
      srclist = srcset.split(",").map do |srcset_split|
        srcset_split.split(" ")[1].to_i
      end

      (0..srclist.length - 1).each do |i|
        assert_equal(srclist[i], resolutions[i])
      end
    end

    def test_srcset_within_bounds
      min, *max = srcset.split(",")

      # parse out the width descriptor as an integer
      min = min.split(" ")[1].to_i
      max = max[max.length - 1].split(" ")[1].to_i

      assert_operator min, :>=, @widths[0]
      assert_operator max, :<=, @widths[-1]
    end

    def test_invalid_widths_input_emits_error
      assert_raises(ArgumentError) do
        mock_client.to_srcset(options: { widths: "abc" })
      end
    end

    def test_non_integer_array_emits_error
      assert_raises(ArgumentError) do
        mock_client.to_srcset(options: { widths: [100, 200, false] })
      end
    end

    def test_negative_integer_array_emits_error
      assert_raises(ArgumentError) do
        mock_client.to_srcset(options: { widths: [100, 200, -100] })
      end
    end

    def test_with_param_after
      srcset = mock_signed_client.to_srcset(
        options: { widths: [100, 200, 300] },
        h: 1000, fit: "clip"
      )

      assert_includes(srcset, "h=")
      assert(!srcset.include?("widths="))
    end

    def test_with_param_before
      srcset = mock_client.to_srcset(
        h: 1000, fit: "clip",
        options: { widths: [100, 200, 300] }
      )
      assert_includes(srcset, "h=")
      assert(!srcset.include?("widths="))
    end

    private

    def srcset
      @widths = [100, 500, 1000, 1800]
      @client ||= mock_signed_client.to_srcset(options: { widths: @widths })
    end
  end

  class SrcsetMinMaxWidths < Imgix::Test
    include SrcsetTest

    def test_srcset_generates_width_pairs
      expected_number_of_pairs = 11
      assert_equal expected_number_of_pairs, srcset.split(",").length
    end

    def test_srcset_pair_values
      resolutions = [500, 580, 673, 780, 905, 1050,
                     1218, 1413, 1639, 1901, 2000]
      srclist = srcset.split(",").map do |srcset_split|
        srcset_split.split(" ")[1].to_i
      end

      (0..srclist.length - 1).each do |i|
        assert_equal(srclist[i], resolutions[i])
      end
    end

    def test_srcset_within_bounds
      min, *max = srcset.split(",")

      # parse out the width descriptor as an integer
      min = min.split(" ")[1].to_i
      max = max[max.length - 1].split(" ")[1].to_i

      assert_operator min, :>=, @MIN
      assert_operator max, :<=, @MAX
    end

    # a 41% testing threshold is used to account for rounding
    def test_with_custom_width_tolerance
      srcset = mock_client.to_srcset(
        options: { min_width: 500, max_width: 2000, width_tolerance: 0.20 }
      )

      increment_allowed = 0.41

      # create an array of widths
      widths = srcset.split(",").map do |src|
        src.split(" ")[1].to_i
      end

      prev = widths[0]

      (1..widths.length - 1).each do |i|
        element = widths[i]
        assert_operator (element.to_f / prev.to_f), :<, (1 + increment_allowed)
        prev = element
      end
    end

    def test_invalid_min_emits_error
      assert_raises(ArgumentError) do
        mock_client.to_srcset(options: { min_width: "abc" })
      end
    end

    def test_negative_max_emits_error
      assert_raises(ArgumentError) do
        mock_client.to_srcset(options: { max_width: -100 })
      end
    end

    def test_with_param_after
      srcset = mock_client.to_srcset(
        options: { min_width: 500, max_width: 2000 },
        h: 1000, fit: "clip"
      )

      assert_includes(srcset, "h=")
      assert(!srcset.include?("min_width="))
      assert(!srcset.include?("max_width="))
    end

    def test_with_param_before
      srcset = mock_client.to_srcset(
        h: 1000, fit: "clip",
        options: { min_width: 500, max_width: 2000 }
      )

      assert_includes(srcset, "h=")
      assert(!srcset.include?("min_width="))
      assert(!srcset.include?("max_width="))
    end

    def test_only_min
      min_width = 1000
      max_width = 8192
      srcset = mock_client.to_srcset(options: { min_width: min_width })

      min, *max = srcset.split(",")

      # parse out the width descriptor as an integer
      min = min.split(" ")[1].to_i
      max = max[max.length - 1].split(" ")[1].to_i

      assert_operator min, :>=, min_width
      assert_operator max, :<=, max_width
    end

    def test_only_max
      min_width = 100
      max_width = 1000
      srcset = mock_client.to_srcset(options: { max_width: max_width })
      min, *max = srcset.split(",")

      # parse out the width descriptor as an integer
      min = min.split(" ")[1].to_i
      max = max[max.length - 1].split(" ")[1].to_i

      assert_operator min, :>=, min_width
      assert_operator max, :<=, max_width
    end

    def test_max_as_100
      srcset = mock_client.to_srcset(options: { max_width: 100 })
      assert_equal(srcset, "https://testing.imgix.net/image.jpg?w=100 100w")
    end

    def test_min_as_8192
      srcset = mock_client.to_srcset(options: { min_width: 8192 })
      assert_equal(srcset, "https://testing.imgix.net/image.jpg?w=8192 8192w")
    end

    private

    def srcset
      @MIN = 500
      @MAX = 2000
      @client ||= mock_client.to_srcset(
        options: { min_width: @MIN, max_width: @MAX }
      )
    end
  end
end
