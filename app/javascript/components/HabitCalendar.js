import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="habit-calendar"
export default class extends Controller {
    static targets = ["calendar", "loadingIndicator"]
    static values = {
        habitId: String,
        startDate: String,
        endDate: String
    }

    connect() {
        console.log("HabitCalendar controller connected")

        if (this.hasHabitIdValue) {
            this.loadHabitLogs()
        }

        // Listen for habit log creation/update events
        window.addEventListener('habit-log:created', this.handleHabitLogChanged.bind(this))
        window.addEventListener('habit:toggled', this.handleHabitLogChanged.bind(this))
    }

    disconnect() {
        window.removeEventListener('habit-log:created', this.handleHabitLogChanged.bind(this))
        window.removeEventListener('habit:toggled', this.handleHabitLogChanged.bind(this))
    }

    async loadHabitLogs() {
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

            const response = await fetch(`/api/habits/${this.habitIdValue}/habit_logs?${queryParams}`, {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                }
            })

            if (response.ok) {
                const logs = await response.json()
                this.renderCalendar(logs, startDate, endDate)
            } else {
                console.error('Failed to load habit logs')
            }
        } catch (error) {
            console.error('Error loading habit logs:', error)
        } finally {
            if (this.hasLoadingIndicatorTarget) {
                this.loadingIndicatorTarget.classList.add('hidden')
            }
        }
    }

    renderCalendar(logs, startDate, endDate) {
        if (!this.hasCalendarTarget) return

        this.calendarTarget.innerHTML = ''

        const start = new Date(startDate)
        const end = new Date(endDate)
        const daysBetween = this.getDaysBetween(start, end)

        // Create a map of completed dates for quick lookup
        const completedDates = new Map()
        logs.forEach(log => {
            if (log.completed) {
                completedDates.set(log.date, true)
            }
        })

        // Create the calendar grid
        const calendarGrid = document.createElement('div')
        calendarGrid.classList.add('calendar-grid')

        // Add month header if showing more than 7 days
        if (daysBetween > 7) {
            this.addMonthHeader(calendarGrid, start, end)
        }

        // Add day of week headers
        this.addDayOfWeekHeaders(calendarGrid)

        // Add the calendar days
        let currentDate = new Date(start)

        while (currentDate <= end) {
            const dateString = this.formatDate(currentDate)
            const isCompleted = completedDates.has(dateString)

            const dayEl = document.createElement('div')
            dayEl.classList.add('calendar-day')
            if (isCompleted) {
                dayEl.classList.add('completed')
            }

            // Add today marker
            if (this.isToday(currentDate)) {
                dayEl.classList.add('today')
            }

            dayEl.textContent = currentDate.getDate()
            calendarGrid.appendChild(dayEl)

            // Move to next day
            currentDate.setDate(currentDate.getDate() + 1)
        }

        this.calendarTarget.appendChild(calendarGrid)
    }

    addMonthHeader(calendarGrid, start, end) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"]

        // Create month header element
        const monthHeader = document.createElement('div')
        monthHeader.classList.add('month-header')

        // If start and end are in the same month
        if (start.getMonth() === end.getMonth() && start.getFullYear() === end.getFullYear()) {
            monthHeader.textContent = `${monthNames[start.getMonth()]} ${start.getFullYear()}`
        } else {
            monthHeader.textContent = `${monthNames[start.getMonth()]} - ${monthNames[end.getMonth()]} ${end.getFullYear()}`
        }

        calendarGrid.appendChild(monthHeader)
    }

    addDayOfWeekHeaders(calendarGrid) {
        const daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        daysOfWeek.forEach(day => {
            const dayHeader = document.createElement('div')
            dayHeader.classList.add('day-header')
            dayHeader.textContent = day
            calendarGrid.appendChild(dayHeader)
        })
    }

    handleHabitLogChanged(event) {
        // Only reload the calendar if this event is for our habit
        if (this.hasHabitIdValue &&
            event.detail &&
            (event.detail.habit_id === this.habitIdValue ||
                (event.detail.habit && event.detail.habit.id === this.habitIdValue))) {
            this.loadHabitLogs()
        }
    }

    // Utility methods
    getDaysBetween(start, end) {
        return Math.floor((end - start) / (1000 * 60 * 60 * 24)) + 1
    }

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

    isToday(date) {
        const today = new Date()
        return date.getDate() === today.getDate() &&
            date.getMonth() === today.getMonth() &&
            date.getFullYear() === today.getFullYear()
    }
} 