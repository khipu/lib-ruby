require 'json'

module Khipu
  class KhipuApiEndpoint < KhipuService

    def initialize(receiver_id, secret)
      super(receiver_id, secret)
    end

    def execute(endpoint, params, add_hash = true, json_response = true, base_url = Khipu::API_URL)
      post_params = params.clone
      if add_hash
        post_params['hash'] = hmac_sha256(@secret, concatenated(params))
      end
      post(endpoint, post_params, json_response, base_url)
    end

    def payment_status(args)
      endpoint = 'paymentStatus'
      check_arguments(args, [:payment_id])
      params = {
          receiver_id: @receiver_id,
          payment_id: args[:payment_id]
      }
      execute(endpoint, params)
    end

    def create_payment_url(args)
      endpoint = 'createPaymentURL'
      check_arguments(args, [:subject, :amount])
      params = {
          receiver_id: @receiver_id,
          subject: args[:subject],
          body: args[:body] || '',
          amount: args[:amount],
          payer_email: args[:payer_email] || '',
          bank_id: args[:bank_id] || '',
          expires_date: args[:expires_date] || '',
          transaction_id: args[:transaction_id] || '',
          custom: args[:custom] || '',
          notify_url: args[:notify_url] || '',
          return_url: args[:return_url] || '',
          cancel_url: args[:cancel_url] || '',
          picture_url: args[:picture_url] || ''
      }
      resp = execute(endpoint, params)
      resp_items = %w(id url mobile-url)
      resp.select{|key, value| resp_items.include?(key)}
    end

    def create_authenticated_payment_url(args)
      endpoint = 'createAuthenticatedPaymentURL'
      check_arguments(args, [:subject, :amount, :payer_username])
      params = {
          receiver_id: @receiver_id,
          subject: args[:subject],
          body: args[:body] || '',
          amount: args[:amount],
          payer_username: args[:payer_username],
          payer_email: args[:payer_email] || '',
          bank_id: args[:bank_id] || '',
          expires_date: args[:expires_date] || '',
          transaction_id: args[:transaction_id] || '',
          custom: args[:custom] || '',
          notify_url: args[:notify_url] || '',
          return_url: args[:return_url] || '',
          cancel_url: args[:cancel_url] || '',
          picture_url: args[:picture_url] || ''
      }
      resp = execute(endpoint, params)
      resp_items = %w(id url mobile-url)
      resp.select{|key, value| resp_items.include?(key)}
    end

    def create_email(args)
      endpoint = 'createEmail'
      check_arguments(args, [:subject, :destinataries, :pay_directly, :send_emails])
      params = {
          receiver_id: @receiver_id,
          subject: args[:subject],
          body: args[:body] || '',
          destinataries: args[:destinataries].to_json,
          pay_directly: args[:pay_directly],
          send_emails: args[:send_emails],
          expires_date: args[:expires_date] || '',
          transaction_id: args[:transaction_id] || '',
          custom: args[:custom] || '',
          notify_url: args[:notify_url] || '',
          return_url: args[:return_url] || '',
          cancel_url: args[:cancel_url] || '',
          picture_url: args[:picture_url] || ''
      }
      execute(endpoint, params)
    end

    def receiver_banks
      endpoint = 'receiverBanks'
      params = {
          receiver_id: @receiver_id
      }
      resp = execute(endpoint, params)
      resp_items = %w(id name message min-amount)
      resp['banks'].map{|item| item.select{|key, value| resp_items.include?(key)} }
    end

    def receiver_status
      endpoint = 'receiverStatus'
      params = {
          receiver_id: @receiver_id,
      }
      execute(endpoint, params)
    end

    def set_bill_expired(args)
      endpoint = 'setBillExpired'
      check_arguments(args, [:bill_id])
      params = {
          receiver_id: @receiver_id,
          bill_id: args[:bill_id],
          text: args[:text] || ''
      }
      execute(endpoint, params)
    end

    def set_paid_by_receiver(args)
      endpoint = 'setPaidByReceiver'
      check_arguments(args, [:payment_id])
      params = {
          receiver_id: @receiver_id,
          payment_id: args[:payment_id],
      }
      execute(endpoint, params)
    end

    def set_rejected_by_payer(args)
      endpoint = 'setRejectedByPayer'
      check_arguments(args, [:payment_id])
      params = {
          receiver_id: @receiver_id,
          payment_id: args[:payment_id],
          text: args[:text] || ''
      }
      execute(endpoint, params)
    end

    def verify_payment_notification(args)
      endpoint = 'verifyPaymentNotification'
      check_arguments(args, [:api_version, :notification_id, :subject, :amount, :payer_email, :notification_signature])
      params = {
          api_version: args[:api_version],
          receiver_id: @receiver_id,
          notification_id: args[:notification_id],
          subject: args[:subject],
          amount: args[:amount],
          currency: args[:currency] || 'CLP',
          transaction_id: args[:transaction_id] || '',
          payer_email: args[:payer_email] || '',
          custom: args[:custom] || '',
          notification_signature: args[:notification_signature]
      }
      resp = execute(endpoint, params, false, false)
      resp == 'VERIFIED'
    end

    def verify_payment_notification_local(args)
      check_arguments(args, [:api_version, :notification_id, :subject, :amount, :payer_email, :notification_signature])
      params = {
          api_version: args[:api_version],
          receiver_id: @receiver_id,
          notification_id: args[:notification_id],
          subject: args[:subject],
          amount: args[:amount],
          currency: args[:currency] || 'CLP',
          transaction_id: args[:transaction_id] || '',
          payer_email: args[:payer_email] || '',
          custom: args[:custom] || ''
      }
      verify_signature(params, args[:notification_signature])
    end

    def get_payment_notification(args)
      endpoint = 'getPaymentNotification'
      check_arguments(args, [:notification_token])
      params = {
          receiver_id: @receiver_id,
          notification_token: args[:notification_token]
      }
      execute(endpoint, params)
    end

    # Integrator API

    def create_receiver(args)
      endpoint = 'createReceiver'
      check_arguments(args, [:email, :first_name, :last_name, :notify_url, :identifier, :bussiness_category, :bussiness_name,
                             :phone, :address_line_1, :address_line_2, :address_line_3, :country_code])
      params = {
          receiver_id: @receiver_id,
          email: args[:email],
          first_name: args[:first_name],
          last_name: args[:last_name],
          notify_url: args[:notify_url],
          identifier: args[:identifier],
          bussiness_category: args[:bussiness_category],
          bussiness_name: args[:bussiness_name],
          phone: args[:phone],
          address_line_1: args[:address_line_1],
          address_line_2: args[:address_line_2],
          address_line_3: args[:address_line_3],
          country_code: args[:country_code]
      }
      execute(endpoint, params, true, true, Khipu::INTEGRATOR_API_URL)
    end

    def create_integrator_payment_url(args)
      endpoint = 'createPaymentURL'
      check_arguments(args, [:subject, :amount, :integrator_fee])
      params = {
          receiver_id: @receiver_id,
          subject: args[:subject],
          body: args[:body] || '',
          amount: args[:amount],
          integrator_fee: args[:integrator_fee],
          payer_email: args[:payer_email] || '',
          bank_id: args[:bank_id] || '',
          expires_date: args[:expires_date] || '',
          transaction_id: args[:transaction_id] || '',
          custom: args[:custom] || '',
          notify_url: args[:notify_url] || '',
          return_url: args[:return_url] || '',
          cancel_url: args[:cancel_url] || '',
          picture_url: args[:picture_url] || ''
      }
      resp = execute(endpoint, params, true, true, Khipu::INTEGRATOR_API_URL)
      resp_items = %w(id url mobile_url)
      resp.select{|key, value| resp_items.include?(key)}
    end
  end
end
