class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :bitcoin_address
      t.string :bitcoin_transaction_id
      t.decimal :btc
      t.money :usd, currency: { present: false }
      t.string :message

      t.timestamps
    end
  end
end
