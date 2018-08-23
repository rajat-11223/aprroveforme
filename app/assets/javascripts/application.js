//= require jquery
//= require jquery-ui/widgets/datepicker
//= require jquery_ujs
//= require turbolinks
//= require foundation
//= require js.cookie
//= require jstz
//= require browser_timezone_rails/set_time_zone
//= require user_voice
//= require initialize_app
//= require approval_google_picker
//= require approvals

ApproveForMe.initializeFoundation = function() {
  $(function(){ $(document).foundation(); });
}

ApproveForMe.closeCallouts = function() {
  setTimeout(function() { $('.callout').trigger('close') }, 4000);
}

document.addEventListener("turbolinks:load", ApproveForMe.initializeFoundation);
document.addEventListener("turbolinks:load", ApproveForMe.closeCallouts);
