import { Controller } from "@hotwired/stimulus"

export default class InlineEditController extends Controller {
  static targets = ["read", "edit"];

  edit() {
    this.readTargets.forEach(element => {
      element.classList.add("hidden")
    })

    this.editTargets.forEach(element => {
      element.classList.remove("hidden")
    })
  }

  cancel() {
    this.editTargets.forEach(element => {
      element.classList.add("hidden")
    })
    this.readTargets.forEach(element => {
      element.classList.remove("hidden")
    })
  }
}

