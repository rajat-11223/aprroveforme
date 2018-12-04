class ApproveForMe.Pages.ResponsesShow extends ApproveForMe.Page
  render: ->

  bindEvents: ->
    @onEvent 'change', "input[name='approver[status]']", {}, @submitForm

  # Helpers
  submitForm: (e) ->
    $this = $(this)

    if confirm(I18n.t("response.create.confirmation"))
      $this.parents("form").submit()
