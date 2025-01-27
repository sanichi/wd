import { Controller } from "@hotwired/stimulus"
import "chessboard"

export default class extends Controller {
  static values = {
    fen: String,
    note: String,
    side: String
  }

  connect() {
    Chessboard(this.element, {
      showNotation: this.noteValue == "T",
      position: this.fenValue,
      orientation: this.sideValue,
    });
  }
}
