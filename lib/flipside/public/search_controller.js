import { Controller } from "@hotwired/stimulus"

export default class SearchController extends Controller {
  static targets = ["input", "value", "param", "results"]
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
      console.log("Response:", response)
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
    if (this.hasInputTarget) {
      this.inputTarget.value = event.target.textContent.trim()
    }

    if (this.hasValueTarget) {
      this.valueTarget.value = event.target.value
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
  }
}

