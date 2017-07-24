class @Zahlen
  @language: 'en'
  @locales:
    en:
      errors:
        not_valid: 'The card information is not a valid. Please check the errors marked on red.'
        card_number: 'Credit card number is invalid.'
        card_exp: 'The expiration date is invalid.'
        card_exp_month: 'The expiration month is invalid.'
        card_exp_year: 'The expiration year is invalid.'
        card_cvc: 'The cvc is invalid.'
        card_holdername: "The cardholder's name is invalid."
        rejected: 'Sorry! Your payment data was declined. Please try again or try a new card.'
        timeout: 'This seems to be taking too long. Please contact support and give them transaction ID: '

    es:
      errors:
        not_valid: 'La información de la tarjeta es invalida. Por favor revisa los campos marcados en rojo.'
        card_number: 'El número de la tarjeta es invalido.'
        card_exp: 'La fecha de expiración es invalida.'
        card_exp_month: 'El mes de expiración es invalido.'
        card_exp_year: 'El año de expiración es invalido.'
        card_cvc: 'El código de seguridad es invalido.'
        card_holdername: "El nombre del titular es invalido."
        rejected: '¡Lo sentimos! Pero tu pago fue decliado por la institución bancaria. Por favor intentalo de nuevo'
        timeout: 'Al parecer ha tomado mucho tiempo esta validar tu transación. Por favor contacta a nuestro equipo de soporte y proporcionales el siguiente identificador de transacción: '

  @locale: ->
    Zahlen.locales[@language]
