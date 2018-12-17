class ApproveForMe.Pages.AccountPaymentMethod extends ApproveForMe.Page
  render: ->

  bindEvents: ->
    @onEvent 'click', '.add-payment-method', {}, @addPaymentMethod

  addPaymentMethod: (e) ->
    e.preventDefault()

    modalElem = $("#addPaymentMethod")
    modal = new Foundation.Reveal(modalElem)
    ApproveForMe.payments.setupForm(modalElem)
    modal.open()
