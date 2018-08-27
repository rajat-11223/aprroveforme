class ApproveForMe.Pages.ApprovalsEdit extends ApproveForMe.Page
  render: ->
    $("#datepicker").datepicker({minDate: '+1D'})

  bindEvents: ->
