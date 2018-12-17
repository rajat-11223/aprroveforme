class ApproveForMe.Pages.PricingIndex extends ApproveForMe.Page
  render: ->
    setTimeout ->
      ApproveForMe.crisp.askForMeeting()
    , 5000

  bindEvents: ->
    @onEvent 'click', '.continue-change', {}, @continuePermission
    @onEvent 'change', '#pricingIntervalSwitch', {}, @pricingIntervalChanged

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

  pricingIntervalChanged: (e) ->
    target = $(e.target)
    yearlyPricing = target.prop('checked')
    if yearlyPricing == true
      $(".pricing-table").find(".yearly-details").removeClass("hide")
      $(".pricing-table").find(".monthly-details").addClass("hide")
    else
      $(".pricing-table").find(".monthly-details").removeClass("hide")
      $(".pricing-table").find(".yearly-details").addClass("hide")
