require 'rest-client'
require 'json'
require 'folio_lsp/configuration'

module EBSCO
  module FOLIO
    
    class Auth
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

          #okapi-snd-us-east-1.folio.ebsco.com
          
          # puts options
          # puts "USER: " + @user
          # puts "PASS: " + @pass

          if options.has_key? :okapi_token
            @okapi_token = options[:okapi_token]
          else
            @okapi_token = create_okapi_token
          end 

          # if @debug
          #   puts '*** OKAPI TOKEN: ' + @okapi_token.inspect
          # end

        end

        def create_okapi_token
          #if blank?(@okapi_token)

            puts 'OKAPI TENANT: ' + @okapi_tenant
            puts 'OKAPI USER: ' + @user
            puts 'OKAPI PASS: ' + @pass
            puts 'OKAPI URL: ' + 'https://' + @okapi_host + @config[:auth_path]

            response = RestClient.post 'https://' + @okapi_host + @config[:auth_path], '{"username": "' + @user + '","password": "' + @pass + '"}', {:'x-okapi-tenant' => @okapi_tenant, :accept => :json, :content_type => :json}
 
            puts response.code
            puts response.headers
            puts response.body
          #end
          @okapi_token = response.headers[:x_okapi_token]
          @okapi_token
        end

    end

  end
end