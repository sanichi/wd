$(function() {
  $('#toggle_pgn').click(function(e) {
    e.preventDefault();
    $('pre.pgn').toggle();
  });
  $('pre.pgn').hide();
});
