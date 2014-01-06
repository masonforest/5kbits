require 'spec_helper'

feature 'purchasing bitcoin' do
  scenario 'user purchases bitcoin' do
    $bitcoin_client.stub(:sendtoaddress)
    visit root_path

    fill_in 'BTC', with: '1.0'
    fill_in 'Bitcoin Address', with: 'xxx'
    fill_in 'Message', with: 'Test'
    fill_in 'Credit Card Number', with: '4242424242424242'
    fill_in 'MM / YY', with: '1 / 20'
    fill_in 'CVC', with: '123'

    click_button 'Purchase Bitcoin'

    expect(FakeStripe.charge_count).to eq 1
    expect($bitcoin_client).to have_received(:sendtoaddress).with('xxx', '1.0','Test')
  end
end
