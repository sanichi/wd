import { Controller } from "@hotwired/stimulus"
import "chessboard"

export default class extends Controller {
  static values = {
    fen: String,
    url: String,
    note: { type: String, default: "F" },
    side: { type: String, default: "white" },
  }

  connect() {
    Chessboard(this.element, {
      position: this.fenValue,
      showNotation: this.noteValue == "T",
      orientation: this.sideValue,
    });
  }

  visit() {
    if (this.hasUrlValue) {
      Turbo.visit(this.urlValue);
    }
  }
}
