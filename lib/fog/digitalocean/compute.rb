require 'fog/digitalocean'
require 'fog/compute'

module Fog
  module Compute
    class DigitalOcean < Fog::Service

      requires     :digitalocean_api_key
      requires     :digitalocean_client_id

      recognizes   :digitalocean_api_url

      model_path   'fog/digitalocean/models/compute'
      model        :server
      collection   :servers
      model        :flavor
      collection   :flavors
      model        :image
      collection   :images
      model        :region
      collection   :regions
      
      request_path 'fog/digitalocean/requests/compute'
      request      :list_servers
      request      :list_images
      request      :list_regions
      request      :list_flavors
      request      :get_server_details
      request      :create_server
      request      :destroy_server
      request      :reboot_server
      request      :power_cycle_server
      request      :power_off_server
      request      :power_on_server
      request      :shutdown_server
      request      :list_ssh_keys
      request      :create_ssh_key

      # request :digitalocean_resize      

      class Mock

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :servers => [],
              :ssh_keys => []
            }
          end
        end

        def self.reset
          @data = nil
        end

        def initialize(options={})
          @digitalocean_api_key = options[:digitalocean_api_key]
        end

        def data
          self.class.data[@digitalocean_api_key]
        end

        def reset_data
          self.class.data.delete(@digitalocean_api_key)
        end

      end

      class Real

        def initialize(options={})
          @digitalocean_api_key   = options[:digitalocean_api_key]
          @digitalocean_client_id = options[:digitalocean_client_id]
          @digitalocean_api_url   = options[:digitalocean_api_url] || \
                                            "https://api.digitalocean.com"
          @connection             = Fog::Connection.new(@digitalocean_api_url)
        end

        def reload
          @connection.reset
        end

        def request(params)
          params[:query] ||= {}
          params[:query].merge!(:api_key   => @digitalocean_api_key)
          params[:query].merge!(:client_id => @digitalocean_client_id)

          response = @connection.request(params)

          unless response.body.empty?
            response.body = Fog::JSON.decode(response.body)
            if response.body['status'] != 'OK'
              raise Fog::Errors::Error.new
            end
          end
          response
        end

      end
    end
  end
end