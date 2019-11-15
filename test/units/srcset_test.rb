require 'test_helper'

module SrcsetTest

    class SrcsetDefault < Imgix::Test
        def test_no_parameters
            srcset = path.to_srcset()
            expected_number_of_pairs = 31
            assert_equal expected_number_of_pairs, srcset.split(',').length
        end

        def test_srcset_pair_values
            resolutions = [100, 116, 134, 156, 182, 210, 244, 282,
                328, 380, 442, 512, 594, 688, 798, 926,
                1074, 1246, 1446, 1678, 1946, 2258, 2618,
                3038, 3524, 4088, 4742, 5500, 6380, 7400, 8192]
            srcset = path.to_srcset()
            srclist = srcset.split(',').map { |srcset_split|
                srcset_split.split(' ')[1].to_i
            }

            for i in 0..srclist.length - 1 do
                assert_equal(srclist[i], resolutions[i])
            end
        end

        private
            def path
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg')
            end
    end

    class SrcsetGivenWidth < Imgix::Test
        def test_srcset_in_dpr_form
            device_pixel_ratio = 1

            srcset.split(',').map { |src|
                ratio = src.split(' ')[1]
                assert_equal ("#{device_pixel_ratio}x"), ratio
                device_pixel_ratio += 1
            }
        end

        def test_srcset_has_dpr_params
            i = 1
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, "dpr=#{i}"
                i += 1
            }
        end

        def test_srcset_signs_urls
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, 's='

                # parses out all parameters except for 's=...'
                params = src[src.index('?')..src.index('s=') - 2]

                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=') + 2, src.length)

                signature_base = 'MYT0KEN' + '/image.jpg' + params;
                expected_signature = Digest::MD5.hexdigest(signature_base)
                
                assert_equal expected_signature, generated_signature
            }
        end

        def test_srcset_has_variable_qualities
            i = 0
            srcset.split(',').map { |src|
                assert_includes src, "q=#{DPR_QUALITY[i]}"
                i += 1
            }
        end

        def test_srcset_respects_overriding_quality
            quality_override = 100
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, q:quality_override)

            srcset.split(',').map { |src|
                assert_includes src, "q=#{quality_override}"
            }
        end

        def test_disable_variable_quality
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, options: { disable_variable_quality: true })

            srcset.split(',').map { |src|
                assert(not(src.include? "q="))
            }
        end

        def test_respects_quality_param_when_disabled
            quality_override = 100
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, q:100, options: { disable_variable_quality: true })

            srcset.split(',').map { |src|
                assert_includes src, "q=#{quality_override}"
            }
        end

        private
            DPR_QUALITY = [75, 50, 35, 23, 20]

            def srcset
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100)
            end
    end

    class SrcsetGivenHeight < Imgix::Test
        def test_srcset_generates_width_pairs
            expected_number_of_pairs = 31
            assert_equal expected_number_of_pairs, srcset.split(',').length
        end

        def test_srcset_pair_values
            resolutions = [100, 116, 134, 156, 182, 210, 244, 282,
                328, 380, 442, 512, 594, 688, 798, 926,
                1074, 1246, 1446, 1678, 1946, 2258, 2618,
                3038, 3524, 4088, 4742, 5500, 6380, 7400, 8192]
            srclist = srcset.split(',').map { |srcset_split|
                srcset_split.split(' ')[1].to_i
            }

            for i in 0..srclist.length - 1 do
                assert_equal(srclist[i], resolutions[i])
            end
        end

        def test_srcset_respects_height_parameter
            srcset.split(',').map { |src|
                assert_includes src, 'h='
            }
        end

        def test_srcset_within_bounds
            min, *max = srcset.split(',')

            # parse out the width descriptor as an integer
            min = min.split(' ')[1].to_i
            max = max[max.length - 1].split(' ')[1].to_i

            assert_operator min, :>=, 100
            assert_operator max, :<=, 8192
        end

        # a 17% testing threshold is used to account for rounding
        def test_srcset_iterates_17_percent
            increment_allowed = 0.17

            # create an array of widths
            widths = srcset.split(',').map { |src|
                src.split(' ')[1].to_i
            }

            prev = widths[0]

            for i in 1..widths.length - 1 do
                element = widths[i]
                assert_operator (element.to_f / prev.to_f), :<, (1 + increment_allowed)
                prev = element
            end
        end

        def test_srcset_signs_urls
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, 's='

                # parses out all parameters except for 's=...'
                params = src[src.index('?')..src.index('s=') - 2]

                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=') + 2, src.length)

                signature_base = 'MYT0KEN' + '/image.jpg' + params;
                expected_signature = Digest::MD5.hexdigest(signature_base)
                
                assert_equal expected_signature, generated_signature
            }
        end

        private
            def srcset
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(h:100)
            end
    end

    class SrcsetGivenWidthAndHeight < Imgix::Test
        def test_srcset_in_dpr_form
            device_pixel_ratio = 1
            srcset.split(',').map { |src|
                ratio = src.split(' ')[1]
                assert_equal ("#{device_pixel_ratio}x"), ratio
                device_pixel_ratio += 1
            }
        end

        def test_srcset_has_dpr_params
            i = 1
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, "dpr=#{i}"
                i += 1
            }
        end

        def test_srcset_signs_urls
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, 's='

                # parses out all parameters except for 's=...'
                params = src[src.index('?')..src.index('s=') - 2]

                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=') + 2, src.length)

                signature_base = 'MYT0KEN' + '/image.jpg' + params;
                expected_signature = Digest::MD5.hexdigest(signature_base)

                assert_equal expected_signature, generated_signature
            }
        end

        def test_srcset_has_variable_qualities
            i = 0
            srcset.split(',').map { |src|
                assert_includes src, "q=#{DPR_QUALITY[i]}"
                i += 1
            }
        end

        def test_srcset_respects_overriding_quality
            quality_override = 100
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, h:100, q:quality_override)

            srcset.split(',').map { |src|
                assert_includes src, "q=#{quality_override}"
            }
        end

        def test_disable_variable_quality
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, h:100, options: { disable_variable_quality: true })

            srcset.split(',').map { |src|
                assert(not(src.include? "q="))
            }
        end

        def test_respects_quality_param_when_disabled
            quality_override = 100
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, h:100, q:100, options: { disable_variable_quality: true })

            srcset.split(',').map { |src|
                assert_includes src, "q=#{quality_override}"
            }
        end

        private
            DPR_QUALITY = [75, 50, 35, 23, 20]

            def srcset
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100,h:100)
            end
    end

    class SrcsetGivenAspectRatio < Imgix::Test
        def test_srcset_generates_width_pairs
            expected_number_of_pairs = 31
            assert_equal expected_number_of_pairs, srcset.split(',').length
        end

        def test_srcset_pair_values
            resolutions = [100, 116, 134, 156, 182, 210, 244, 282,
                328, 380, 442, 512, 594, 688, 798, 926,
                1074, 1246, 1446, 1678, 1946, 2258, 2618,
                3038, 3524, 4088, 4742, 5500, 6380, 7400, 8192]
            srclist = srcset.split(',').map { |srcset_split|
                srcset_split.split(' ')[1].to_i
            }

            for i in 0..srclist.length - 1 do
                assert_equal(srclist[i], resolutions[i])
            end
        end

        def test_srcset_within_bounds
            min, *max = srcset.split(',')

            # parse out the width descriptor as an integer
            min = min.split(' ')[1].to_i
            max = max[max.length - 1].split(' ')[1].to_i

            assert_operator min, :>=, 100
            assert_operator max, :<=, 8192
        end

        # a 17% testing threshold is used to account for rounding
        def test_srcset_iterates_17_percent
            increment_allowed = 0.17

            # create an array of widths
            widths = srcset.split(',').map { |src|
                src.split(' ')[1].to_i
            }

            prev = widths[0]

            for i in 1..widths.length - 1 do
                element = widths[i]
                assert_operator (element.to_f / prev.to_f), :<, (1 + increment_allowed)
                prev = element
            end
        end

        def test_srcset_signs_urls
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, 's='

                # parses out all parameters except for 's=...'
                params = src[src.index('?')..src.index('s=') - 2]

                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=') + 2, src.length)

                signature_base = 'MYT0KEN' + '/image.jpg' + params;
                expected_signature = Digest::MD5.hexdigest(signature_base)
                
                assert_equal expected_signature, generated_signature
            }
        end

        private
            def srcset
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(ar:'3:2')
            end
    end

    class SrcsetGivenAspectRatioAndHeight < Imgix::Test
        def test_srcset_in_dpr_form
            device_pixel_ratio = 1

            srcset.split(',').map { |src|
                ratio = src.split(' ')[1]
                assert_equal ("#{device_pixel_ratio}x"), ratio
                device_pixel_ratio += 1
            }
        end

        def test_srcset_has_dpr_params
            i = 1
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, "dpr=#{i}"
                i += 1
            }
        end

        def test_srcset_signs_urls
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, 's='

                # parses out all parameters except for 's=...'
                params = src[src.index('?')..src.index('s=') - 2]

                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=') + 2, src.length)

                signature_base = 'MYT0KEN' + '/image.jpg' + params;
                expected_signature = Digest::MD5.hexdigest(signature_base)

                assert_equal expected_signature, generated_signature
            }
        end

        def test_srcset_has_variable_qualities
            i = 0
            srcset.split(',').map { |src|
                assert_includes src, "q=#{DPR_QUALITY[i]}"
                i += 1
            }
        end

        def test_srcset_respects_overriding_quality
            quality_override = 100
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, ar:'3:2', q:quality_override)

            srcset.split(',').map { |src|
                assert_includes src, "q=#{quality_override}"
            }
        end

        def test_disable_variable_quality
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, ar:'3:2', options: { disable_variable_quality: true })

            srcset.split(',').map { |src|
                assert(not(src.include? "q="))
            }
        end

        def test_respects_quality_param_when_disabled
            quality_override = 100
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(w:100, h:100, q:100, options: { disable_variable_quality: true })

            srcset.split(',').map { |src|
                assert_includes src, "q=#{quality_override}"
            }
        end

        private
            DPR_QUALITY = [75, 50, 35, 23, 20]

            def srcset
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset({h:100,ar:'3:2'})
            end
    end

    class SrcsetWidthTolerance < Imgix::Test
        def test_srcset_generates_width_pairs
            expected_number_of_pairs = 15
            assert_equal expected_number_of_pairs, srcset.split(',').length
        end

        def test_srcset_pair_values
            resolutions = [100,140,196,274,384,538,752,1054,1476,2066,2892,4050,5670,7938,8192]
            srclist = srcset.split(',').map { |srcset_split|
                srcset_split.split(' ')[1].to_i
            }

            for i in 0..srclist.length - 1 do
                assert_equal(srclist[i], resolutions[i])
            end
        end

        def test_srcset_within_bounds
            min, *max = srcset.split(',')

            # parse out the width descriptor as an integer
            min = min.split(' ')[1].to_i
            max = max[max.length - 1].split(' ')[1].to_i
            assert_operator min, :>=, 100
            assert_operator max, :<=, 8192
        end

        # a 41% testing threshold is used to account for rounding
        def test_srcset_iterates_41_percent
            increment_allowed = 0.41

            # create an array of widths
            widths = srcset.split(',').map { |src|
                src.split(' ')[1].to_i
            }

            prev = widths[0]

            for i in 1..widths.length - 1 do
                element = widths[i]
                assert_operator (element.to_f / prev.to_f), :<, (1 + increment_allowed)
                prev = element
            end
        end

        def test_invalid_tolerance_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(options: {width_tolerance: 'abc'})
            }
        end

        def test_negative_tolerance_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(options: {width_tolerance: -0.10})
            }
        end

        def test_with_param_after
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
            .path('image.jpg')
            .to_srcset(options: {width_tolerance: 0.20}, h:1000, fit:"clip")
            assert_includes(srcset, "h=")
            assert(not(srcset.include? "width_tolerance="))
        end

        def test_with_param_before
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
            .path('image.jpg')
            .to_srcset(h:1000, fit:"clip", options: {width_tolerance: 0.20})
            assert_includes(srcset, "h=")
            assert(not(srcset.include? "width_tolerance="))
        end

        private
            def srcset
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(options: {width_tolerance: 0.20})
            end
    end

    class SrcsetCustomWidths < Imgix::Test
        def test_srcset_generates_width_pairs
            expected_number_of_pairs = 4
            assert_equal expected_number_of_pairs, srcset.split(',').length
        end

        def test_srcset_pair_values
            resolutions = [100, 500, 1000, 1800]
            srclist = srcset.split(',').map { |srcset_split|
                srcset_split.split(' ')[1].to_i
            }

            for i in 0..srclist.length - 1 do
                assert_equal(srclist[i], resolutions[i])
            end
        end

        def test_srcset_within_bounds
            min, *max = srcset.split(',')

            # parse out the width descriptor as an integer
            min = min.split(' ')[1].to_i
            max = max[max.length - 1].split(' ')[1].to_i

            assert_operator min, :>=, @widths[0]
            assert_operator max, :<=, @widths[-1]
        end

        def test_invalid_widths_input_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(options: {widths: 'abc'})
            }
        end

        def test_non_integer_array_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(options: {widths: [100, 200, false]})
            }
        end

        def test_negative_integer_array_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(options: {widths: [100, 200, -100]})
            }
        end

        def test_with_param_after
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
            .path('image.jpg')
            .to_srcset(options: {widths: [100, 200, 300]}, h:1000, fit:"clip")
            assert_includes(srcset, "h=")
            assert(not(srcset.include? "widths="))
        end

        def test_with_param_before
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
            .path('image.jpg')
            .to_srcset(h:1000, fit:"clip", options: {widths: [100, 200, 300]})
            assert_includes(srcset, "h=")
            assert(not(srcset.include? "widths="))
        end

        private
            def srcset
                @widths = [100, 500, 1000, 1800]
                @client ||= Imgix::Client.new(
                    host: 'testing.imgix.net',
                    include_library_param: false)
                    .path('image.jpg')
                    .to_srcset(options: {widths: @widths})
            end
    end

    class SrcsetMinMaxWidths < Imgix::Test
        def test_srcset_generates_width_pairs
            expected_number_of_pairs = 11
            assert_equal expected_number_of_pairs, srcset.split(',').length
        end

        def test_srcset_pair_values
            resolutions = [500,580,672,780,906,1050,1218,1414,1640,1902,2000]
            srclist = srcset.split(',').map { |srcset_split|
                srcset_split.split(' ')[1].to_i
            }

            for i in 0..srclist.length - 1 do
                assert_equal(srclist[i], resolutions[i])
            end
        end

        def test_srcset_within_bounds
            min, *max = srcset.split(',')

            # parse out the width descriptor as an integer
            min = min.split(' ')[1].to_i
            max = max[max.length - 1].split(' ')[1].to_i

            assert_operator min, :>=, @MIN
            assert_operator max, :<=, @MAX
        end

        # a 41% testing threshold is used to account for rounding
        def test_with_custom_width_tolerance
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(options: {min_width: 500, max_width: 2000, width_tolerance: 0.20})

            increment_allowed = 0.41

            # create an array of widths
            widths = srcset.split(',').map { |src|
                src.split(' ')[1].to_i
            }

            prev = widths[0]

            for i in 1..widths.length - 1 do
                element = widths[i]
                assert_operator (element.to_f / prev.to_f), :<, (1 + increment_allowed)
                prev = element
            end
        end

        def test_invalid_min_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(options: {min_width: 'abc'})
            }
        end

        def test_negative_max_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(options: {max_width: -100})
            }
        end

        def test_with_param_after
            srcset = Imgix::Client.new(host: 'testing.imgix.net', include_library_param: false)
            .path('image.jpg')
            .to_srcset(options: {min_width: 500, max_width:2000}, h:1000, fit:"clip")

            assert_includes(srcset, "h=")
            assert(not(srcset.include? "min_width="))
            assert(not(srcset.include? "max_width="))
        end

        def test_with_param_before
            srcset = Imgix::Client.new(host: 'testing.imgix.net', include_library_param: false)
            .path('image.jpg')
            .to_srcset(h:1000, fit:"clip", options: {min_width: 500, max_width:2000})

            assert_includes(srcset, "h=")
            assert(not(srcset.include? "min_width="))
            assert(not(srcset.include? "max_width="))
        end

        def test_only_min
            min_width = 1000
            max_width = 8192
            srcset = Imgix::Client.new(host: 'testing.imgix.net', include_library_param: false).path('image.jpg').to_srcset(options: {min_width: min_width})

            min, *max = srcset.split(',')

            # parse out the width descriptor as an integer
            min = min.split(' ')[1].to_i
            max = max[max.length - 1].split(' ')[1].to_i

            assert_operator min, :>=, min_width
            assert_operator max, :<=, max_width
        end

        def test_only_max
            min_width = 100
            max_width = 1000
            srcset = Imgix::Client.new(host: 'testing.imgix.net', include_library_param: false).path('image.jpg').to_srcset(options: {max_width: max_width})
            min, *max = srcset.split(',')

            # parse out the width descriptor as an integer
            min = min.split(' ')[1].to_i
            max = max[max.length - 1].split(' ')[1].to_i

            assert_operator min, :>=, min_width
            assert_operator max, :<=, max_width

        end

        private
            def srcset
                @MIN = 500
                @MAX = 2000
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', include_library_param: false).path('image.jpg').to_srcset(options: {min_width: @MIN, max_width: @MAX})
            end
    end
end
