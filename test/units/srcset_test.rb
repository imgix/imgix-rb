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

        private
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

        private
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

        private
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
                .to_srcset(width_tolerance: 'abc')
            }
        end

        def test_negative_tolerance_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(width_tolerance: -0.10)
            }
        end

        def test_with_param_after
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
            .path('image.jpg')
            .to_srcset(width_tolerance: 0.20, h:1000, fit:"clip")
            assert_includes(srcset, "h=")
            assert(not(srcset.include? "width_tolerance="))
        end
        
        def test_with_param_before
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
            .path('image.jpg')
            .to_srcset(h:1000, fit:"clip", width_tolerance: 0.20)
            assert_includes(srcset, "h=")
            assert(not(srcset.include? "width_tolerance="))
        end

        private
            def srcset
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(width_tolerance: 0.20)
            end
    end
    class SrcsetCustomSizes < Imgix::Test
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

            assert_operator min, :>=, @sizes[0]
            assert_operator max, :<=, @sizes[-1]
        end

        def test_invalid_sizes_input_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(sizes: 'abc')
            }
        end

        def test_non_integer_array_emits_error
            assert_raises(ArgumentError) {
                Imgix::Client.new(host: 'testing.imgix.net')
                .path('image.jpg')
                .to_srcset(sizes: [100, 200, false])
            }
        end

        def test_with_param_after
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
            .path('image.jpg')
            .to_srcset(sizes: [100, 200, 300], h:1000, fit:"clip")
            assert_includes(srcset, "h=")
            assert(not(srcset.include? "sizes="))
        end

        def test_with_param_before
            srcset = Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false)
            .path('image.jpg')
            .to_srcset(h:1000, fit:"clip", sizes: [100, 200, 300])
            assert_includes(srcset, "h=")
            assert(not(srcset.include? "sizes="))
        end

        private
            def srcset
                @sizes = [100, 500, 1000, 1800]
                @client ||= Imgix::Client.new(host: 'testing.imgix.net', secure_url_token: 'MYT0KEN', include_library_param: false).path('image.jpg').to_srcset(sizes: @sizes)
            end
    end
end
