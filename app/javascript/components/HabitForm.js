import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="habit-form"
export default class extends Controller {
    static targets = ["form", "nameInput", "descriptionInput", "frequencyInput", "errorContainer", "habitIdInput", "activeInput"]

    connect() {
        console.log("HabitForm controller connected")

        // Ensure the CSRF token is properly set
        this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    }

    closeModal(event) {
        if (event) {
            // If this was triggered by an event, prevent default behavior
            event.preventDefault()
            console.log("closeModal called from event handler")
        } else {
            console.log("closeModal called programmatically")
        }

        // Use the global hide modal function if available
        if (typeof window.hideAddHabitModal === 'function') {
            console.log("Using global hideAddHabitModal function")
            window.hideAddHabitModal()
            return
        }

        // Fallback to manual hiding
        console.log("Using fallback modal hide")
        const modal = document.getElementById('addHabitModal')
        const editModal = document.getElementById('editHabitModal')

        if (modal) {
            console.log("Closing addHabitModal")
            modal.classList.add('hidden')
            modal.style.display = 'none'
        }

        if (editModal) {
            console.log("Closing editHabitModal")
            editModal.classList.add('hidden')
            editModal.style.display = 'none'
        }
    }

    async submit(event) {
        event.preventDefault()
        console.log("HabitForm submit triggered")

        const jsonData = {
            habit: {
                name: this.nameInputTarget.value,
                description: this.descriptionInputTarget.value,
                frequency: this.frequencyInputTarget.value,
                active: true
            }
        }

        console.log("Submitting habit data:", jsonData)

        // Get form values to display after submission
        const habitName = this.nameInputTarget.value
        const habitDesc = this.descriptionInputTarget.value
        const habitFreq = this.frequencyInputTarget.value

        try {
            const response = await fetch('/api/habits', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                },
                body: JSON.stringify(jsonData)
            })

            console.log("Response status:", response.status);

            if (response.ok) {
                // Parse the JSON response but don't show it to the user
                const responseData = await response.json();
                console.log("Success response:", responseData);

                // Reset form
                this.formTarget.reset()

                // Force hide the modal completely
                const modal = document.getElementById('addHabitModal');
                if (modal) {
                    modal.classList.add('hidden');
                    modal.style.display = 'none';
                }

                // Show success message
                const successMessage = document.createElement('div');
                successMessage.className = 'success-message';
                successMessage.style.padding = '10px';
                successMessage.style.backgroundColor = '#10b981';
                successMessage.style.color = 'white';
                successMessage.style.borderRadius = '5px';
                successMessage.style.margin = '10px 0';
                successMessage.style.position = 'fixed';
                successMessage.style.top = '20px';
                successMessage.style.right = '20px';
                successMessage.style.zIndex = '9999';
                successMessage.textContent = `Habit "${habitName}" created successfully!`;
                document.body.appendChild(successMessage);

                // Remove the success message after 3 seconds
                setTimeout(() => {
                    successMessage.remove();
                }, 3000);

                // Dispatch event to notify other controllers
                const event = new CustomEvent('habit:created', { detail: responseData })
                window.dispatchEvent(event)

                // Reload the page after a small delay
                setTimeout(() => {
                    window.location.reload()
                }, 300)
            } else {
                console.error("Error response, status:", response.status);
                // Parse error response, but don't show it directly to user
                const errorData = await response.json();
                console.error("Error data:", errorData);
                this.showErrors(errorData.errors || ['Failed to create habit. Please try again.'])
            }
        } catch (error) {
            console.error('Error creating habit:', error)
            this.showErrors(['An unexpected error occurred. Please try again.'])
        }
    }

    async update(event) {
        event.preventDefault()

        if (!this.hasHabitIdInputTarget) {
            console.error('No habit ID found')
            return
        }

        const habitId = this.habitIdInputTarget.value

        if (!habitId) {
            console.error('Habit ID is empty')
            return
        }

        const jsonData = {
            habit: {
                name: this.nameInputTarget.value,
                description: this.descriptionInputTarget.value,
                frequency: this.frequencyInputTarget.value,
                active: this.hasActiveInputTarget ? this.activeInputTarget.value === 'true' : true
            }
        }

        try {
            const response = await fetch(`/api/habits/${habitId}`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                },
                body: JSON.stringify(jsonData)
            })

            if (response.ok) {
                const data = await response.json()
                // Close modal
                this.closeModal()

                // Dispatch event to notify other controllers
                const event = new CustomEvent('habit:updated', { detail: data })
                window.dispatchEvent(event)

                // Reload the page to show updated habit details
                window.location.reload()
            } else {
                const errorData = await response.json()
                this.showErrors(errorData.errors)
            }
        } catch (error) {
            console.error('Error updating habit:', error)
            this.showErrors(['An unexpected error occurred. Please try again.'])
        }
    }

    showErrors(errors) {
        console.log("Showing errors:", errors)

        if (!this.hasErrorContainerTarget) {
            console.error("Error container target not found")
            return
        }

        this.errorContainerTarget.innerHTML = ''

        if (errors && errors.length) {
            const errorList = document.createElement('ul')
            errorList.classList.add('error-list')

            errors.forEach(error => {
                const errorItem = document.createElement('li')
                errorItem.textContent = error
                errorList.appendChild(errorItem)
                console.error("Form error:", error)
            })

            this.errorContainerTarget.appendChild(errorList)
        }
    }
} 