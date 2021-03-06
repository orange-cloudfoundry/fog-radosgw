module Fog
  module Radosgw
    class Usage
      module Utils

        def sanitize_and_convert_time(time)
          fmt = '%Y-%m-%d %H:%M:%S'
          escape(time.strftime(fmt))
        end

      end

      class Real
        include Utils

        def get_usage(access_key_id, options = {})
          path = "admin/usage"
          t_now = Fog::Time.now
          start_time  = sanitize_and_convert_time(options[:start_time] || t_now - 86400)
          end_time    = sanitize_and_convert_time(options[:end_time]   || t_now)

          query = "?format=json&start=#{start_time}&end=#{end_time}"
          params = { 
            :method => 'GET',
            :path => path,
          }

          begin
            response = Excon.get("#{@scheme}://#{@host}/#{path}#{query}",
                                 :headers => signed_headers(params))
            if !response.body.empty?
              response.body = Fog::JSON.decode(response.body)
            end
            response
          rescue Excon::Errors::BadRequest => e
            raise Fog::Radosgw::Provisioning::ServiceUnavailable.new
          end
        end
      end

      class Mock
        include Utils

        def get_usage(access_key, options = {})
          Excon::Response.new.tap do |response|
            response.status = 200
            response.headers['Content-Type'] = 'application/json'
            response.body = {
              'entries' =>  [],
              'summary'  => []
            }
          end
        end
      end
    end
  end
end
