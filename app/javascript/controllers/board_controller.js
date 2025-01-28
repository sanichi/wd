import { Controller } from "@hotwired/stimulus"
import "chessboard"

export default class extends Controller {
  static values = {
    fen: String,
    url: String,
    note: { type: Boolean, default: false },
    side: { type: String, default: "white" },
  }

  connect() {
    const board = Chessboard(this.element, {
      position: this.fenValue,
      showNotation: this.noteValue,
      orientation: this.sideValue,
    });
    window.addEventListener("resize", () => {
      board.resize();
    });
  }

  visit() {
    if (this.hasUrlValue) {
      Turbo.visit(this.urlValue);
    }
  }
}
