class Transaction < ActiveRecord::Base
  monetize :usd_cents
end
