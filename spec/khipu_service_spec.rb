require "spec_helper"

describe 'KhipuService' do

  it 'should calculate hmac' do
    service = Khipu::KhipuService.new(1234, '1234')
    hex_hmac = service.hmac_sha256('abcd', '1234')
    expect(hex_hmac).to eq('d219a3dd877f943be0ee65ef6a34129778d2fd0568ce2d9a8f37fea9d7fcaca3')
  end

  it 'should concatenate parameters' do
    service = Khipu::KhipuService.new(1234, '1234')
    params = service.concatenated(a: 1, b: 'foo', c: nil)
    expect(params).to eq('a=1&b=foo&c=')
  end

end