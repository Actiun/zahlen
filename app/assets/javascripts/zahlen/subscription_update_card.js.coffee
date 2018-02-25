class @ChangeSubscriptionCard
  @form_selector: '.zahlen-change-subscription-card-form'

  constructor: (options = {}) ->
    $.extend @, {}, options
    @handlers()
    $(@constructor.form_selector).find('.zahlen-error').hide()

  handlers: ->
    @formSubmitHandler()

  formSubmitHandler: ->
    self = @
    form_selector = @constructor.form_selector

    $(document).off('click', '.zahlen-change-subscription-card-button').on 'click','.zahlen-change-subscription-card-button', (e) ->
      e.preventDefault()
      $(".zahlen-change-subscription-card-button").prop("disabled", true);
      $(".zahlen-change-subscription-card-button-text").hide();
      $(".zahlen-change-subscription-card-button-spinner").show();

      if !self.validateForm()
        ChangeSubscriptionCard.showError(Zahlen.locale().errors.not_valid)
        return false

      $(form_selector).trigger('zahlen:processingCardUpdate')

      Conekta.Token.create($(form_selector), self.conektaSuccessResponseHandler, self.conektaErrorResponseHandler)

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
    form = $(ChangeSubscriptionCard.form_selector)
    form.find("input[data-conekta*='card']").prop('disabled', true)
    form.append $('<input type="hidden" name="gateway_card_id">').val(token.id)
    form.submit()

  conektaErrorResponseHandler: (err) ->
    console.log err
    ChangeSubscriptionCard.showError(err.message_to_purchaser)

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
    $(form_selector).trigger('error', msg)
    $(".zahlen-change-subscription-card-button").prop("disabled", false);
    $(".zahlen-change-subscription-card-button-text").show();
    $(".zahlen-change-subscription-card-button-spinner").hide();
    $(form_selector).find('.zahlen-error').text(msg)
    $(form_selector).find('.zahlen-error').show()
    $(form_selector).trigger('zahlen:error');
    console.log $(form_selector).find('.zahlen-error')

ready = ->
  new ChangeSubscriptionCard

$(document).ready(ready)
$(document).on('page:load', ready)
