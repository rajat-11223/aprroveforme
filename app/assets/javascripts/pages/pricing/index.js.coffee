class ApproveForMe.Pages.PricingIndex extends ApproveForMe.Page
  render: ->
    setTimeout ->
      ApproveForMe.crisp.askForMeeting()
    , 5000

  bindEvents: ->
    @onEvent 'click', '.continue-change', {}, @continuePermission
    @onEvent 'click', "[data-switchable]", {}, @switchable
    @onEvent 'click', "[data-switchable-id='pricing-toggle']", {}, @pricingIntervalChanged

  continuePermission: ->
    name = $(this).data('name')
    interval = $(this).data('interval')
    type = $(this).data('type')

    $.ajax
      url: '/subscription/continue_permission'
      type: 'GET'
      data: {name: name, interval: interval, type: type}
      success: (data) ->
        $("#permissionModal").html(data)

        modal = new Foundation.Reveal($("#confirmPlanChange"))
        modal.open()
      error: (data) ->
        log("ERROR in #continuePermission")
        log(data)

  switchable: (e) ->
    target = $(e.target)

    if target.data("switchable") == undefined
      target = target.parent()

    switch_sibblings = target.data("switchable-id")
    all_switches = $("[data-switchable-id='#{switch_sibblings}']")

    all_switches.toggleClass("tw-switch-off")
    all_switches.toggleClass("tw-switch-on")

  pricingIntervalChanged: (e) ->
    target = $(e.target)
    if target.data("switchable") == undefined
      target = target.parent()

    switchOn = target.hasClass("tw-switch-on")

    if switchOn
      $("#pricing-table").find(".yearly-details").removeClass("tw-hidden")
      $("#pricing-table").find(".monthly-details").addClass("tw-hidden")
    else
      $("#pricing-table").find(".monthly-details").removeClass("tw-hidden")
      $("#pricing-table").find(".yearly-details").addClass("tw-hidden")
