require "spec_helper"

describe Khipu::KhipuService do
  let(:service) { Khipu::KhipuService.new(1234, '1234') }

  it 'should calculate hmac' do
    hex_hmac = service.hmac_sha256('abcd', '1234')
    expect(hex_hmac).to eq('d219a3dd877f943be0ee65ef6a34129778d2fd0568ce2d9a8f37fea9d7fcaca3')
  end

  it 'should concatenate parameters' do
    params = service.concatenated(a: 1, b: 'foo', c: nil)
    expect(params).to eq('a=1&b=foo&c=')
  end

  describe '.post' do
    it 'should return body if response is not json' do
      stub_request(:post, 'https://khipu.com/api/1.3/endpoint').
        to_return(status: 200, body: 'Hello World')
      expect(service.post('endpoint', {}, false)).to eq('Hello World')
    end

    it 'should return json if response is json' do
      stub_request(:post, 'https://khipu.com/api/1.3/endpoint').
        to_return(status: 200, body: {text: 'Hello World'}.to_json)
      expect(service.post('endpoint', {})).to eq({'text' => 'Hello World'})
    end

    it 'should raise error with invalid json response' do
      stub_request(:post, 'https://khipu.com/api/1.3/endpoint').
        to_return(status: 200, body: '{"text":}')
      expect{service.post('endpoint', {})}.to raise_error /invalid response from endpoint/i
    end

    it 'should raise error with status code different from 200 and 400' do
      stub_request(:post, 'https://khipu.com/api/1.3/endpoint').
        to_return(status: 500)
      expect{service.post('endpoint', {})}.to raise_error /invalid response code/i
    end

    it 'should raise error with status code 400 and invalid json' do
      stub_request(:post, 'https://khipu.com/api/1.3/endpoint').
        to_return(status: 400, body: '{"error":}')
      expect{service.post('endpoint', {})}.to raise_error /invalid response from endpoint/i
    end

    it 'should raise Khipu::ApiError with status code 400' do
      stub_request(:post, 'https://khipu.com/api/1.3/endpoint').
        to_return(status: 400, body: {error: {type:'Type', message: 'Message'}}.to_json)
      expect{service.post('endpoint', {})}.to raise_error do |error|
        expect(error).to be_a(Khipu::ApiError)
        expect(error.type).to eq('Type')
        expect(error.message).to eq('Message')
      end
    end
  end
end
