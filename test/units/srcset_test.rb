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

            for i in 0..srclist.length-1 do
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
                params = src.slice(src.index('?'), src.length)
                params = params.slice(0, params.index('s=')-1)
                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=')+2, src.length)

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

            for i in 0..srclist.length-1 do
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
            max = max[max.length-1].split(' ')[1].to_i

            assert_operator min, :>=, 100
            assert_operator max, :<=, 8192
        end

        def test_srcset_iterates_18_percent
            increment_allowed = 0.18

            # create an array of widths
            widths = srcset.split(',').map { |src|
                src.split(' ')[1].to_i
            }

            prev = widths[0]

            for i in 1..widths.length-1 do
                element = widths[i]
                assert_operator (element / prev), :<, (1 + increment_allowed)
                prev = element
            end
        end

        def test_srcset_signs_urls
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, 's='

                # parses out all parameters except for 's=...'
                params = src.slice(src.index('?'), src.length)
                params = params.slice(0, params.index('s=')-1)
                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=')+2, src.length)

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
                params = src.slice(src.index('?'), src.length)
                params = params.slice(0, params.index('s=')-1)
                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=')+2, src.length)

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

            for i in 0..srclist.length-1 do
                assert_equal(srclist[i], resolutions[i])
            end
        end

        def test_srcset_within_bounds
            min, *max = srcset.split(',')

            # parse out the width descriptor as an integer
            min = min.split(' ')[1].to_i
            max = max[max.length-1].split(' ')[1].to_i

            assert_operator min, :>=, 100
            assert_operator max, :<=, 8192
        end

        def test_srcset_iterates_18_percent
            increment_allowed = 0.18

            # create an array of widths
            widths = srcset.split(',').map { |src|
                src.split(' ')[1].to_i
            }

            prev = widths[0]

            for i in 1..widths.length-1 do
                element = widths[i]
                assert_operator (element / prev), :<, (1 + increment_allowed)
                prev = element
            end
        end

        def test_srcset_signs_urls
            srcset.split(',').map { |srcset_split|
                src = srcset_split.split(' ')[0]
                assert_includes src, 's='

                # parses out all parameters except for 's=...'
                params = src.slice(src.index('?'), src.length)
                params = params.slice(0, params.index('s=')-1)
                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=')+2, src.length)

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
                params = src.slice(src.index('?'), src.length)
                params = params.slice(0, params.index('s=')-1)
                # parses out the 's=...' parameter
                generated_signature = src.slice(src.index('s=')+2, src.length)

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
end