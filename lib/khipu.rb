require 'khipu/version'
require 'khipu/khipu_service'
require 'khipu/khipu_api_endpoint'
require 'khipu/html_helper'
require 'khipu/api_error'
require 'khipu/const'

module Khipu

  API_URL = 'https://khipu.com/api/1.3/'
  DEBUG = ENV['KHIPU_DEBUG'] || false
  FORM_BUTTONS = {
      '50x25'       => '50x25.png',
      '100x25'      => '100x25.png',
      '100x25white' => '100x25-w.png',
      '100x50'      => '100x50.png',
      '100x50white' => '100x50-w.png',
      '150x25'      => '150x25.png',
      '150x25white' => '150x25-w.png',
      '150x50'      => '150x50.png',
      '150x50white' => '150x50-w.png',
      '150x75'      => '150x75.png',
      '150x75white' => '150x75-w.png',
      '200x50'      => '200x50.png',
      '200x50white' => '200x50-w.png',
      '200x75'      => '200x75.png',
      '200x75white' => '200x75-w.png',
  }.inject({}) { |h, (k, v)| h[k] = 'https://s3.amazonaws.com/static.khipu.com/buttons/' + v; h }

  def self.create_khipu_api(receiver_id, secret = '')
    KhipuApiEndpoint.new(receiver_id, secret)
  end

  def self.create_html_helper(receiver_id, secret)
    HtmlHelper.new(receiver_id, secret)
  end

  def self.debug_stream
    $stdout
  end

  def self.dev_env?
    ENV['KHIPU_ENV'] == 'DEV'
  end
end
