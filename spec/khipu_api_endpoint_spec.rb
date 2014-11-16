require "spec_helper"

describe Khipu::KhipuApiEndpoint do
  let(:api) { Khipu.create_khipu_api(1234, '1234') }

  describe ".create_receiver" do
    let(:receiver_params) do
      {
        first_name: 'First Name',
        last_name: 'Last Name',
        email: 'email@domain.com',
        notify_url: 'https://example.com/notify_url',
        identifier: '12345678-5',
        bussiness_category: 'Business Category',
        bussiness_name: 'Business Name',
        phone: '56221234567',
        address_line_1: 'Address Line 1',
        address_line_2: 'Address Line 2',
        address_line_3: 'Address Line 3',
        country_code: 'cl'
      }
    end
    let(:return_params) do
      {
        receiver_id: 1369,
        secret: "392d15ea0a92b83b1b54ddda165efd146ff81804"
      }
    end

    subject { api.create_receiver(receiver_params) }

    before do
      stub_request(:post, "https://khipu.com/integratorApi/1.3/createReceiver")
      .to_return(body: return_params.to_json)
    end

    it { should include('receiver_id') }
    it { should include('secret') }
    it { expect(subject['receiver_id']).to eq 1369 }
    it { expect(subject['secret']).to eq "392d15ea0a92b83b1b54ddda165efd146ff81804" }
  end

  describe ".create_integrator_payment_url" do
    let(:payment_params) do
      {
        subject: 'Laser Printer',
        body: 'Multiple tray laser printer.',
        amount: '100',
        integrator_fee: '10',
        notify_url: 'https://example.com/notify_url',
        return_url: 'https://example.com/return_url',
        cancel_url: 'https://example.com/cancel_url',
        transaction_id: 'T-1000',
        expires_date: DateTime.now + 30*24*60*60, # 30 days
        payer_email: 'email@example.com',
        custom: 'Red model.'
      }
    end
    let(:return_params) do
      {
        id: "cghs6n7mtklx",
        bill_id: "SSRwa",
        url: "https://khipu.com/payment/show/cghs6n7mtklx",
        manual_url: "https://khipu.com/payment/manual/cghs6n7mtklx",
        mobile_url: "khipu:///pos/cghs6n7mtklx",
        ready_for_terminal: false
      }
    end

    subject { api.create_integrator_payment_url(payment_params) }

    before do
      stub_request(:post, "https://khipu.com/integratorApi/1.3/createPaymentURL")
      .to_return(body: return_params.to_json)
    end

    it { should include('id') }
    it { should include('url') }
    it { should include('mobile_url') }
    it { expect(subject['id']).to eq 'cghs6n7mtklx' }
    it { expect(subject['url']).to eq 'https://khipu.com/payment/show/cghs6n7mtklx' }
    it { expect(subject['mobile_url']).to eq 'khipu:///pos/cghs6n7mtklx' }
  end
end
