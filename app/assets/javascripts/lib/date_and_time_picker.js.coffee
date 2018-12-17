ApproveForMe.date_and_time_picker =
  init: (selector, type) ->
    @removeOldPicker(selector)
    flatpickr(selector, @settings()[type])

  settings: ->
    base_settings = {
      minDate: "today",
      dateFormat: "Z",
      altInput: true,
    }

    {
      "date": Object.assign({
        enableTible: false,
        altFormat: "F j, Y \\a\\t 12:00 \\P\\M",
      }, base_settings),
      "datetime": Object.assign({
        enableTime: true,
        altFormat: "F j, Y \\a\\t h:i K",
      }, base_settings)
    }

  removeOldPicker: (selector) ->
    $(selector).siblings("input").remove()
