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

  function go_forward(number) {
    while (current_move < number) {
      chess.move(moves[current_move]);
      current_move++;
    }
  }

  function go_back(number) {
    while (current_move > number) {
      chess.undo();
      current_move--;
    }
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
      if (current_move == first_move) return;
      chess.undo();
      current_move--;
      display_board();
    },

    goto_end: function() {
      if (current_move == last_move) return;
      go_forward(last_move);
      display_board();
    },

    goto_start: function() {
      if (current_move == first_move) return;
      go_back(first_move);
      display_board();
    },

    seek: function(i) {
      if (i < current_move) {
        go_back(i);
        display_board();
      } else if (i > current_move) {
        go_forward(i);
        display_board();
      }
    },

    resize: function() {
      board.resize();
    },

  };
};
