class Account
  def self.balance
    Rails.cache.fetch(:balance) do
      $bitcoin_client.getbalance
    end
  end

  def self.balance_in_usd
    balance_in_usd_cents / 100.0
  end

  def self.balance_in_usd_cents
    balance *  ENV['BTC_TO_USD_CENTS_EXCHANGE_RATE'].to_i
  end
end
