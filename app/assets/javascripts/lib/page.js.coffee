class ApproveForMe.Page
  constructor: ->
    @defaultRender()
    @defaultBindEvents()

  render: ->
    # Default implementation
    null

  bindEvents: ->
    # Default implementation
    null

  defaultRender: ->
    @setupFoundation()
    @closeAlerts()
    @closeCallouts()
    @initCrisp()
    @finishFormProgressBar()
    @watchGonVars()

    log("Rendering #{this.constructor.name}")
    @render()
    @close()

  defaultBindEvents: ->
    log("Binding Events #{this.constructor.name}")
    @bindEvents()
    @onEvent 'submit', 'form', {}, @startFormProgressBar
    @onEvent 'click', '[data-fadeable-handle]', {}, @fadeOutParent

  onEvent: (event, selector, data, handler) ->
    if selector == window
      window.addEventListener(event, handler, false)
    else
      $('body').on(event, selector, data, handler)

  close: ->
    $('body').off()

  # Helpers
  setupFoundation: ->
    $(document).foundation()

  watchGonVars: ->
    interval = 5 * 60 * 1000 # (5 minutes)

    gon.watch 'googleUserToken', {interval: interval}, (val) ->
      gon.googleUserToken = val

    gon.watch 'googleUserTokenExpiresAt', {interval: interval}, (val) ->
      gon.googleUserTokenExpiresAt = val

  closeAlerts: ->
    setTimeout ->
      $('.alerts .alert').fadeOut()
    , 5000

  closeCallouts: ->
    setTimeout ->
      $('.callout').trigger('close')
    , 13000

  initCrisp: ->
    ApproveForMe.crisp.init()
    ApproveForMe.crisp.setUserDetails(gon.global.user)

  startFormProgressBar: ->
    if $(this).data("remote") != true
      return

    if !Turbolinks.supported
      return

    Turbolinks.controller.adapter.progressBar.setValue(0)
    Turbolinks.controller.adapter.progressBar.show()

  fadeOutParent: (e) ->
    $(e.target).parents("[data-fadeable]").fadeOut()

  finishFormProgressBar: ->
    Turbolinks.controller.adapter.progressBar.setValue(10000)
    Turbolinks.controller.adapter.progressBar.hide()
