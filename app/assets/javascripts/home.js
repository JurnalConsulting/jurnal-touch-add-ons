$("#popup-delete-setting").on('show.bs.modal', function(e){
  var $this = $(e.relatedTarget);
  var setting_id = $this.data("setting-id");

  var $delete_link = $("#popup-delete-setting-btn");
  var delete_href = $delete_link.attr('href');
  var new_href = delete_href.substring(0, delete_href.lastIndexOf("/") + 1) + setting_id;
  $delete_link.attr('href',new_href);
});

$(document).on('turbolinks:load', function(){
  $('.link_get_qr').on('click', function() {
    $('#popup-qr .qr-image').attr('src', $(this).attr('data-qr-src'));
    $('#popup-qr').modal('show');
  });
});