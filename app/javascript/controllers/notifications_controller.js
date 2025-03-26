import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notifications"
export default class extends Controller {
  static targets = [
    "list", 
    "form", 
    "emailToggle", 
    "pushToggle", 
    "smsToggle", 
    "emailOptions", 
    "pushOptions", 
    "smsOptions",
    "errorContainer",
    "successContainer"
  ]

  connect() {
    console.log("Notifications controller connected")
    
    // Get CSRF token for API requests
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    // Determine if we're on the profile page
    this.isProfilePage = window.location.pathname.includes('/profile')
    
    // Load user's notification preferences
    if (this.hasFormTarget) {
      this.loadNotificationPreferences()
    }
    
    // Load notifications list
    this.loadNotifications()
    
    // Reload stats on profile page
    if (this.isProfilePage) {
      this.loadNotificationStats()
    }
    
    // Listen for notification updates from other pages
    window.addEventListener('turbo:load', this.loadNotifications.bind(this))
    
    // Check for notification parameter in URL
    const urlParams = new URLSearchParams(window.location.search)
    if (urlParams.has('notification_created')) {
      this.showSuccess('Notification was successfully created.')
    }
  }

  async loadNotificationPreferences() {
    try {
      const response = await fetch('/api/v1/notification_preferences')
      
      if (response.ok) {
        const data = await response.json()
        
        // Update toggle states based on user preferences
        if (this.hasEmailToggleTarget) {
          this.emailToggleTarget.checked = data.email_enabled
          this.toggleOptions('email')
        }
        
        if (this.hasPushToggleTarget) {
          this.pushToggleTarget.checked = data.push_enabled
          this.toggleOptions('push')
        }
        
        if (this.hasSmsToggleTarget) {
          this.smsToggleTarget.checked = data.sms_enabled
          this.toggleOptions('sms')
        }
      } else {
        console.error('Failed to load notification preferences')
      }
    } catch (error) {
      console.error('Error loading notification preferences:', error)
    }
  }

  async loadNotificationStats() {
    try {
      const response = await fetch('/api/v1/notifications/stats')
      
      if (response.ok) {
        const stats = await response.json()
        
        // Update stats in the profile page
        const statsContainer = document.getElementById('notification-stats')
        if (statsContainer) {
          const scheduledValue = statsContainer.querySelector('.scheduled .stat-value')
          const pendingValue = statsContainer.querySelector('.pending .stat-value')
          const sentValue = statsContainer.querySelector('.sent .stat-value')
          
          if (scheduledValue) scheduledValue.textContent = stats.scheduled || 0
          if (pendingValue) pendingValue.textContent = stats.pending || 0
          if (sentValue) sentValue.textContent = stats.sent || 0
        }
      } else {
        console.error('Failed to load notification stats')
      }
    } catch (error) {
      console.error('Error loading notification stats:', error)
    }
  }

  async loadNotifications() {
    if (!this.hasListTarget) return
    
    try {
      this.listTarget.innerHTML = '<div class="loading-indicator">Loading notifications...</div>'
      
      const response = await fetch('/api/v1/notifications')
      
      if (response.ok) {
        const notifications = await response.json()
        console.log('Loaded notifications:', notifications)
        
        if (!notifications || notifications.length === 0) {
          this.listTarget.innerHTML = `
            <div class="empty-notifications">
              <i class="fas fa-bell-slash"></i>
              <p>No notifications found</p>
              <a href="/notifications/new" class="create-notification-btn centered">
                <i class="fas fa-plus-circle"></i> Create Notification
              </a>
            </div>
          `
          return
        }
        
        // Clear loading message
        this.listTarget.innerHTML = ''
        
        // On profile page, only show the 3 most recent notifications
        const displayNotifications = this.isProfilePage 
          ? notifications.slice(0, 3) 
          : notifications
        
        // Render each notification
        displayNotifications.forEach(notification => {
          const notificationElement = this.createNotificationElement(notification)
          this.listTarget.appendChild(notificationElement)
        })
        
        // Add view all link for profile page
        if (this.isProfilePage && notifications.length > 0) {
          const viewAllLink = document.createElement('div')
          viewAllLink.className = 'view-all-link'
          viewAllLink.innerHTML = `
            <a href="/notifications">
              View All Notifications <i class="fas fa-arrow-right"></i>
            </a>
          `
          this.listTarget.appendChild(viewAllLink)
        }
      } else {
        console.error('Failed to load notifications, status:', response.status)
        this.listTarget.innerHTML = '<div class="error-message">Failed to load notifications</div>'
      }
    } catch (error) {
      console.error('Error loading notifications:', error)
      this.listTarget.innerHTML = '<div class="error-message">Error loading notifications</div>'
    }
  }

  createNotificationElement(notification) {
    // Use a different class for notifications on profile page
    const itemClass = this.isProfilePage 
      ? 'recent-notification-item' 
      : 'notification-item'
    
    const container = document.createElement('div')
    container.className = `${itemClass} ${notification.status}`
    container.dataset.notificationId = notification.id
    
    const statusLabel = {
      scheduled: 'Scheduled',
      pending: 'Pending',
      sent: 'Sent',
      failed: 'Failed'
    }
    
    const typeIcon = {
      email: 'fa-envelope',
      push: 'fa-bell',
      sms: 'fa-comment-sms'
    }
    
    let scheduleInfo = ''
    if (notification.notification_schedule) {
      const schedule = notification.notification_schedule
      scheduleInfo = `
        <div class="schedule-info">
          <span class="schedule-type">${schedule.schedule_type.replace('_', ' ')}</span> •
          <span class="frequency">${schedule.frequency}</span> •
          <span class="scheduled-at">Next: ${new Date(schedule.scheduled_at).toLocaleString()}</span>
        </div>
      `
    }
    
    const notificationType = notification.notification_type || 'unknown'
    const notificationStatus = notification.status || 'pending'
    
    // Create content for the notification
    const content = `
      <div class="notification-content">
        <div class="notification-title">${notification.title || 'Untitled'}</div>
        <div class="notification-body">${notification.body || 'No content'}</div>
        ${scheduleInfo}
      </div>
      <div class="notification-meta">
        <span class="notification-type ${notificationType}">
          <i class="fas ${typeIcon[notificationType] || 'fa-bell'}"></i>
          ${notificationType.charAt(0).toUpperCase() + notificationType.slice(1)}
        </span>
        <span class="notification-status status-${notificationStatus}">
          ${statusLabel[notificationStatus] || 'Unknown'}
        </span>
      </div>
    `
    
    // Only add actions on the main notifications page, not on profile
    if (this.isProfilePage) {
      container.innerHTML = `
        <div class="notification-details">
          ${content}
        </div>
      `
    } else {
      container.innerHTML = `
        <div class="notification-details">
          ${content}
        </div>
        <div class="notification-actions">
          ${notificationStatus === 'scheduled' ? 
            `<button class="notification-action-btn cancel-btn" data-action="click->notifications#cancelNotification">
               <i class="fas fa-times"></i> Cancel
             </button>` : 
            ''}
          ${notificationStatus === 'pending' ? 
            `<button class="notification-action-btn reschedule-btn" data-action="click->notifications#scheduleModal">
               <i class="fas fa-clock"></i> Schedule
             </button>` : 
            ''}
          <button class="notification-action-btn edit-btn" data-action="click->notifications#editNotification">
            <i class="fas fa-edit"></i> Edit
          </button>
        </div>
      `
    }
    
    return container
  }

  toggleType(event) {
    const type = event.currentTarget.dataset.type
    this.toggleOptions(type)
  }
  
  toggleOptions(type) {
    if (type === 'email' && this.hasEmailOptionsTarget && this.hasEmailToggleTarget) {
      this.emailOptionsTarget.style.display = this.emailToggleTarget.checked ? 'block' : 'none'
    } else if (type === 'push' && this.hasPushOptionsTarget && this.hasPushToggleTarget) {
      this.pushOptionsTarget.style.display = this.pushToggleTarget.checked ? 'block' : 'none'
    } else if (type === 'sms' && this.hasSmsOptionsTarget && this.hasSmsToggleTarget) {
      this.smsOptionsTarget.style.display = this.smsToggleTarget.checked ? 'block' : 'none'
    }
  }

  async savePreferences(event) {
    event.preventDefault()
    
    if (!this.hasFormTarget) return
    
    const formData = new FormData(this.formTarget)
    const jsonData = {
      preferences: {
        email_enabled: this.hasEmailToggleTarget ? this.emailToggleTarget.checked : false,
        push_enabled: this.hasPushToggleTarget ? this.pushToggleTarget.checked : false,
        sms_enabled: this.hasSmsToggleTarget ? this.smsToggleTarget.checked : false,
        email_frequency: formData.get('email_frequency'),
        push_frequency: formData.get('push_frequency'),
        sms_frequency: formData.get('sms_frequency')
      }
    }
    
    try {
      const response = await fetch('/api/v1/notification_preferences', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: JSON.stringify(jsonData)
      })
      
      if (response.ok) {
        this.showSuccess('Notification preferences saved successfully!')
      } else {
        const errorData = await response.json()
        this.showErrors(errorData.errors || ['Failed to save preferences'])
      }
    } catch (error) {
      console.error('Error saving preferences:', error)
      this.showErrors(['An unexpected error occurred'])
    }
  }
  
  async cancelNotification(event) {
    const notificationElement = event.target.closest('.notification-item')
    const notificationId = notificationElement.dataset.notificationId
    
    if (!notificationId) return
    
    try {
      const response = await fetch(`/api/v1/notifications/${notificationId}/cancel`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken
        }
      })
      
      if (response.ok) {
        // Reload notifications list
        this.loadNotifications()
        
        // Also update stats if on profile page
        if (this.isProfilePage) {
          this.loadNotificationStats()
        }
        this.showSuccess('Notification cancelled successfully!')
      } else {
        const errorData = await response.json()
        this.showErrors(errorData.errors || ['Failed to cancel notification'])
      }
    } catch (error) {
      console.error('Error cancelling notification:', error)
      this.showErrors(['An unexpected error occurred'])
    }
  }

  editNotification(event) {
    const notificationElement = event.target.closest('[data-notification-id]')
    const notificationId = notificationElement?.dataset.notificationId
    
    if (!notificationId) return
    
    // Navigate to edit page
    window.location.href = `/notifications/${notificationId}/edit`
  }
  
  scheduleModal(event) {
    const notificationElement = event.target.closest('[data-notification-id]')
    const notificationId = notificationElement?.dataset.notificationId
    
    if (!notificationId) return
    
    // Navigate to schedule page
    window.location.href = `/notifications/${notificationId}/schedule`
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