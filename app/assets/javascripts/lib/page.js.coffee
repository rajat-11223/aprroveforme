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
    , 4000

  initCrisp: ->
    ApproveForMe.crisp.init()
