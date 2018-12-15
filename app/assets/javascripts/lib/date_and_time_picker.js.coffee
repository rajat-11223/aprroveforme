ApproveForMe.date_and_time_picker =
  init: (selector, type) ->
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
        altFormat: "F j, Y",
      }, base_settings),
      "datetime": Object.assign({
        enableTime: true,
        altFormat: "F j, Y \\a\\t h:i K",
      }, base_settings)
    }