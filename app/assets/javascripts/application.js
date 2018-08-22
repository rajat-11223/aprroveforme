//= require jquery
//= require jquery-ui/widgets/datepicker
//= require jquery_ujs
//= require turbolinks
//= require user_voice
//= require approvals
//= require foundation


function ready() {
  if (window.foundationInitialized == true) {
    // Early exit when site has already initialized
    return;
  } else {
    window.foundationInitialized = true;
    console.log("Initialize foundation");
    $(document).foundation();
  }
}

document.addEventListener("turbolinks:load", ready);
$( document ).ready(ready);
