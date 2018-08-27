document.addEventListener "turbolinks:load", ->
  # Include the UserVoice JavaScript SDK (only needed once on a page)
  UserVoice = window.UserVoice or []
  do ->
    uv = document.createElement('script')
    uv.type = 'text/javascript'
    uv.async = true
    uv.src = '//widget.uservoice.com/H6yaFyp6VZJrQqdY8RxGg.js'
    s = document.getElementsByTagName('script')[0]
    s.parentNode.insertBefore uv, s
    return
  #
  # UserVoice Javascript SDK developer documentation: https://www.uservoice.com/o/javascript-sdk
  #
  # Set colors
  UserVoice.push [
    'set'
    {
      accent_color: '#808283'
      trigger_color: 'white'
      trigger_background_color: 'rgba(46, 49, 51, 0.6)'
    }
  ]
  # Identify the user and pass traits To enable, replace sample data with actual user traits and uncomment the line
  # UserVoice.push [
  #   'identify'
  #   {}
  # ]

  # Add default trigger to the bottom-right corner of the window: AK 4.11.18 Updated position
  UserVoice.push [
    'addTrigger'
    {
      mode: 'satisfaction'
      trigger_position: 'bottom-left'
    }
  ]

  # Or, use your own custom trigger: UserVoice.push(['addTrigger', '#id', { mode: 'satisfaction' }]); Autoprompt for Satisfaction and SmartVote (only displayed under certain conditions)
  UserVoice.push [
    'autoprompt'
    {}
  ]
