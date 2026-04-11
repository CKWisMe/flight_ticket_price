import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["requestStatus", "statuses"]
  static values = { url: String }

  connect() {
    if (!this.hasUrlValue) return

    this.poll()
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  async poll() {
    try {
      const response = await fetch(this.urlValue, { headers: { Accept: "application/json" } })
      if (!response.ok) return

      const payload = await response.json()
      if (this.hasRequestStatusTarget) {
        this.requestStatusTarget.textContent = payload.statusLabel || payload.status
      }

      if (this.hasStatusesTarget) {
        this.statusesTarget.innerHTML = payload.sourceStatuses.map((status) => `
          <div class="status-card">
            <strong>${status.sourceKey}</strong>
            <span class="status-badge">${status.statusLabel || status.status}</span>
          </div>
        `).join("")
      }

      if (["queued", "running", "partially_completed"].includes(payload.status)) {
        this.timeout = setTimeout(() => this.poll(), 5000)
      }
    } catch (_error) {
      this.timeout = setTimeout(() => this.poll(), 10000)
    }
  }
}
