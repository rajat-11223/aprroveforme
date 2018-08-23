# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

closeCallouts = ->
  $('.callout').trigger('close')

document.addEventListener "turbolinks:load", ->
  setTimeout ->
    closeCallouts()
  , 4000

  if $("#datepicker").length > 0
    $("#datepicker").datepicker({minDate: '+1D'})

  if $(".add-payment-method").length > 0
    $(".add-payment-method").click ->
      $('#myModal').foundation('reveal', 'open')

  if $(".continue-change").length > 0
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
          console.log(data);
