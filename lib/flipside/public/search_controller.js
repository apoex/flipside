import { Controller } from "@hotwired/stimulus"

export default class SearchController extends Controller {
  static targets = ["input", "value", "param", "results", "addButton"]
  static values = {url: String}

  timer = null

  async search(event) {
    clearTimeout(this.timer)
    this.timer = setTimeout(this.fetchResults.bind(this), 400)
  }

  async fetchResults() {
    this.clearResults()
    try {
      const url = this.getUrl()
      if (!url) return

      const response = await fetch(url)
      if (!response.ok) {
        console.error("Failed to fetch search results")
        return
      }

      const html = await response.text()
      this.updateResults(html)
    } catch (error) {
      console.error("Error fetching search results:", error)
    }
  }

  select(event) {
    // If the event target has no value, then we assume we didn't find any results
    if (!event.target.value) {
      this.clearResults()
      if (this.hasAddButtonTarget) this.disableAddButton()
      return
    }

    if (this.hasInputTarget) {
      this.inputTarget.value = event.target.textContent.trim()
    }

    if (this.hasValueTarget) {
      this.valueTarget.value = event.target.value
      if (this.hasAddButtonTarget) this.enabledAddButton()
    }

    this.clearResults()
  }

  getUrl() {
    if (!this.hasInputTarget) return

    const query = this.inputTarget.value.trim()
    if (query.length === 0) return

    const params = new URLSearchParams()
    params.append("q", encodeURIComponent(query))

    this.paramTargets.forEach(paramTarget => {
      const key = paramTarget.dataset.searchParam
      const value = paramTarget.value
      params.append(key, value)
    })

    return `${this.urlValue}?${params.toString()}`
  }

  updateResults(html) {
    if (!this.hasResultsTarget) return

    this.resultsTarget.innerHTML = html
    this.resultsTarget.classList.add("block")
  }

  clearResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ""
    }
  }

  clearAll() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }

    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ""
    }

    if (this.hasAddButtonTarget) this.disableAddButton()
  }

  enabledAddButton() {
    this.addButtonTarget.classList.remove("bg-gray-600")
    this.addButtonTarget.classList.add("bg-gray-300")
    this.addButtonTarget.classList.add("hover:bg-gray-400")
    this.addButtonTarget.disabled = false
  }

  disableAddButton() {
    this.addButtonTarget.classList.add("bg-gray-600")
    this.addButtonTarget.classList.remove("bg-gray-300")
    this.addButtonTarget.classList.remove("hover:bg-gray-400")
    this.addButtonTarget.disabled = true
  }
}

