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
    @closeCallouts()
    @initCrisp()

    log("Rendering #{this.constructor.name}")
    @render()
    @close()

  defaultBindEvents: ->
    log("Binding Events #{this.constructor.name}")
    @bindEvents()
    @onEvent 'submit', 'form', {}, @startFormProgressBar
    @onEvent 'turbolinks:load', document, {}, @finishFormProgressBar

  onEvent: (event, selector, data, handler) ->
    $('body').on(event, selector, data, handler)

  close: ->
    $('body').off()

  # Helpers
  setupFoundation: ->
    $(document).foundation()

  closeCallouts: ->
    setTimeout ->
      $('.callout').trigger('close')
    , 10000

  initCrisp: ->
    ApproveForMe.crisp.init()

  startFormProgressBar: ->
    if $(this).data("remote") != true
      return

    if !Turbolinks.supported
      return

    Turbolinks.controller.adapter.progressBar.setValue(0)
    Turbolinks.controller.adapter.progressBar.show()

  finishFormProgressBar: ->
    Turbolinks.controller.adapter.progressBar.setValue(10000)
    Turbolinks.controller.adapter.progressBar.hide()
