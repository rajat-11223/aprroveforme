class ApproveForMe.Pages.ApprovalsEdit extends ApproveForMe.Page
  render: ->
    $("#datepicker").datepicker({minDate: '+1D'})

  bindEvents: ->
    @onEvent 'click', '.destroy-approver', {}, @markAsDestroyedAndHide
    @onEvent 'click', '#google-file-picker', {}, ApproveForMe.google.createFilePicker

  # Helpers
  markAsDestroyedAndHide: ->
    $this = $(this)
    approver = $this.parents(".approver")
    remove_checkbox = approver.find("input.destroy-approver-checkbox")

    remove_checkbox.prop("checked", true)
    approver.hide()
