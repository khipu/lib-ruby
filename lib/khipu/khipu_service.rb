require 'net/http'
require 'openssl'
require 'base64'

module Khipu
  class KhipuService

    attr_accessor :receiver_id, :secret, :agent

    def initialize(receiver_id, secret)
      @receiver_id = receiver_id
      @secret = secret
    end

    def post(endpoint, params, json_response = true, base_url = Khipu::API_URL)
      uri = URI(base_url + endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      if Khipu::DEBUG
        http.set_debug_output(Khipu::debug_stream)
      end

      params['agent'] = "lib-ruby-#{Khipu::VERSION} - #{@agent}" if @agent

      req = Net::HTTP::Post.new(uri.request_uri, {'User-Agent' => "khipu-ruby-#{Khipu::VERSION}"})
      req.set_form_data(params)
      res = http.request(req)
      if res.code == '400'
        begin
          error = JSON.parse(res.body)
          raise ApiError.new(error['error']['type'], error['error']['message'])
        rescue JSON::ParserError
          raise "Invalid response from endpoint #{uri}"
        end
      elsif res.code != '200'
        raise "Invalid response code #{res.code} endpoint #{uri}"
      end
      if Khipu::DEBUG
        Khipu::debug_stream.puts res.body
      end
      if json_response
        begin
          JSON.parse(res.body)
        rescue JSON::ParserError
          raise "Invalid response from endpoint #{uri}"
        end
      else
        res.body
      end
    end

    def check_arguments(args, mandatory_args)
      mandatory_args.each do |arg|
        if (!args.has_key? arg)
          raise(ArgumentError, "#{arg} not present")
        end
      end
    end

    def hmac_sha256(secret, data)
      OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, data).unpack('H*').first
    end

    def concatenated(params)
      params.collect { |k, v| k.to_s + '=' + v.to_s }.join('&')
    end

    def verify_signature(params, signature)
      cert_data = Khipu::dev_env? ? Khipu::CERT_DEV : Khipu::CERT_PROD
      cert = OpenSSL::X509::Certificate.new(cert_data)
      pkey = cert.public_key
      pkey.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(signature), concatenated(params))
    end

  end
end
