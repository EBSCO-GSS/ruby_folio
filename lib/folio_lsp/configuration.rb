require 'yaml'

module EBSCO

  module FOLIO

    class Configuration

      attr_reader :valid_config_keys

      def initialize
        # Configuration defaults
        @config  = {
            :debug => true,
            :auth_token => '',
            :okapi_host => '',
            :okapi_tenant => '',
            :auth_path => '/authn/login',
            :rtac_path => '/rtac/',
            :title_hold_path => '/patron/account/{userId}/instance/{instanceId}/hold',
            :cancel_hold_path => '/patron/account/{userId}/item/{itemId}/hold/{holdId}',
            :service_points_path => '/service-points',
            :user_agent => 'EBSCO FOLIO GEM v0.0.1',
            :log => 'faraday.log',
            :log_level => 'INFO',
            :max_attempts => 3,
            :timeout => 60,
            :open_timeout => 12,
        }
        @valid_config_keys = @config.keys
      end

      def configure(opts = {})
        opts.each do |k, v|
          @config[k] = v if @valid_config_keys.include? k
        end
        @config
      end

      def configure_with(file)
        begin
          config = YAML.load_file(file ||= 'folio.yaml').symbolize_keys
        rescue Errno::ENOENT
          #puts 'YAML configuration file couldn\'t be found. Using defaults.'
          return
        rescue Psych::SyntaxError
          #puts 'YAML configuration file contains invalid syntax. Using defaults'
          return
        end
        @config[:file] = file
        configure(config)
      end
    end

  end
end