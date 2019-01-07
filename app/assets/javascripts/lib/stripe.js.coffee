ApproveForMe.payments.stripeTokenHandler = (token) ->
  # Insert the token ID into the form so it gets submitted to the server
  form = document.getElementById('payment-form');
  hiddenInput = document.createElement('input');

  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'stripeToken');
  hiddenInput.setAttribute('value', token.id);
  form.appendChild(hiddenInput);

  # Submit the form
  form.submit();

ApproveForMe.payments.setupForm = (parent) ->
  stripe = Stripe(gon.global.stripePublishableKey)

  # Create an instance of Elements.
  elements = stripe.elements()

  form = parent.find("form")
  displayError = parent.find("#{}card-errors")

  # Custom styling can be passed to options when creating an Element.
  # (Note that this demo uses a wider set of styles than the guide below.)
  # style =
  #   base:
  #     color: '#32325d'
  #     lineHeight: '18px'
  #     fontFamily: '"Helvetica Neue", Helvetica, sans-serif'
  #     fontSmoothing: 'antialiased'
  #     fontSize: '16px'
  #     '::placeholder': color: '#aab7c4'
  #   invalid:
  #     color: '#fa755a'
  #     iconColor: '#fa755a'
  style = {}

  # Create an instance of the card Element.
  card = elements.create('card', style: style)

  # Add an instance of the card Element into the `element` <div>.
  card.mount "#card-element"

  # Handle real-time validation errors from the card Element.
  card.addEventListener 'change', (event) ->
    if event.error
      displayError.textContent = event.error.message
    else
      displayError.textContent = ''
    return

  # Handle form submission.
  form.submit (e) ->
    e.preventDefault()

    stripe.createToken(card).then (result) ->
      if result.error
        # Inform the user if there was an error.
        displayError.textContent = result.error.message
      else
        # Send the token to your server.
        ApproveForMe.payments.stripeTokenHandler result.token
