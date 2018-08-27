class ApproveForMe.Pages.SubscriptionsNew extends ApproveForMe.Page
  render: ->
    paymentForm = $(".pay-with-card")
    ApproveForMe.payments.setupForm(paymentForm)
