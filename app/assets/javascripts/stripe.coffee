class BalancedForm
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

  cardURI: ->
    $('#transaction_form_card_uri')

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

  requestBalancedToken: =>
    balanced.card.create
      number: @creditCardNumber().val()
      cvc: @cvc().val()
      expiration_month: @expirationDate().payment('cardExpiryVal')['month'] || 0
      expiration_year: @expirationDate().payment('cardExpiryVal')['year'] || 0
      ,
      @balancedCallback

  balancedCallback: (response) =>
    @setCardURI(response.cards[0].href)
    @submit()

  setCardURI: (value) ->
    @cardURI().val(value)

  submit: ->
    @$form.get(0).submit()

  displayError: (error) ->
    @$form.find('.error').remove()
    $(@STRIPE_ERROR_MAP[error.param])
      .after("<span class=error>#{error.message}")

  onSubmit: (e) =>
    e.preventDefault()
    @disableButton()
    @requestBalancedToken()

$ ->
  new BalancedForm('#new_transaction_form')
