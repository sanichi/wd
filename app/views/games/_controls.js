$(function() {
  $('#toggle_pgn').click(function(e) {
    e.preventDefault();
    $('pre.pgn').toggle();
  });
  $('pre.pgn').hide();
  $('.controls .btn').click(function(e) {
    switch($(this).data('btn')) {
      case '<<':
        goto_start();
        break;
      case '<':
        take_back();
        break;
      case '>':
        play_move();
        break;
      case '>>':
        goto_end();
        break;
    }
  });
});
