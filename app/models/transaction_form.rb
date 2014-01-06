class TransactionForm
  include ActiveModel::Model

  attr_reader(
    :credit_card_number,
    :expiration_date,
    :cvc,
    :transaction
  )

  attr_accessor(
    :bitcoin_address,
    :btc,
    :message,
    :stripe_token
  )

  def submit
    if valid?
      ActiveRecord::Base.transaction do
        charge_card
        transfer_bitcoins
        create_transaction
      end
    end
  end

  def transfer_bitcoins
    $bitcoin_client.sendtoaddress(bitcoin_address, btc, message)
  end

  def charge_card
    Stripe::Charge.create(
      amount: amount_in_cents,
      currency: 'usd',
      card: stripe_token,
      description: message
    )
  end

  def create_transaction
    @transaction = Transaction.create(
      bitcoin_address: bitcoin_address,
      btc: btc,
      amount_in_cents: amount_in_cents,
      message: message
    )
  end

  private

  def amount_in_cents
    btc.to_i * ENV['BTC_TO_USD_CENTS_EXCHANGE_RATE'].to_i
  end
end
