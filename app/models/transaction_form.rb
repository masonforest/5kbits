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
    :stripe_token,
    :stripe_customer_id,
    :usd_cents
  )

  validates :bitcoin_address, format: { with: /\A(1|3)[a-zA-Z1-9]{26,33}\z/,
    message: 'invalid bitcoin address' }

  monetize :usd_cents

  validate :total_purchased_with_card_is_valid

  validates(
    :usd,
    numericality: {
      greater_than_or_equal_to: 1,
      message: "must be greater than or equal to $1"
    }
  )

  validates(
    :usd,
    numericality: {
      less_than_or_equal_to: :max_purchase,
      message: lambda {|translation, error| "must be less than or equal to $#{sprintf("%.2f", error[:count])}"}
    }
  )

  before_validation :create_stripe_customer

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
    @stripe_charge = Stripe::Charge.create(
      amount: usd_cents,
      currency: 'usd',
      customer: @stripe_customer,
      description: message
    )
  end

  def create_transaction
    @transaction = Transaction.create(
      bitcoin_address: bitcoin_address,
      bitcoin_transaction_id: @bitcoin_transaction_id,
      btc: btc,
      card_fingerprint:  @stripe_charge.card.fingerprint,
      usd_cents: usd_cents,
      message: message
    )
  end

  def changed_attributes
    { usd: usd }
  end

  private

  def total_purchased_with_card_is_valid
    if total_purchased_with_card >= max_cents
      errors.add(:usd, "you have already spent #{number_to_currency(max_cents / 100.0)} with this card")
    end
  end

  def total_purchased_with_card
    Transaction.where(card_fingerprint: card_fingerprint).sum(:usd_cents) / 100.0
  end

  def create_stripe_customer
    if stripe_customer_id
      @stripe_customer = Stripe::Customer.retrive(stripe_customer_id)
    else
      @stripe_customer = Stripe::Customer.create(card: stripe_token)
      stripe_customer_id = @stripe_customer_id
    end
  end

  def card_fingerprint
    card.fingerprint
  end

  def card
    @stripe_customer.cards.first
  end

  def amount_is_valid
    if usd_cents > max_cents
      errors.add(:usd, "amount must be less than #{number_to_currency(max_cents / 100.0)}")
    end
  end

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
    (usd_cents / ENV['BTC_TO_USD_CENTS_EXCHANGE_RATE'].to_f)
      .round(8)
  end

end
