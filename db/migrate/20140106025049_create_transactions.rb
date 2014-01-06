class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :bitcoin_address
      t.decimal :btc
      t.integer :amount_in_cents
      t.string :message

      t.timestamps
    end
  end
end
