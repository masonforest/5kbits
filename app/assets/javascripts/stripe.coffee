class StripeForm
  STRIPE_ERROR_MAP:
    "number": "#transaction_form_credit_card_number"
    "exp_month": "#transaction_form_expiration_date"
    "exp_year": "#transaction_form_expiration_date"
    "cvc": "#transaction_form_cvc"

  constructor: (selector)->
    @$form = $(selector)
    @creditCardNumber().payment('formatCardNumber')
    @expirationDate().payment('formatCardExpiry')
    @bind()

  bind: ->
    @$form.submit(@onSubmit)

  stripeToken: ->
    $('#transaction_form_stripe_token')

  creditCardNumber: ->
    $('#transaction_form_credit_card_number')

  expirationDate: ->
    $('#transaction_form_expiration_date')

  cvc: ->
    $('#transaction_form_cvc')

  submitButton: ->
    @$form.find("input[type='submit']")

  disableButton: ->
    @submitButton().prop('disabled', true)

  enableButton: ->
    @submitButton().prop('disabled', false)

  requestStripeToken: =>
    Stripe.card.createToken
      number: @creditCardNumber().val()
      cvc: @cvc().val()
      exp_month: @expirationDate().payment('cardExpiryVal')['month'] || 0
      exp_year: @expirationDate().payment('cardExpiryVal')['year'] || 0
      ,
      @stripeCallback

  stripeCallback: (status, response) =>
    if response.error
      @displayError(response.error)
      @enableButton()
    else
      @setStripeToken(response.id)
      @submit()

  setStripeToken: (value) ->
    @stripeToken().val(value)

  submit: ->
    @$form.get(0).submit()

  displayError: (error) ->
    @$form.find('.error').remove()
    $(@STRIPE_ERROR_MAP[error.param])
      .after("<span class=error>#{error.message}")

  onSubmit: (e) =>
    e.preventDefault()
    @disableButton()
    @requestStripeToken()

$ ->
  new StripeForm('#new_transaction_form')
