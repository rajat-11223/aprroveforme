#= require modernizr
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require foundation
#= require js.cookie
#= require jstz
#= require browser_timezone_rails/set_time_zone
#= require i18n
#= require i18n/translations
#= require flatpickr
#= require approve_for_me
#= require_tree ./lib
#= require_tree ./pages

ready = ->
  ApproveForMe.init()
  ApproveForMe.setPage()

logEvent = (name) ->
  $(document).on name, (e, data) ->
    log(name, data)

window.log = (attrs...) ->
  if window.RAILS_ENV != "production"
    console.log(attrs...)

logEvent("turbolinks:before-change")
logEvent("turbolinks:request-end")
logEvent("turbolinks:load")
logEvent("ajaxSend")
logEvent("ajaxComplete")

# $(document).on 'ready', ready
$(document).on 'turbolinks:load', ready
