import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="settings"
export default class extends Controller {
  static targets = [
    "form", 
    "notificationsEnabled", 
    "emailNotificationsEnabled",
    "advancedNotificationOptions",
    "emailFrequency",
    "pushEnabled",
    "smsEnabled",
    "pushFrequency",
    "smsFrequency",
    "errorContainer",
    "successContainer"
  ]

  connect() {
    console.log("Settings controller connected")
    
    // Get CSRF token for API requests
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    // Check if we have notification preferences available
    if (this.hasNotificationsEnabledTarget) {
      this.loadNotificationPreferences()
      
      // Add event listeners for toggles
      if (this.hasNotificationsEnabledTarget) {
        this.notificationsEnabledTarget.addEventListener('change', this.toggleAdvancedOptions.bind(this))
        this.toggleAdvancedOptions()
      }
      
      if (this.hasEmailNotificationsEnabledTarget) {
        this.emailNotificationsEnabledTarget.addEventListener('change', this.toggleEmailOptions.bind(this))
        this.toggleEmailOptions()
      }
    }
  }
  
  toggleAdvancedOptions() {
    if (this.hasAdvancedNotificationOptionsTarget) {
      this.advancedNotificationOptionsTarget.classList.toggle('d-none', !this.notificationsEnabledTarget.checked)
    }
  }
  
  toggleEmailOptions() {
    if (this.hasEmailFrequencyTarget) {
      this.emailFrequencyTarget.disabled = !this.emailNotificationsEnabledTarget.checked
    }
  }
  
  async loadNotificationPreferences() {
    try {
      const response = await fetch('/api/v1/notification_preferences')
      
      if (response.ok) {
        const data = await response.json()
        
        // If we have the advanced options fields, update them
        if (this.hasEmailFrequencyTarget) {
          this.emailFrequencyTarget.value = data.email_frequency
        }
        
        if (this.hasPushEnabledTarget) {
          this.pushEnabledTarget.checked = data.push_enabled
        }
        
        if (this.hasSmsEnabledTarget) {
          this.smsEnabledTarget.checked = data.sms_enabled
        }
        
        if (this.hasPushFrequencyTarget) {
          this.pushFrequencyTarget.value = data.push_frequency
        }
        
        if (this.hasSmsFrequencyTarget) {
          this.smsFrequencyTarget.value = data.sms_frequency
        }
      } else {
        console.error('Failed to load notification preferences')
      }
    } catch (error) {
      console.error('Error loading notification preferences:', error)
    }
  }
  
  async saveAdvancedPreferences(event) {
    event.preventDefault()
    
    // Only proceed if we're showing the advanced options
    if (this.notificationsEnabledTarget.checked) {
      try {
        const preferences = {
          email_enabled: this.emailNotificationsEnabledTarget.checked,
          push_enabled: this.hasPushEnabledTarget ? this.pushEnabledTarget.checked : false,
          sms_enabled: this.hasSmsEnabledTarget ? this.smsEnabledTarget.checked : false,
          email_frequency: this.hasEmailFrequencyTarget ? this.emailFrequencyTarget.value : 'immediately',
          push_frequency: this.hasPushFrequencyTarget ? this.pushFrequencyTarget.value : 'immediately',
          sms_frequency: this.hasSmsFrequencyTarget ? this.smsFrequencyTarget.value : 'immediately'
        }
        
        const response = await fetch('/api/v1/notification_preferences', {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': this.csrfToken
          },
          body: JSON.stringify({ preferences })
        })
        
        if (response.ok) {
          this.showSuccess('Notification preferences updated successfully.')
        } else {
          const errorData = await response.json()
          this.showError(errorData.errors || 'Failed to update notification preferences.')
        }
      } catch (error) {
        console.error('Error saving notification preferences:', error)
        this.showError('An error occurred while saving preferences.')
      }
    }
    
    // Allow the standard form submission to continue
    return true
  }
  
  showError(message) {
    if (this.hasErrorContainerTarget) {
      this.errorContainerTarget.textContent = typeof message === 'string' ? message : JSON.stringify(message)
      this.errorContainerTarget.classList.remove('d-none')
      setTimeout(() => {
        this.errorContainerTarget.classList.add('d-none')
      }, 5000)
    }
  }
  
  showSuccess(message) {
    if (this.hasSuccessContainerTarget) {
      this.successContainerTarget.textContent = message
      this.successContainerTarget.classList.remove('d-none')
      setTimeout(() => {
        this.successContainerTarget.classList.add('d-none')
      }, 5000)
    }
  }
} 