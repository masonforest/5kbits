class AddCardFingerprintToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :card_fingerprint, :string
  end
end
