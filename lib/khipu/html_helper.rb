module Khipu
  class HtmlHelper < KhipuService

    def initialize(receiver_id, secret)
      super(receiver_id, secret)
    end

    def create_payment_form(args, button = Khipu::FORM_BUTTONS['50x25'])
      endpoint_url = Khipu::API_URL + 'createPaymentPage'
      check_arguments(args, [:subject, :amount])
      params = {
          receiver_id: @receiver_id,
          subject: args[:subject],
          body: args[:body] || '',
          amount: args[:amount]
      }
      payer_username = ''
      if args[:payer_username]
        payer_username = %Q{\n<input type="hidden" name="payer_username" value="#{args[:payer_username]}"/>}
        params[:payer_username] = args[:payer_username]
      end
      params.merge!({
          payer_email: args[:payer_email] || '',
          bank_id: args[:bank_id] || '',
          expires_date: args[:expires_date] || '',
          transaction_id: args[:transaction_id] || '',
          custom: args[:custom] || '',
          notify_url: args[:notify_url] || '',
          return_url: args[:return_url] || '',
          cancel_url: args[:cancel_url] || '',
          picture_url: args[:picture_url] || '',
      })
      params[:hash] = hmac_sha256(@secret, concatenated(params))
      %Q{<form action="#{endpoint_url}" method="post">
<input type="hidden" name="receiver_id" value="#{params[:receiver_id]}">
<input type="hidden" name="subject" value="#{params[:subject]}"/>
<input type="hidden" name="body" value="#{params[:body]}">
<input type="hidden" name="amount" value="#{params[:amount]}">#{payer_username}
<input type="hidden" name="notify_url" value="#{params[:notify_url]}"/>
<input type="hidden" name="return_url" value="#{params[:return_url]}"/>
<input type="hidden" name="cancel_url" value="#{params[:cancel_url]}"/>
<input type="hidden" name="custom" value="#{params[:custom]}">
<input type="hidden" name="transaction_id" value="#{params[:transaction_id]}">
<input type="hidden" name="payer_email" value="#{params[:payer_email]}">
<input type="hidden" name="expires_date" value="#{params[:expires_date]}">
<input type="hidden" name="bank_id" value="#{params[:bank_id]}">
<input type="hidden" name="picture_url" value="#{params[:picture_url]}">
<input type="hidden" name="hash" value="#{params[:hash]}">
<input type="image" name="submit" src="#{button}">
</form>}
    end
  end
end