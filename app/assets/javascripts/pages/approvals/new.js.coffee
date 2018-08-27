class ApproveForMe.Pages.ApprovalsNew extends ApproveForMe.Page
  render: ->
    $("#datepicker").datepicker({minDate: '+1D'})

  bindEvents: ->
