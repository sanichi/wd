var Game = function(pgn, id) {

  var moves = [];
  var current_move = 0;
  var first_move = 0;
  var last_move = 0;

  var chess = new Chess();
  var ok = chess.load_pgn(pgn, { sloppy: true });
  ok ? get_moves() : chess.clear();

  var board = Chessboard(id, {
    showNotation: false,
    position: chess.fen(),
  });

  function get_moves()
  {
    while (true) {
      var move = chess.undo();
      if (move == null)
      {
        break;
      }
      else
      {
          moves.unshift(move);
      }
    }
    last_move = moves.length;
  }

  function display_board() {
    board.position(chess.fen());
  }

  return {

    play_move: function() {
      if (current_move == last_move) return;
      chess.move(moves[current_move]);
      current_move++;
      display_board();
    },

    take_back: function() {
      if (current_move == 0) return;
      chess.undo();
      current_move--;
      display_board();
    },

    goto_end: function() {
      while (current_move < last_move) {
        chess.move(moves[current_move]);
        current_move++;
      }
      display_board();
    },

    goto_start: function() {
      while (current_move > first_move) {
        chess.undo();
        current_move--;
      }
      display_board();
    },

    resize: function() {
      board.resize();
    }

  };
};
