import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="habit-stats"
export default class extends Controller {
    static targets = ["statsContainer", "loadingIndicator", "weeklyChart", "monthlyChart", "currentStreakValue", "completionRateValue"]
    static values = {
        habitId: String,
        startDate: String,
        endDate: String
    }

    connect() {
        console.log("HabitStats controller connected")

        if (this.hasHabitIdValue) {
            this.loadHabitStats()
        }

        // Listen for habit toggled events
        window.addEventListener('habit:toggled', this.handleHabitToggled.bind(this))
    }

    disconnect() {
        window.removeEventListener('habit:toggled', this.handleHabitToggled.bind(this))
    }

    async loadHabitStats() {
        if (this.hasLoadingIndicatorTarget) {
            this.loadingIndicatorTarget.classList.remove('hidden')
        }

        try {
            // Set default date range if not provided
            const startDate = this.hasStartDateValue ? this.startDateValue : this.getMonthStartDate()
            const endDate = this.hasEndDateValue ? this.endDateValue : this.getTodayDate()

            const queryParams = new URLSearchParams({
                start_date: startDate,
                end_date: endDate
            })

            const response = await fetch(`/api/habits/${this.habitIdValue}/stats?${queryParams}`, {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                }
            })

            if (response.ok) {
                const stats = await response.json()
                this.renderStats(stats)
            } else {
                console.error('Failed to load habit stats')
            }
        } catch (error) {
            console.error('Error loading habit stats:', error)
        } finally {
            if (this.hasLoadingIndicatorTarget) {
                this.loadingIndicatorTarget.classList.add('hidden')
            }
        }
    }

    renderStats(stats) {
        // Update current streak
        if (this.hasCurrentStreakValueTarget) {
            this.currentStreakValueTarget.textContent = stats.current_streak || '0'
        }

        // Update completion rate
        if (this.hasCompletionRateValueTarget) {
            this.completionRateValueTarget.textContent = `${Math.round(stats.completion_rate)}%`
        }

        // Additional stats rendering (weekly/monthly charts) could go here
        // This would typically involve using a charting library like Chart.js
    }

    handleHabitToggled(event) {
        // Reload stats when a habit is toggled
        if (this.hasHabitIdValue && event.detail && event.detail.habit_id === this.habitIdValue) {
            this.loadHabitStats()
        }
    }

    // Utility methods for date formatting
    getMonthStartDate() {
        const date = new Date()
        date.setDate(1)
        return this.formatDate(date)
    }

    getTodayDate() {
        return this.formatDate(new Date())
    }

    formatDate(date) {
        const year = date.getFullYear()
        const month = String(date.getMonth() + 1).padStart(2, '0')
        const day = String(date.getDate()).padStart(2, '0')
        return `${year}-${month}-${day}`
    }
} 