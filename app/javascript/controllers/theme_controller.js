import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["themeSelect"]

  connect() {
    this.updateTheme(this.themeSelectTarget.value)
  }

  change(event) {
    this.updateTheme(event.target.value)
  }

  updateTheme(theme) {
    if (theme === "dark") {
      document.documentElement.classList.add("dark-theme")
      document.documentElement.classList.remove("light-theme")
    } else if (theme === "light") {
      document.documentElement.classList.add("light-theme")
      document.documentElement.classList.remove("dark-theme")
    } else if (theme === "system") {
      // Check system preference
      if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.classList.add("dark-theme")
        document.documentElement.classList.remove("light-theme")
      } else {
        document.documentElement.classList.add("light-theme")
        document.documentElement.classList.remove("dark-theme")
      }
      
      // Listen for changes to the prefers-color-scheme media query
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
        if (this.themeSelectTarget.value === "system") {
          if (e.matches) {
            document.documentElement.classList.add("dark-theme")
            document.documentElement.classList.remove("light-theme")
          } else {
            document.documentElement.classList.add("light-theme")
            document.documentElement.classList.remove("dark-theme")
          }
        }
      })
    }
  }
} 