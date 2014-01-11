$ ->
  EXCHANGE_RATE = $('meta[name=btc_to_usd_cents_exchange_rate]').attr('value') / 100
  $('.amount .input-group-addon').click ->
    $('.input-group').removeClass('active')

    $(this)
      .parents('.amount')
      .find('input')
      .attr(disabled: 'disabled')
      .append("<span class='glyphicon glyphicon-pencil' />")

    $(this)
      .parents('.input-group')
      .addClass('active')
      .find('input')
      .removeAttr('disabled')

  $('#transaction_form_btc').on 'keyup', ->
    unless ($(this).val() * EXCHANGE_RATE).isNaN
      $('#transaction_form_usd').val(($(this).val() * EXCHANGE_RATE).toFixed(2))

  $('#transaction_form_usd').on 'keyup', ->
    unless ($(this).val() * EXCHANGE_RATE).isNaN
      $('#transaction_form_btc').val(($(this).val() / EXCHANGE_RATE).toFixed(6))

  $('#transaction_form_usd').on 'blur', ->
    unless isNaN($(this).val())
      $(this).val((+$(this).val()).toFixed(2))
