class ApproveForMe.Pages.ResponseShow extends ApproveForMe.Page
  render: ->

  bindEvents: ->
    @onEvent 'click', "input[name='approver[status]']", {}, @submitForm

  # Helpers
  submitForm: (e) ->
    $this = $(this)

    if confirm(I18n.t("response.create.confirmation"))
      $this.parents("form").submit()
