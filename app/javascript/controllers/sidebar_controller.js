import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.updateSidebarState()
        window.addEventListener('resize', this.updateSidebarState.bind(this))
    }

    disconnect() {
        window.removeEventListener('resize', this.updateSidebarState.bind(this))
    }

    toggle() {
        document.body.classList.toggle('sidebar-expanded')
    }

    updateSidebarState() {
        // Default to expanded on larger screens
        if (window.innerWidth >= 1024) {
            document.body.classList.add('sidebar-expanded')
        } else {
            document.body.classList.remove('sidebar-expanded')
        }
    }
} 