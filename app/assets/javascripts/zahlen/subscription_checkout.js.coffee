class @SubscriptionCheckout
  @form_selector: '.zahlen-subscription-form'
  @payment_method: 'card'

  constructor: (options = {}) ->
    $.extend @, {}, options
    @handlers()
    $(@constructor.form_selector).find('.zahlen-error').hide()
    @displayPaymentMethodData()

  handlers: ->
    @formSubmitHandler()
    @getInitPaymentMethod()
    @paymentMethodToggle()

  formSubmitHandler: ->
    self = @
    form_selector = @constructor.form_selector
    self.payment_method = $("input[data-zahlen='payment-method']:checked").val()

    $(document).off("submit#{form_selector}").on "submit#{form_selector}", "#{form_selector}", (e) ->
      e.preventDefault()
      if self.payment_method in ['card']
        if !self.validateForm()
          SubscriptionCheckout.showError(Zahlen.locale().errors.not_valid)
          return false

      $(this).find(':submit').prop('disabled', true);
      $('.zahlen-spinner').show();

      if !self.payment_method?
        console.log "No payment method has been found. Please check your form."
        return false

      if self.payment_method in ['card']
        Conekta.Token.create($(form_selector), self.conektaSuccessResponseHandler, self.conektaErrorResponseHandler)
      else
        self.offlineReponseHandler()
      return false

  getInitPaymentMethod: ->
    payment_method = $("input[data-zahlen='payment-method']").val()
    if payment_method?
      @payment_method = payment_method.replace(/_/, '-')
      
  paymentMethodToggle: ->
    self = @
    form_selector = @constructor.form_selector
    $('body').on "change", "input[data-zahlen='payment-method']", (e) ->
      payment_method = $(this).val().replace(/_/, '-')
      self.payment_method = payment_method
      self.displayPaymentMethodData()

  displayPaymentMethodData: ->
    $('.payment-method-fields').hide()
    $(".#{@payment_method}-fields").show()

  validateForm: ->
    self = @
    valid = true

    card_number_input = $("input[data-conekta='card[number]']")
    card_holdername_input = $("input[data-conekta='card[name]']")
    card_exp_input = $("input[data-conekta='card[exp]']")
    card_exp_month_input = $("input[data-conekta='card[exp_month]']")
    card_exp_year_input = $("input[data-conekta='card[exp_year]']")
    card_cvc_input = $("input[data-conekta='card[cvc]']")

    if valid_number = !Conekta.card.validateNumber(card_number_input.val())
      valid = false
    self.toggleInputError(card_number_input, valid_number, Zahlen.locale().errors.card_number)

    exp_month = ''
    exp_year = ''
    if card_exp_input.size() > 0
      exp_date = card_exp_input.val().replace(/ /g,'')
      exp_month = exp_date.split('/')[0]
      exp_year = exp_date.split('/')[1]
      card_exp_month_input.val(exp_month)
      card_exp_year_input.val(exp_year)
    else
      exp_month = card_exp_month_input.val()
      exp_year = card_exp_year_input.val()

    if valid_exp = !Conekta.card.validateExpirationDate(exp_month, exp_year)
      valid = false

    if card_exp_input.size() > 0
      self.toggleInputError(card_exp_input, valid_exp, Zahlen.locale().errors.card_exp)
    else
      self.toggleInputError(card_exp_month_input, valid_exp, Zahlen.locale().errors.card_exp_month)
      self.toggleInputError(card_exp_year_input, valid_exp, Zahlen.locale().errors.card_exp_year)

    if valid_cvc = !Conekta.card.validateCVC(card_cvc_input.val())
      valid = false
    self.toggleInputError(card_cvc_input, valid_cvc, Zahlen.locale().errors.card_cvc)

    if invalid_holdername = card_holdername_input.val().length == 0
      valid = false
    self.toggleInputError(card_holdername_input, invalid_holdername, Zahlen.locale().errors.card_holdername)

    return valid

  conektaSuccessResponseHandler: (token) ->
    console.log(token)
    form = $(SubscriptionCheckout.form_selector).clone()
    form.append $('<input type="hidden" name="gateway_card_id">').val(token.id)
    # Remove all card fields from beign submit
    form.find("input[data-conekta*='card']").remove()

    base_path = '/zahlen'
    action = form.attr('action')

    $.ajax
      type: 'POST'
      url: action
      data: form.serialize()
      success: (data) ->
        SubscriptionCheckout.poll 60, data.uuid, base_path
        return
      error: (data) ->
        SubscriptionCheckout.showError jQuery.parseJSON(data.responseText).error
        return

  conektaErrorResponseHandler: (err) ->
    console.log err
    SubscriptionCheckout.showError(err.message_to_purchaser)

  offlineReponseHandler: ->
    form = $(SubscriptionCheckout.form_selector).clone()
    # Remove all card fields from beign submit
    form.find("input[data-conekta*='card']").remove()

    base_path = '/zahlen'
    action = form.attr('action')

    $.ajax
      type: 'POST'
      url: action
      data: form.serialize()
      success: (data) ->
        SubscriptionCheckout.poll 60, data.uuid, base_path
        return
      error: (data) ->
        SubscriptionCheckout.showError jQuery.parseJSON(data.responseText).error
        return

  toggleInputError: (selector, erred, error_msg) ->
    self = @
    $(selector).parent('.form-group').toggleClass('has-error', erred)
    if erred && error_msg.length > 0
      form_group = $(selector).parent('.form-group')
      if form_group.find(".help-block").length
        form_group.find(".help-block").text(error_msg)
      else
        form_group.append("<span class='help-block'>#{error_msg}</span>")
    else
      $(selector).parent('.form-group').find('.help-block').remove()

  paymentMethod: (form_selector) ->
    $(form_selector).find("input[data-zahlen='payment-method']").val()

  @showError: (msg) ->
    form_selector = @form_selector
    $(form_selector).find(':submit').prop('disabled', false).trigger('error', msg)
    $(form_selector).find('.zahlen-error').text(msg)
    $(form_selector).find('.zahlen-error').show()
    console.log $(form_selector).find('.zahlen-error')

  @poll: (num_retries_left, uuid, base_path) ->
    console.log "Searching transaction data => #{num_retries_left}"
    if num_retries_left == 0
      SubscriptionCheckout.showError Zahlen.locale().errors.timeout + uuid
      return

    handler = (data) ->
      if data.status == 'active' || data.status == 'pending_payment'
        window.location = base_path + '/subscription/' + uuid
      else
        setTimeout (->
          SubscriptionCheckout.poll num_retries_left - 1, uuid, base_path
          return
        ), 500
      return

    errorHandler = (jqXHR) ->
      SubscriptionCheckout.showError jQuery.parseJSON(jqXHR.responseText).error
      return

    $.ajax
      type: 'GET'
      dataType: 'json'
      url: base_path + "/subscription/#{uuid}/status"
      success: handler
      error: errorHandler


ready = ->
  new SubscriptionCheckout

$(document).ready(ready)
$(document).on('page:load', ready)
