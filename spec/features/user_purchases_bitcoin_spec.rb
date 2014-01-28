require 'spec_helper'

feature 'purchasing bitcoin' do
  scenario 'user purchases bitcoin' do
    amount = 1
    amount_in_btc = (amount * 100.0 / ENV['BTC_TO_USD_CENTS_EXCHANGE_RATE'].to_i.to_f).round(8)
    $bitcoin_client.stub(:sendtoaddress)
    visit root_path

    fill_in 'Amount', with: amount
    fill_in 'Bitcoin Address', with: '1LoBLNKPEdy4GwYWdaDLaTRbB7BBC9dZP3'
    fill_in 'Message', with: 'Test'
    fill_in 'Credit Card Number', with: '4242424242424242'
    fill_in 'MM / YY', with: '1 / 20'
    fill_in 'CVC', with: '123'

    click_button 'Purchase bitcoin'

    expect(FakeStripe.charge_count).to eq 1
    expect($bitcoin_client).to have_received(:sendtoaddress).with('1LoBLNKPEdy4GwYWdaDLaTRbB7BBC9dZP3', amount_in_btc  ,'Test')
  end
end
