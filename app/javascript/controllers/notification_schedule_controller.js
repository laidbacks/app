import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification-schedule"
export default class extends Controller {
  static targets = [
    "form", 
    "loading", 
    "details", 
    "title", 
    "body", 
    "type", 
    "errorContainer", 
    "successContainer", 
    "scheduleTypeInput", 
    "frequencyInput", 
    "frequencyContainer", 
    "scheduledAtInput"
  ]
  static values = { id: String }

  connect() {
    console.log("Notification schedule controller connected")
    
    // Get CSRF token for API requests
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    // Load notification details
    this.loadNotification()
    
    // Set default scheduled_at to now + 1 hour
    const oneHourFromNow = new Date(Date.now() + 60 * 60 * 1000)
    const formatted = oneHourFromNow.toISOString().slice(0, 16) // Format for datetime-local input
    if (this.hasScheduledAtInputTarget) this.scheduledAtInputTarget.value = formatted
  }

  async loadNotification() {
    if (!this.idValue) return
    
    try {
      this.showLoading()
      
      const response = await fetch(`/api/v1/notifications/${this.idValue}`)
      
      if (response.ok) {
        const notification = await response.json()
        this.displayNotificationDetails(notification)
        
        // Show form after loading
        if (this.hasFormTarget) this.formTarget.classList.remove('hidden')
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

  displayNotificationDetails(notification) {
    if (this.hasTitleTarget) this.titleTarget.textContent = notification.title
    if (this.hasBodyTarget) this.bodyTarget.textContent = notification.body
    if (this.hasTypeTarget) this.typeTarget.textContent = notification.notification_type
    
    // Show notification details
    if (this.hasDetailsTarget) this.detailsTarget.classList.remove('hidden')
  }

  toggleRecurring() {
    if (!this.hasScheduleTypeInputTarget || !this.hasFrequencyContainerTarget) return
    
    const isRecurring = this.scheduleTypeInputTarget.value === 'recurring'
    this.frequencyContainerTarget.classList.toggle('hidden', !isRecurring)
  }

  async scheduleNotification(event) {
    event.preventDefault()
    
    if (!this.idValue) return
    
    const scheduleType = this.scheduleTypeInputTarget.value
    const jsonData = {
      schedule: {
        schedule_type: scheduleType,
        frequency: scheduleType === 'recurring' ? this.frequencyInputTarget.value : 'daily', // Default for one-time
        scheduled_at: new Date(this.scheduledAtInputTarget.value).toISOString()
      }
    }
    
    try {
      const response = await fetch(`/api/v1/notifications/${this.idValue}/schedule`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: JSON.stringify(jsonData)
      })
      
      if (response.ok) {
        this.showSuccess('Notification scheduled successfully!')
        
        // Redirect to notifications list after a short delay
        setTimeout(() => {
          window.location.href = '/notifications'
        }, 1500)
      } else {
        const errorData = await response.json()
        this.showErrors(errorData.errors || ['Failed to schedule notification'])
      }
    } catch (error) {
      console.error('Error scheduling notification:', error)
      this.showErrors(['An unexpected error occurred'])
    }
  }

  cancel() {
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
    
    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.add('hidden')
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