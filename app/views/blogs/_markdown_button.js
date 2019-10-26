$(function() {
  $('#toggle_markdown').click(function(e) {
    e.preventDefault();
    $('.markdown').toggle();
  });
  $('.markdown').hide();
});
