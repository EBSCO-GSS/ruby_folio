require 'rest-client'
require 'json'
require 'time'
require 'folio_lsp/configuration'

module EBSCO
  module FOLIO
    
    class Session
        # The authentication token.  This is passed along in the x-okapi-token HTTP header for every call.
        attr_accessor :okapi_token
        attr_reader :config

        def initialize(options = {})

          folio_config = EBSCO::FOLIO::Configuration.new

          if options[:config]
            @config = folio_config.configure_with(options[:config])
            # return default if there is some problem with the yaml file (bad syntax, not found, etc.)
            @config = folio_config.configure if @config.nil?
          else
            @config = folio_config.configure(options)
          end

          # these properties aren't in the config
          if options.has_key? :user
            @user = options[:user]
          elsif ENV.has_key? 'FOLIO_USER'
            @user = ENV['FOLIO_USER']
          end

          if options.has_key? :pass
            @pass = options[:pass]
          elsif ENV.has_key? 'FOLIO_PASS'
            @pass = ENV['FOLIO_PASS']
          end

          if options.has_key? :okapi_tenant
            @okapi_tenant = options[:okapi_tenant]
          elsif ENV.has_key? 'OKAPI_TENANT'
            @okapi_tenant = ENV['OKAPI_TENANT']
          end

          if options.has_key? :okapi_host
            @okapi_host = options[:okapi_host]
          elsif ENV.has_key? 'OKAPI_HOST'
            @okapi_host = ENV['OKAPI_HOST']
          end

          if options.has_key? :okapi_token
            @okapi_token = options[:okapi_token]
          else
            @okapi_token = create_okapi_token
          end 

        end

        def create_okapi_token

          @okapi_token = ENV['OKAPI_TOKEN'] || ''
          if (@okapi_token.empty?)
            response = RestClient.post 'https://' + @okapi_host + @config[:auth_path], '{"username": "' + @user + '","password": "' + @pass + '"}', {:'x-okapi-tenant' => @okapi_tenant, :accept => :json, :content_type => :json}
            @okapi_token = response.headers[:x_okapi_token]
          end

          ENV['OKAPI_TOKEN'] = @okapi_token
          @okapi_token

        end

        def get_rtac(mmid = '')
          response = RestClient.get 'https://' + @okapi_host + @config[:rtac_path] + mmid, {:'x-okapi-token' => @okapi_token, :accept => :json, :content_type => :json}
          rtac_hash = JSON.parse(response)
          rtac_hash
        end

        def get_pickup_locations()
          response = RestClient.get 'https://' + @okapi_host + @config[:service_points_path] + '?query=' + URI.escape("(pickupLocation==true)"), {:'x-okapi-token' => @okapi_token, :accept => :json} 
          pul_hash = JSON.parse(response)
          pul_hash
        end

        def place_hold(hold_details = {})
          if (hold_details.has_key? :userId) && (hold_details.has_key? :instanceId) && (hold_details.has_key? :pickupLocationId)
            current_time = Time.now.iso8601
            if hold_details.key?("expirationDate")
              endDate = Time.parse(hold_details[:endDate]).iso8601
            else
              endDate = (Time.now + (2*7*24*60*60)).iso8601
            end
            request_body = Hash.new
            request_body[ "requestDate" ] = current_time
            request_body[ "expirationDate" ] = endDate
            request_body[ "pickupLocationId" ] = hold_details[:pickupLocationId]
            request_body[ "item" ] = {}
            request_body[ "item" ][ "instanceId" ] = hold_details[:instanceId]
            request_path = config[:title_hold_path]
            request_path.sub! '{userId}', hold_details[:userId]
            request_path.sub! '{instanceId}', hold_details[:instanceId]
            raw_response = RestClient.post 'https://' + @okapi_host + request_path, request_body.to_json,{:'x-okapi-token' => @okapi_token, :accept => :json, :content_type => :json}
            response = JSON.parse(raw_response)
          else
            response = hold_details
          end
          response
        end

        def cancel_hold(hold_details = {})
          if (hold_details.has_key? :userId) && (hold_details.has_key? :itemId) && (hold_details.has_key? :holdId)

            request_path = config[:cancel_hold_path]
            request_path.sub! '{userId}', hold_details[:userId]
            request_path.sub! '{itemId}', hold_details[:itemId]
            request_path.sub! '{holdId}', hold_details[:holdId]

            raw_response = RestClient.delete 'https://' + @okapi_host + request_path, {:'x-okapi-token' => @okapi_token, :accept => 'text/plain'}

            response = 'Success'
          else
            response = hold_details
          end
          response
        end

    end

  end
end