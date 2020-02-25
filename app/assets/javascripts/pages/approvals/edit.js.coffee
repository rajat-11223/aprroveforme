class ApproveForMe.Pages.ApprovalEdit extends ApproveForMe.Page
  render: ->
    ApproveForMe.date_and_time_picker.init("#datepicker", "date")
    ApproveForMe.date_and_time_picker.init("#datetimepicker", "datetime")

  bindEvents: ->
    @onEvent 'click', '.destroy-approver', {}, @markAsDestroyedAndHide
    @onEvent 'click', '#google-file-picker', {}, ApproveForMe.google.createFilePicker
    @onEvent 'submit', 'form', {}, ApproveForMe.ApprovalValidator.submit

  # Helpers
  markAsDestroyedAndHide: ->
    $this = $(this)
    approver = $this.parents(".approver")
    remove_checkbox = approver.find("input.destroy-approver-checkbox")

    remove_checkbox.prop("checked", true)
    approver.hide()
