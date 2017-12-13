// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs 
//= require bootstrap-sprockets
//= require select2
//= require clipboard
//= require settings
//= require turbolinks

function toggleSpinner(value) {
  $('#spinner-group, #spinner-backdrop').toggleClass('hidden',value);
}

$(document).on('turbolinks:request-start', function() {
  toggleSpinner(false);
});

$(document).on('turbolinks:request-end', function() {
  toggleSpinner(true);
});

$(document).on('turbolinks:load', function(){
  $('[data-toggle="tooltip"]').tooltip({ container: 'body' });

  $('.select2-wrapper select').select2();

  $('.select2-tags').select2({
    tags: false
  });

  // Tooltip

  $('.clipboard-btn').tooltip({
    trigger: 'click',
    placement: 'bottom'
  });

  function setTooltip(btn, message) {
    $(btn).tooltip('hide')
      .attr('data-original-title', message)
      .tooltip('show');
  }

  function hideTooltip(btn) {
    setTimeout(function() {
      $(btn).tooltip('hide');
    }, 1500);
  }

  // Clipboard

  var clipboard = new Clipboard('.clipboard-btn');

  clipboard.on('success', function(e) {
    setTooltip(e.trigger, 'Copied!');
    hideTooltip(e.trigger);
  });

  clipboard.on('error', function(e) {
    setTooltip(e.trigger, 'Failed!');
    hideTooltip(e.trigger);
  });
});