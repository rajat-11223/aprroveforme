class ApproveForMe.Pages.SubscriptionNew extends ApproveForMe.Page
  render: ->
    paymentForm = $(".pay-with-card")
    ApproveForMe.payments.setupForm(paymentForm)
