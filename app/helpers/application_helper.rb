module ApplicationHelper
  def btc_remaining
    Account.balance
  end

  def usd_remaining
    number_to_currency(Account.balance_in_cents / 100.0)
  end
end
