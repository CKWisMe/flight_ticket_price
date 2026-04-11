import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tripType", "legsSection", "legsList", "template", "validation"]

  connect() {
    this.tripTypeChanged()
  }

  tripTypeChanged() {
    const multiCity = this.tripTypeTarget.value === "multi_city"
    this.legsSectionTarget.classList.toggle("is-hidden", !multiCity)

    if (multiCity && this.legsListTarget.children.length < 2) {
      this.addLeg()
      this.addLeg()
    }

    this.validate()
  }

  addLeg() {
    if (this.legsListTarget.children.length >= 4) {
      this.validationTarget.textContent = "Multi-city trips support up to 4 legs."
      return
    }

    const fragment = this.templateTarget.content.cloneNode(true)
    this.legsListTarget.appendChild(fragment)
    this.renumberLegs()
    this.validate()
  }

  validate() {
    const tripType = this.tripTypeTarget.value
    if (tripType !== "multi_city") {
      this.validationTarget.textContent = ""
      return
    }

    const legs = this.legsListTarget.querySelectorAll(".leg-row")
    if (legs.length < 2) {
      this.validationTarget.textContent = "Multi-city trips require at least 2 legs."
      return
    }

    this.validationTarget.textContent = ""
  }

  renumberLegs() {
    this.legsListTarget.querySelectorAll(".leg-row").forEach((row, index) => {
      const input = row.querySelector('input[name*="[position]"]')
      if (input) input.value = index + 1
    })
  }
}
