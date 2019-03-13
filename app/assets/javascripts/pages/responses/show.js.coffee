class ApproveForMe.Pages.ResponseShow extends ApproveForMe.Page
  render: ->
    @refreshIframesEvery30Seconds()

  bindEvents: ->
    @onEvent 'click', "input[name='approver[status]']", {}, @submitForm
    @onEvent 'focus', window, {}, @refreshIframes

  # Helpers
  refreshIframesEvery30Seconds: ->
    window.setInterval @refreshIframes, 30 * 1000

  submitForm: (e) ->
    $this = $(this)

    if confirm(I18n.t("response.create.confirmation"))
      $this.parents("form").submit()

  refreshIframes: (e) ->
    log("Refresh all iframes")
    $('iframe').attr 'src', (i, val) ->
      val

