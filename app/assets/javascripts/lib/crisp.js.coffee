ApproveForMe.crisp =
  init: ->
    window.$crisp = []
    window.CRISP_WEBSITE_ID = "cc1fee05-4760-4e64-8ceb-8a052cd24e6e"

    do ->
      d = document
      s = d.createElement('script')
      s.src = 'https://client.crisp.chat/l.js'
      s.async = 1
      d.getElementsByTagName('head')[0].appendChild(s)

      $crisp.push(["safe", true]) # Disable Crisp Warnings

  open: ->
    return unless $crisp
    $crisp.push(["do", "chat:open"])

  setUserDetails: (user) ->
    return unless $crisp
    log("Set User Deatils")

    if user.name
      $crisp.push(["set", "user:nickname", user.name]);

    if user.email
      $crisp.push(["set", "user:email", user.email]);

    if user.picture
      $crisp.push(["set", "user:avatar", user.picture]);

  askForMeeting: ->
    return if @shownBefore('earnFreeYear')

    @markShown('earnFreeYear')
    @pushMessage("Want to earn a free year of ApproveForMe Unlimited?")
    @pushMessage("Schedule a 15 minute call with me at https://calendly.com/ricky-chilcott/approve-for-me-15-minute and I'll hook you up.")

  # Helpers
  pushMessage: (msg) ->
    return unless $crisp
    $crisp.push(["do", "message:show", ["text", msg]])

  shownBefore: (key) ->
    Cookies.get(key) == 'true'

  markShown: (key) ->
    Cookies.set(key, true, { expires: 7 })
