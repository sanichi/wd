import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    class: String,
    id: String
  }

  connect() {
    this.toggle();
  }

  toggle() {
    if (this.hasClassValue) {
      const els = document.getElementsByClassName(this.classValue);
      [...els].forEach((el) => { this.show(el) });
    }
    if (this.hasIdValue) {
      this.show(document.getElementById(this.idValue));
    }
  }

  show(el) {
    if (el !== null) {
      el.hidden = !el.hidden;
      if (!el.hidden) {
        el.scrollIntoView({ behavior: "smooth", block: "end" });
      }
    }
  }
}
