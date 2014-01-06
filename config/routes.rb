BitcoinExchange::Application.routes.draw do
  resources :transactions, only: [:new, :create, :show]
  root to: 'transactions#new'
end
