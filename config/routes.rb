OverpricedBitcoin::Application.routes.draw do
  resources :transactions, only: [:new, :create, :show, :index]
  root to: 'transactions#new'
end
