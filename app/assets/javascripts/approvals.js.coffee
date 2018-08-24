# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

document.addEventListener "turbolinks:load", ->
  $("#datepicker").datepicker({minDate: '+1D'})

  $(".add-payment-method").click (e) ->
    e.preventDefault()

    modalElem = $("#addPaymentMethod")
    modal = new Foundation.Reveal(modalElem)
    ApproveForMe.payments.setupForm(modalElem)
    modal.open()

  $(".continue-change").click ->
    id = $(this).data('id');
    continuePermission(id);

  continuePermission = (id) ->
    $.ajax
      url: '/subscription/continue_permission'
      type: 'GET'
      data: {id: id}
      success: (data) ->
        $("#permissionModal").html(data)

        modal = new Foundation.Reveal($("#confirmPlanChange"))
        modal.open()
      error: (data) ->
        console.log("ERROR in #continuePermission")
        console.log(data)
