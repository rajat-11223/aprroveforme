class ApproveForMe.Pages.ApprovalsNew extends ApproveForMe.Page
  render: ->
    $("#datepicker").datepicker({minDate: '+1D'})

  bindEvents: ->
    @onEvent 'click', '.destroy-approver', {}, @markAsDestroyedAndHide


  # Helpers
  markAsDestroyedAndHide: ->
    $this = $(this)
    approver = $this.parents(".approver")
    remove_checkbox = approver.find("input.destroy-approver-checkbox")

    remove_checkbox.prop("checked", true)
    approver.hide()
