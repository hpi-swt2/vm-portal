// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require popper
//= require bootstrap
//= require doughnut_chart
//= require prevent_anchor_reload
//= require select2
//= require clipboard
// Contains code for initializing and configuring datatables
// app/assets/javascripts/datatables.js
//= require datatables
//= require_tree .

// With Turbolinks, jQuery $(document).ready events fire only in response
// to the initial page load, not after any subsequent page changes
// https://github.com/turbolinks/turbolinks#observing-navigation-events
document.addEventListener("turbolinks:load", function() {
  // Initialize 'Select2', jQuery based replacement for select boxes
  // https://github.com/argerim/select2-rails#include-select2-rails-stylesheet-assets
  $('.selecttwo').select2({ theme: "bootstrap" });
  // Initialize Boostrap tooltips for all elements having data-toggle
  // attribute set to 'tooltip'. Uses the title attr as tooltip.
  // https://getbootstrap.com/docs/4.0/components/tooltips
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).ready(function(){
  // Initialize all copy to clipboard buttons
  // https://github.com/sadiqmmm/clipboard-rails#usage
  var clipboard = new Clipboard('.clipboard-btn');
  // Show a success tooltip notification using Bootstrap tooltips
  clipboard.on('success', function (e) {
    var original_title = $(e.trigger).attr('title');
    // https://getbootstrap.com/docs/4.0/components/tooltips/#tooltipoptions
    $(e.trigger).attr('title', 'Copied!').tooltip('show');
    // After a delay, destroy the success tooltip and restore original
    setTimeout(function () {
      $(e.trigger).attr('title', original_title).tooltip('dispose') 
    }, 700)
  });
});
