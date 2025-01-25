import "jquery"
import Rails from "@rails/ujs"
Rails.start();

$(function () {
  // Auto-submit on change.
  $('form .auto-submit').change(function () {
    var form = $(this).parents('form');
    form.attr('data-remote') == "true" ? Rails.fire(form[0], 'submit') : form.submit();
  });
});
