import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="habit-log"
export default class extends Controller {
    static targets = ["form", "dateInput", "notesInput", "completedInput", "errorContainer"]
    static values = {
        habitId: String
    }

    connect() {
        console.log("HabitLog controller connected")

        // Set today's date as default if date input is empty
        if (this.hasDateInputTarget && !this.dateInputTarget.value) {
            this.dateInputTarget.value = this.getTodayDate()
        }
    }

    closeModal() {
        // Find and close the add log modal
        const modal = document.getElementById('addLogModal')
        if (modal) {
            modal.classList.add('hidden')
        }
    }

    async submit(event) {
        event.preventDefault()

        if (!this.hasHabitIdValue) {
            console.error('Habit ID value is missing')
            return
        }

        const formData = new FormData(this.formTarget)
        const jsonData = {
            habit_log: {
                date: this.dateInputTarget.value,
                notes: this.hasNotesInputTarget ? this.notesInputTarget.value : '',
                completed: this.hasCompletedInputTarget ? this.completedInputTarget.checked : true
            }
        }

        try {
            const response = await fetch(`/api/habits/${this.habitIdValue}/habit_logs`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify(jsonData)
            })

            if (response.ok) {
                const data = await response.json()

                // Reset form
                this.formTarget.reset()
                // Close modal
                this.closeModal()
                // Set today's date again
                if (this.hasDateInputTarget) {
                    this.dateInputTarget.value = this.getTodayDate()
                }

                // Dispatch event to notify other controllers
                const event = new CustomEvent('habit-log:created', { detail: data })
                window.dispatchEvent(event)

                // Show success message
                this.showSuccessMessage('Habit log saved successfully!')
            } else {
                const errorData = await response.json()
                this.showErrors(errorData.errors)
            }
        } catch (error) {
            console.error('Error creating habit log:', error)
            this.showErrors(['An unexpected error occurred. Please try again.'])
        }
    }

    showErrors(errors) {
        if (!this.hasErrorContainerTarget) return

        this.errorContainerTarget.innerHTML = ''

        if (errors && errors.length) {
            const errorList = document.createElement('ul')
            errorList.classList.add('error-list')

            errors.forEach(error => {
                const errorItem = document.createElement('li')
                errorItem.textContent = error
                errorList.appendChild(errorItem)
            })

            this.errorContainerTarget.appendChild(errorList)
        }
    }

    showSuccessMessage(message) {
        if (!this.hasErrorContainerTarget) return

        this.errorContainerTarget.innerHTML = ''

        const successMessage = document.createElement('div')
        successMessage.classList.add('success-message')
        successMessage.textContent = message

        this.errorContainerTarget.appendChild(successMessage)

        // Remove success message after a delay
        setTimeout(() => {
            successMessage.remove()
        }, 3000)
    }

    // Utility methods
    getTodayDate() {
        const date = new Date()
        const year = date.getFullYear()
        const month = String(date.getMonth() + 1).padStart(2, '0')
        const day = String(date.getDate()).padStart(2, '0')
        return `${year}-${month}-${day}`
    }
} 