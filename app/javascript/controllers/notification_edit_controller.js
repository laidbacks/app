import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification-edit"
export default class extends Controller {
  static targets = ["form", "loading", "errorContainer", "successContainer", "titleInput", "bodyInput", "typeInput"]
  static values = { id: String }

  connect() {
    console.log("Notification edit controller connected")
    
    // Get CSRF token for API requests
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    // Load notification details
    this.loadNotification()
  }

  async loadNotification() {
    if (!this.idValue) return
    
    try {
      this.showLoading()
      
      const response = await fetch(`/api/v1/notifications/${this.idValue}`)
      
      if (response.ok) {
        const notification = await response.json()
        this.populateForm(notification)
      } else {
        this.showErrors(['Failed to load notification details'])
      }
    } catch (error) {
      console.error('Error loading notification:', error)
      this.showErrors(['An unexpected error occurred'])
    } finally {
      this.hideLoading()
    }
  }

  populateForm(notification) {
    if (this.hasTitleInputTarget) this.titleInputTarget.value = notification.title
    if (this.hasBodyInputTarget) this.bodyInputTarget.value = notification.body
    if (this.hasTypeInputTarget) this.typeInputTarget.value = notification.notification_type
    
    // Show the form
    this.formTarget.classList.remove('hidden')
  }

  async updateNotification(event) {
    event.preventDefault()
    
    if (!this.idValue) return
    
    const jsonData = {
      notification: {
        title: this.titleInputTarget.value,
        body: this.bodyInputTarget.value,
        notification_type: this.typeInputTarget.value
      }
    }
    
    try {
      const response = await fetch(`/api/v1/notifications/${this.idValue}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: JSON.stringify(jsonData)
      })
      
      if (response.ok) {
        this.showSuccess('Notification updated successfully!')
        
        // Redirect to notifications list after a short delay
        setTimeout(() => {
          window.location.href = '/notifications'
        }, 1500)
      } else {
        const errorData = await response.json()
        this.showErrors(errorData.errors || ['Failed to update notification'])
      }
    } catch (error) {
      console.error('Error updating notification:', error)
      this.showErrors(['An unexpected error occurred'])
    }
  }

  cancelEdit() {
    // Navigate back to notifications list
    window.location.href = '/notifications'
  }
  
  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
    
    if (this.hasFormTarget) {
      this.formTarget.classList.add('hidden')
    }
  }
  
  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }
  }
  
  showErrors(errors) {
    if (!this.hasErrorContainerTarget) return
    
    this.errorContainerTarget.innerHTML = ''
    this.errorContainerTarget.classList.remove('hidden')
    
    errors.forEach(error => {
      const errorElement = document.createElement('div')
      errorElement.textContent = error
      errorElement.className = 'error-message'
      this.errorContainerTarget.appendChild(errorElement)
    })
    
    // Hide after 5 seconds
    setTimeout(() => {
      this.errorContainerTarget.classList.add('hidden')
    }, 5000)
  }
  
  showSuccess(message) {
    if (!this.hasSuccessContainerTarget) return
    
    this.successContainerTarget.innerHTML = ''
    this.successContainerTarget.classList.remove('hidden')
    
    const successElement = document.createElement('div')
    successElement.textContent = message
    successElement.className = 'success-message'
    this.successContainerTarget.appendChild(successElement)
    
    // Hide after 5 seconds
    setTimeout(() => {
      this.successContainerTarget.classList.add('hidden')
    }, 5000)
  }
} 