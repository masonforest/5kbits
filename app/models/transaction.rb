class Transaction < ActiveRecord::Base
  monetize :usd_cents

  def btc=(btc)
    write_attribute(:satoshis, btc * 100000000)
  end

  def btc
    (read_attribute(:satoshis) / 100000000.0).round(8)
  end
end
