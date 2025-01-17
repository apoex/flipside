import { Controller } from "@hotwired/stimulus";

export default class ToggleController extends Controller {
  static targets = ["switch"];
  static values = {
    url: String,
    enabled: Boolean
  }

  async switch(event) {
    try {
      const data = {enable: !this.enabledValue}
      const response = await fetch(this.urlValue, {
        method: "PUT",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(data)
      })

      if (response.ok) {
        location.reload()
      } else {
        const text = await response.text()
        console.error("Failed to update:", text)
      }
    } catch (error) {
      console.error("Error during the PUT request:", error)
    }
  }
}
