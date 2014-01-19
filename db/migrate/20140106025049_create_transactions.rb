class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :bitcoin_address
      t.string :bitcoin_transaction_id
      t.integer :satoshis
      t.money :usd, currency: { present: false }
      t.string :message

      t.timestamps
    end
  end
end
