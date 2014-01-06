Stripe.api_key = ENV['STRIPE_API_KEY']

unless defined? STRIPE_JS_HOST
  STRIPE_JS_HOST = 'https://js.stripe.com'
end
