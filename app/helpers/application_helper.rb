module ApplicationHelper
  def btc_remaining
    Account.balance
  end

  def usd_remaining
    number_to_currency(Account.balance_in_cents / 100.0)
  end

  def exchange_rate
    number_to_currency(ENV['BTC_TO_USD_CENTS_EXCHANGE_RATE'].to_i / 100.0)
  end
end
