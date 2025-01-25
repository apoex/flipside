import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"];

  open() {
    if (this.hasDialogTarget) {
      this.dialogTarget.classList.remove("hidden");
      this.dialogTarget.showModal()
    }
  }

  close() {
    if (this.hasDialogTarget) {
      this.dialogTarget.classList.add("hidden");
      this.dialogTarget.close()
    }
  }
}

