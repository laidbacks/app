import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "username", 
    "fullName", 
    "email", 
    "bio", 
    "timezone", 
    "submitButton", 
    "errorContainer", 
    "successContainer",
    "avatarInput"
  ]

  connect() {
    console.log("Profile controller connected")
  }

  updateProfile(event) {
    event.preventDefault()
    this.submitButton.disabled = true
    this.submitButton.textContent = "Saving..."
    
    const formData = new FormData()
    formData.append("username", this.usernameTarget.value)
    
    if (this.hasFullNameTarget) {
      formData.append("full_name", this.fullNameTarget.value)
    }
    
    if (this.hasEmailTarget) {
      formData.append("email", this.emailTarget.value)
    }
    
    if (this.hasBioTarget) {
      formData.append("bio", this.bioTarget.value)
    }
    
    if (this.hasTimezoneTarget) {
      formData.append("timezone", this.timezoneTarget.value)
    }

    fetch("/profile", {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "application/json"
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      this.submitButton.disabled = false
      this.submitButton.textContent = "Save Changes"
      
      if (data.errors) {
        this.showError(data.errors.join(", "))
      } else {
        this.showSuccess("Profile updated successfully!")
        
        // Optionally refresh the page after a short delay
        setTimeout(() => {
          window.location.href = "/profile"
        }, 1000)
      }
    })
    .catch(error => {
      this.submitButton.disabled = false
      this.submitButton.textContent = "Save Changes"
      this.showError("An error occurred while updating your profile.")
      console.error("Profile update error:", error)
    })
  }

  openAvatarUpload() {
    this.avatarInputTarget.click()
  }

  uploadAvatar(event) {
    const file = event.target.files[0]
    if (!file) return
    
    const formData = new FormData()
    formData.append("avatar", file)
    
    this.showSuccess("Uploading avatar...")
    
    fetch("/profile/avatar", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "application/json"
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        this.showError(data.error)
      } else {
        this.showSuccess(data.message || "Avatar uploaded successfully!")
        
        // Refresh the page to show the new avatar
        setTimeout(() => {
          window.location.reload()
        }, 1000)
      }
    })
    .catch(error => {
      this.showError("An error occurred while uploading your avatar.")
      console.error("Avatar upload error:", error)
    })
  }

  removeAvatar(event) {
    event.preventDefault()
    
    if (!confirm("Are you sure you want to remove your avatar?")) {
      return
    }
    
    fetch("/profile/avatar", {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "application/json"
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        this.showError(data.error)
      } else {
        this.showSuccess(data.message || "Avatar removed successfully!")
        
        // Refresh the page to show the removed avatar
        setTimeout(() => {
          window.location.reload()
        }, 1000)
      }
    })
    .catch(error => {
      this.showError("An error occurred while removing your avatar.")
      console.error("Avatar removal error:", error)
    })
  }

  showError(message) {
    this.errorContainerTarget.textContent = message
    this.errorContainerTarget.classList.remove("hidden")
    this.successContainerTarget.classList.add("hidden")
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
      this.errorContainerTarget.classList.add("hidden")
    }, 5000)
  }

  showSuccess(message) {
    this.successContainerTarget.textContent = message
    this.successContainerTarget.classList.remove("hidden")
    this.errorContainerTarget.classList.add("hidden")
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
      this.successContainerTarget.classList.add("hidden")
    }, 5000)
  }
} 