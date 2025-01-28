import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    class: String
  }

  connect() {
    this.toggle();
  }

  toggle() {
    if (this.hasClassValue) {
      const els = document.getElementsByClassName(this.classValue);
      [...els].forEach((el) => {
        el.hidden = !el.hidden;
        if (!el.hidden) {
          el.scrollIntoView({ behavior: "smooth", block: "end" });
        }
      });
    }
  }
}
