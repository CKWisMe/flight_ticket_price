import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden", "list", "status"]
  static values = {
    endpoint: String
  }

  connect() {
    this.activeIndex = -1
    this.matches = []
    this.abortController = null
    this.debounceTimer = null
    this.listTarget.classList.add("is-hidden")
  }

  disconnect() {
    this.abortPendingRequest()
    clearTimeout(this.debounceTimer)
  }

  inputChanged() {
    const query = this.inputTarget.value.trim()
    this.clearSelection()

    if (query.length < 1) {
      this.hideList()
      this.statusTarget.textContent = ""
      return
    }

    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => this.fetchMatches(query), 150)
  }

  keydown(event) {
    if (this.matches.length === 0) return

    switch (event.key) {
    case "ArrowDown":
      event.preventDefault()
      this.move(1)
      break
    case "ArrowUp":
      event.preventDefault()
      this.move(-1)
      break
    case "Enter":
      if (this.activeIndex >= 0) {
        event.preventDefault()
        this.select(this.matches[this.activeIndex])
      }
      break
    case "Escape":
      this.hideList()
      break
    }
  }

  blur() {
    setTimeout(() => this.hideList(), 150)
  }

  choose(event) {
    const index = Number(event.currentTarget.dataset.index)
    this.select(this.matches[index])
  }

  beforeSubmit(event) {
    if (this.inputTarget.value.trim().length > 0 && this.hiddenTarget.value.trim().length === 0) {
      event.preventDefault()
      this.statusTarget.textContent = "Select an airport from suggestions before submitting."
      this.statusTarget.dataset.state = "error"
      this.inputTarget.setAttribute("aria-invalid", "true")
    }
  }

  async fetchMatches(query) {
    this.abortPendingRequest()
    this.abortController = new AbortController()

    try {
      const url = new URL(this.endpointValue, window.location.origin)
      url.searchParams.set("query", query)

      const response = await fetch(url, {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal
      })

      if (!response.ok) throw new Error("Lookup request failed")

      const payload = await response.json()
      this.matches = payload.matches || []
      this.activeIndex = -1
      this.renderMatches()
    } catch (error) {
      if (error.name === "AbortError") return

      this.matches = []
      this.hideList()
      this.statusTarget.textContent = "Airport lookup failed. Please try again."
      this.statusTarget.dataset.state = "error"
    }
  }

  renderMatches() {
    this.listTarget.innerHTML = ""

    if (this.matches.length === 0) {
      this.hideList()
      this.statusTarget.textContent = "No airports matched your query."
      this.statusTarget.dataset.state = "empty"
      return
    }

    this.statusTarget.textContent = `${this.matches.length} airport suggestions found.`
    this.statusTarget.dataset.state = "info"
    this.inputTarget.setAttribute("aria-expanded", "true")
    this.listTarget.classList.remove("is-hidden")

    this.matches.forEach((match, index) => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "airport-lookup-option"
      button.dataset.index = index
      button.dataset.action = "mousedown->airport-lookup#choose"
      button.setAttribute("role", "option")
      button.innerHTML = `
        <span class="airport-lookup-option__title">${match.displayName}</span>
        <span class="airport-lookup-option__meta">${match.airportCode} - ${match.cityName} - ${match.countryName}</span>
      `
      this.listTarget.appendChild(button)
    })
  }

  move(offset) {
    this.activeIndex = (this.activeIndex + offset + this.matches.length) % this.matches.length

    this.listTarget.querySelectorAll(".airport-lookup-option").forEach((node, index) => {
      node.classList.toggle("is-active", index === this.activeIndex)
    })
  }

  select(match) {
    this.hiddenTarget.value = match.airportCode
    this.inputTarget.value = match.displayName
    this.inputTarget.setAttribute("aria-invalid", "false")
    this.statusTarget.textContent = `Selected ${match.displayName}.`
    this.statusTarget.dataset.state = "success"
    this.hideList()
  }

  clearSelection() {
    this.hiddenTarget.value = ""
    this.inputTarget.setAttribute("aria-invalid", "false")
    if (this.statusTarget.dataset.state === "success") {
      this.statusTarget.textContent = ""
      this.statusTarget.dataset.state = ""
    }
  }

  hideList() {
    this.listTarget.classList.add("is-hidden")
    this.inputTarget.setAttribute("aria-expanded", "false")
  }

  abortPendingRequest() {
    if (this.abortController) {
      this.abortController.abort()
      this.abortController = null
    }
  }
}
