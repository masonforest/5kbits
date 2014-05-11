class TransactionForm
  include ActiveModel::Model
  include ActiveRecord::Callbacks
  include MoneyRails::ActiveRecord::Monetizable
  include ActionView::Helpers::NumberHelper

  attr_reader(
    :usd,
    :credit_card_number,
    :expiration_date,
    :cvc,
    :transaction,
  )

  attr_accessor(
    :bitcoin_address,
    :message,
    :card_uri,
    :usd_cents
  )

  validates :bitcoin_address, format: { with: /\A(1|3)[a-zA-Z1-9]{26,33}\z/,
    message: 'invalid bitcoin address' }

  monetize :usd_cents

  def submit
    if valid?
      ActiveRecord::Base.transaction do
        charge_card
        transfer_bitcoins
        create_transaction
      end
    else
      false
    end
  end

  def transfer_bitcoins
    unless Rails.env.development?
      @bitcoin_transaction_id = $bitcoin_client.sendtoaddress(bitcoin_address, btc.to_f.round(8), message)
      Rails.cache.delete(:balance)
    end
  end

  def charge_card
    @card = Balanced::Card.fetch(card_uri)
    a = @card.debit(
      amount: 500,
      appears_on_statement_as: '5kbits.com',
      description: '5000 bits'
    )

    binding.pry
  end

  def create_transaction
    @transaction = Transaction.create(
      bitcoin_address: bitcoin_address,
      bitcoin_transaction_id: @bitcoin_transaction_id,
      btc: btc,
      card_fingerprint:  'balanced',
      usd_cents: usd_cents,
      message: message
    )
  end

  def changed_attributes
    { usd: usd }
  end

  private

  def max_cents
    ENV['MAXIUM_AMOUNT_IN_CENTS'].to_i
  end

  def max_usd
    max_cents / 100.0
  end

  def max_purchase
    [
      (max_usd - total_purchased_with_card),
      Account.balance_in_usd
    ].min
  end

  def btc
    0.005
  end
end
