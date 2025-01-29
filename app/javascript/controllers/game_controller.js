import { Controller } from "@hotwired/stimulus"
import { Chess } from "chess"
import "chessboard"

export default class extends Controller {
  static targets = [ "pgn", "board", "moves", "study" ]
  static values = {
    move: { type: Number, default: 0 },
    side: String,
    study: Boolean,
  }

  connect() {
    window.chess = new Chess();
    try {
      chess.loadPgn(this.pgnTarget.textContent);
    } catch (error) {
      alert(error);
      chess.clear();
    }

    // Play the game backwards to get all the moves.
    window.moves = [];
    while (true) {
      const move = chess.undo();
      if (move == null) {
        break;
      } else {
        moves.unshift(move);
      }
    }
    window.last_move = moves.length;
    window.current_move = 0;
    window.first_move = 0;

    // Display the position.
    window.board = Chessboard(this.boardTarget, {
      showNotation: false,
      position: chess.fen(),
      orientation: this.sideValue,
    });

    // Hide the moves if this is a study.
    if (this.studyValue) this.movesTarget.hidden = true;

    // Start at custom position.
    if (this.moveValue > 0 && this.moveValue <= last_move) this.go_move(this.moveValue)
  }

  // Actions.

  move()   { this.go_forward(current_move + 1) }
  undo()   { this.go_back(current_move - 1) }
  start()  { this.go_back(first_move) }
  end()    { this.go_forward(last_move) }
  show()   { this.movesTarget.hidden = false; this.studyTarget.hidden = true; }
  flip()   { board.flip() }
  resize() { board.resize() }

  seek({ params: { n } }) { this.go_move(n) }

  keydown(e) {
    switch (e.keyCode) {
      case 39: // right arrow
        this.move();
        //highlight_current();
        break;
      case 37: // left arrow
        this.undo();
        //highlight_current();
        break;
      case 69: // 'e' for end
        this.end();
        //highlight_current();
        break;
      case 83: // 's' for start
        this.start();
        //highlight_current();
        break;
      case 79: // 'o' meaning rotate board
        this.flip();
        break;
      case 77: // 'm' meaning show moves
        this.show();
        break;
    }
  }

  // Utilities.

  go_forward(n) {
    if (n > last_move) return;
    while (current_move < n) {
      chess.move(moves[current_move]);
      current_move++;
    }
    board.position(chess.fen());
    this.highlight_current();
  }

  go_back(n) {
    if (n < first_move) return;
    while (current_move > n) {
      chess.undo();
      current_move--;
    }
    board.position(chess.fen());
    this.highlight_current();
  }

  go_move(n) {
    if (n < current_move) {
      this.go_back(n);
    } else if (n > current_move) {
      this.go_forward(n);
    }
  }

  highlight_current() {
    $('.moves .move').removeClass('current-move');
    if (current_move > 0) {
      $('.moves .move').each(function(i) {
        if (current_move == i + 1) {
          $(this).addClass('current-move');
        }
      });
    }
  }

  disconnect() {
    window.chess = undefined;
    window.board = undefined;
    window.moves = undefined;
    window.last_move = undefined;
    window.current_move = undefined;
    window.first_move = undefined;
  }
}
