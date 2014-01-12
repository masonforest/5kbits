class TransactionForm
  include ActiveModel::Model
  include MoneyRails::ActiveRecord::Monetizable

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
    :stripe_token,
    :usd_cents
  )

  validates :bitcoin_address, format: { with: /\A(1|3)[a-zA-Z1-9]{26,33}\z/,
    message: 'invalid bitcoin address' }

  monetize :usd_cents, :numericality => {
    greater_than: 0,
    less_than_or_equal_to: ENV['MAXIUM_AMOUNT_IN_CENTS'].to_i
  }

  validate :amount_is_valid

  def submit
    if valid?
      ActiveRecord::Base.transaction do
        transfer_bitcoins
        charge_card
        create_transaction
      end
    else
      false
    end
  end

  def transfer_bitcoins
    if Rails.env.production?
      @bitcoin_transaction_id = $bitcoin_client.sendtoaddress(bitcoin_address, btc.to_f.round(8), message)
    end
  end

  def charge_card
    Stripe::Charge.create(
      amount: usd_cents,
      currency: 'usd',
      card: stripe_token,
      description: message
    )
  end

  def create_transaction
    @transaction = Transaction.create(
      bitcoin_address: bitcoin_address,
      bitcoin_transaction_id: @bitcoin_transaction_id,
      btc: btc,
      usd_cents: usd_cents,
      message: message
    )
  end

  def changed_attributes
    { usd: usd }
  end

  private

  def amount_is_valid
    if usd_cents == 0
      errors.add(:usd, 'amount is invalid')
    elsif usd_cents > ENV['MAXIUM_AMOUNT_IN_CENTS'].to_i
      errors.add(:usd, "amount must be less than $#{(ENV['MAXIUM_AMOUNT_IN_CENTS']/100.0).round2}")
    end
  end

  def btc
    (usd_cents / ENV['BTC_TO_USD_CENTS_EXCHANGE_RATE'].to_f)
      .round(8)
  end

end
