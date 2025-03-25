import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="habit-detail"
export default class extends Controller {
    static targets = [
        "habitName", "habitDescription", "habitFrequency", "habitStatus", "habitCreated",
        "totalCompletions", "bestStreak", "logEntries", "emptyLogsState",
        "loadingIndicator", "contentContainer"
    ]

    connect() {
        console.log("HabitDetail controller connected")

        // Get habit ID from URL
        const habitId = this.getHabitIdFromUrl()
        if (habitId) {
            this.loadHabitDetails(habitId)
            this.loadHabitLogs(habitId)
        } else {
            console.error("No habit ID found in URL")
        }

        // Listen for habit log changes
        window.addEventListener('habit-log:created', this.handleHabitLogChanged.bind(this))
        window.addEventListener('habit:toggled', this.handleHabitLogChanged.bind(this))
    }

    disconnect() {
        window.removeEventListener('habit-log:created', this.handleHabitLogChanged.bind(this))
        window.removeEventListener('habit:toggled', this.handleHabitLogChanged.bind(this))
    }

    async loadHabitDetails(habitId) {
        try {
            const response = await fetch(`/api/habits/${habitId}`, {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                }
            })

            if (response.ok) {
                const habit = await response.json()
                this.renderHabitDetails(habit)
            } else {
                console.error('Failed to load habit details')
            }
        } catch (error) {
            console.error('Error loading habit details:', error)
        }
    }

    async loadHabitLogs(habitId) {
        try {
            const response = await fetch(`/api/habits/${habitId}/habit_logs`, {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                }
            })

            if (response.ok) {
                const logs = await response.json()
                this.renderHabitLogs(logs)
                this.updateStats(logs)
            } else {
                console.error('Failed to load habit logs')
            }
        } catch (error) {
            console.error('Error loading habit logs:', error)
        } finally {
            // Hide loading indicator and show content
            this.loadingIndicatorTarget.classList.add('hidden')
            this.contentContainerTarget.classList.remove('hidden')
        }
    }

    renderHabitDetails(habit) {
        // Update habit information
        this.habitNameTarget.textContent = habit.name
        this.habitDescriptionTarget.textContent = habit.description || 'No description provided'
        this.habitFrequencyTarget.textContent = this.capitalizeFirstLetter(habit.frequency)
        this.habitStatusTarget.textContent = habit.active ? 'Active' : 'Inactive'

        // Format creation date
        const createdDate = new Date(habit.created_at)
        this.habitCreatedTarget.textContent = createdDate.toLocaleDateString()
    }

    renderHabitLogs(logs) {
        if (!this.hasLogEntriesTarget) return

        this.logEntriesTarget.innerHTML = ''

        if (logs.length === 0) {
            if (this.hasEmptyLogsStateTarget) {
                this.emptyLogsStateTarget.classList.remove('hidden')
            }
            return
        }

        if (this.hasEmptyLogsStateTarget) {
            this.emptyLogsStateTarget.classList.add('hidden')
        }

        // Sort logs by date (newest first)
        logs.sort((a, b) => new Date(b.date) - new Date(a.date))

        logs.forEach(log => {
            const logElement = this.createLogElement(log)
            this.logEntriesTarget.appendChild(logElement)
        })
    }

    createLogElement(log) {
        const logEntry = document.createElement('div')
        logEntry.classList.add('log-entry')
        if (log.completed) {
            logEntry.classList.add('completed')
        }

        // Format date for display
        const logDate = new Date(log.date)
        const formattedDate = logDate.toLocaleDateString('en-US', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        })

        logEntry.innerHTML = `
      <span class="log-date">${formattedDate}</span>
      <span class="log-status ${log.completed ? 'completed' : 'pending'}">
        ${log.completed ? 'Completed' : 'Not Completed'}
      </span>
      ${log.notes ? `<p class="log-notes">${log.notes}</p>` : ''}
    `

        return logEntry
    }

    updateStats(logs) {
        // Calculate total completions
        const totalCompletions = logs.filter(log => log.completed).length
        this.totalCompletionsTarget.textContent = totalCompletions

        // Best streak calculation would be more complex and might be better calculated on the server
        // For now, we'll just show a placeholder
        this.bestStreakTarget.textContent = "0"
    }

    showEditModal() {
        const habitId = this.getHabitIdFromUrl()
        if (!habitId) return

        // Set up form with current values
        const nameInput = document.querySelector('#editHabitName')
        const descriptionInput = document.querySelector('#editHabitDescription')
        const frequencyInput = document.querySelector('#editHabitFrequency')
        const activeInput = document.querySelector('#editHabitActive')
        const habitIdInput = document.querySelector('[data-habit-form-target="habitIdInput"]')

        if (nameInput) nameInput.value = this.habitNameTarget.textContent
        if (descriptionInput) descriptionInput.value = this.habitDescriptionTarget.textContent
        if (frequencyInput) frequencyInput.value = this.habitFrequencyTarget.textContent.toLowerCase()
        if (activeInput) activeInput.value = this.habitStatusTarget.textContent === 'Active' ? 'true' : 'false'
        if (habitIdInput) habitIdInput.value = habitId

        // Show the modal
        document.getElementById('editHabitModal').classList.remove('hidden')
    }

    showAddLogModal() {
        document.getElementById('addLogModal').classList.remove('hidden')
    }

    async confirmDelete() {
        const habitId = this.getHabitIdFromUrl()
        if (!habitId) return

        const habitName = this.habitNameTarget.textContent

        if (confirm(`Are you sure you want to delete the habit "${habitName}"? This will delete all logs associated with this habit.`)) {
            try {
                const response = await fetch(`/api/habits/${habitId}`, {
                    method: 'DELETE',
                    headers: {
                        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                    }
                })

                if (response.ok) {
                    // Redirect to habits page
                    window.location.href = '/habits'
                } else {
                    console.error('Failed to delete habit')
                    alert('Failed to delete habit. Please try again.')
                }
            } catch (error) {
                console.error('Error deleting habit:', error)
                alert('An error occurred while deleting the habit. Please try again.')
            }
        }
    }

    handleHabitLogChanged(event) {
        const habitId = this.getHabitIdFromUrl()

        // Reload data if this event is for our habit
        if (habitId &&
            event.detail &&
            (event.detail.habit_id === habitId ||
                (event.detail.habit && event.detail.habit.id === habitId))) {
            this.loadHabitLogs(habitId)
        }
    }

    // Utility methods
    getHabitIdFromUrl() {
        const pathParts = window.location.pathname.split('/')
        return pathParts[pathParts.length - 1]
    }

    capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1)
    }
} 