//= require jquery
//= require jquery-ui/widgets/datepicker
//= require jquery_ujs
//= require turbolinks
//= require foundation
//= require js.cookie
//= require jstz
//= require browser_timezone_rails/set_time_zone
//= require user_voice
//= require approvals

function initializeFoundation() {
  $(function(){ $(document).foundation(); });
}

document.addEventListener("turbolinks:load", initializeFoundation);
