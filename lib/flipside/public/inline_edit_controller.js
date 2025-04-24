import { Controller } from "@hotwired/stimulus"

export default class InlineEditController extends Controller {
  static targets = ["value", "form"];

  connect() {
    console.log("InlineEditController connect")
  }

  edit() {
    console.log("InlineEditController edit")
    if (this.hasFormTarget) {
      console.log("InlineEditController edit")
      this.formTarget.classList.remove("hidden");
    }
    if (this.hasValueTarget) {
      this.valueTarget.classList.add("hidden");
    }
  }

  cancel() {
    console.log("InlineEditController cancel")
    if (this.hasFormTarget) {
      console.log("InlineEditController edit")
      this.formTarget.classList.add("hidden");
    }
    if (this.hasValueTarget) {
      this.valueTarget.classList.remove("hidden");
    }
  }
}

