import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dashboard-habits"
export default class extends Controller {
    static targets = ["habitContainer", "loadingIndicator", "emptyState"]

    connect() {
        console.log("DashboardHabits controller connected")

        // Load habits when the controller connects
        this.loadHabits()
    }

    async loadHabits() {
        console.log("DashboardHabits: Loading habits...")
        if (this.hasLoadingIndicatorTarget) {
            this.loadingIndicatorTarget.classList.remove('hidden')
        }

        try {
            console.log("DashboardHabits: Fetching habits from API...")

            // Add more debug info to the request
            const token = document.querySelector('meta[name="csrf-token"]')?.content
            console.log("CSRF Token available:", !!token)

            const response = await fetch('/api/habits', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-Token': token
                }
            })

            console.log("API Response status:", response.status)

            if (response.ok) {
                const habits = await response.json()
                console.log("DashboardHabits: Loaded habits:", habits, typeof habits)

                // Additional check if habits is really an array
                if (Array.isArray(habits)) {
                    console.log("Habits is an array with length:", habits.length)
                    this.renderHabits(habits)
                } else {
                    console.error("API returned habits but it's not an array:", habits)
                    // Try to use it anyway if it has needed properties
                    if (habits && typeof habits === 'object') {
                        const habitsArray = [habits]
                        console.log("Converting to array:", habitsArray)
                        this.renderHabits(habitsArray)
                    } else {
                        this.renderHabits([])
                    }
                }
            } else {
                console.error('Failed to load habits, status:', response.status)
                // Show error in UI
                if (this.hasEmptyStateTarget) {
                    this.emptyStateTarget.innerHTML = '<p>Error loading habits. Please try refreshing the page.</p>'
                    this.emptyStateTarget.classList.remove('hidden')
                }
                try {
                    const errorData = await response.json()
                    console.error("API error details:", errorData)
                } catch (e) {
                    console.error("Could not parse error response as JSON")
                }
            }
        } catch (error) {
            console.error('Error loading habits:', error)
            // Show error in UI
            if (this.hasEmptyStateTarget) {
                this.emptyStateTarget.innerHTML = '<p>Error loading habits. Please try refreshing the page.</p>'
                this.emptyStateTarget.classList.remove('hidden')
            }
        } finally {
            if (this.hasLoadingIndicatorTarget) {
                this.loadingIndicatorTarget.classList.add('hidden')
            }
        }
    }

    renderHabits(habits) {
        if (!this.hasHabitContainerTarget) {
            console.error("DashboardHabits: No habit container target found!")
            return
        }

        console.log("DashboardHabits: Rendering", habits.length, "habits")
        this.habitContainerTarget.innerHTML = ''

        if (habits.length === 0) {
            if (this.hasEmptyStateTarget) {
                console.log("DashboardHabits: No habits, showing empty state")
                this.emptyStateTarget.classList.remove('hidden')
            }
            return
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.classList.add('hidden')
        }

        habits.forEach(habit => {
            const habitElement = this.createHabitElement(habit)
            this.habitContainerTarget.appendChild(habitElement)
        })

        // Update insights about strongest habit
        this.updateStrongestHabitInsight(habits)
    }

    updateStrongestHabitInsight(habits) {
        // Find the habit with the longest streak
        if (habits.length === 0) return

        let strongestHabit = habits[0]

        habits.forEach(habit => {
            if ((habit.current_streak || 0) > (strongestHabit.current_streak || 0)) {
                strongestHabit = habit
            }
        })

        // Update the insight box if it exists
        const insightEl = document.querySelector('.strongest-habit-name')
        const streakEl = document.querySelector('.strongest-habit-streak')

        if (insightEl && strongestHabit) {
            insightEl.textContent = strongestHabit.name
        }

        if (streakEl && strongestHabit) {
            streakEl.textContent = `${strongestHabit.current_streak || 0} day streak!`
        }
    }

    createHabitElement(habit) {
        const habitCard = document.createElement('div')
        habitCard.classList.add('habit-card')
        habitCard.dataset.habitId = habit.id

        // Add status class based on today's completion
        if (habit.completed_today) {
            habitCard.classList.add('completed')
        } else {
            habitCard.classList.add('pending')
        }

        habitCard.innerHTML = `
            <div class="habit-info">
                <h3 class="habit-name">${habit.name}</h3>
                <span class="habit-streak">${habit.current_streak || 0} day streak</span>
            </div>
            <div class="habit-actions">
                <button class="toggle-habit-btn" data-action="click->dashboard-habits#toggleHabit" data-dashboard-habits-habit-id-param="${habit.id}">
                    ${habit.completed_today ?
                '✓ Completed' :
                'Mark Complete'
            }
                </button>
                <a href="/habits/${habit.id}" class="view-details-btn">
                    <button>View Details</button>
                </a>
            </div>
        `

        return habitCard
    }

    async toggleHabit(event) {
        const habitId = event.currentTarget.dataset.dashboardHabitsHabitIdParam

        try {
            const response = await fetch(`/api/habits/${habitId}/toggle_today`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
                    'Accept': 'application/json'
                }
            })

            if (response.ok) {
                const data = await response.json()

                // Update the UI to reflect the change
                const habitCard = this.habitContainerTarget.querySelector(`[data-habit-id="${habitId}"]`)
                if (habitCard) {
                    if (data.completed) {
                        habitCard.classList.remove('pending')
                        habitCard.classList.add('completed')
                        habitCard.querySelector('.toggle-habit-btn').textContent = '✓ Completed'
                    } else {
                        habitCard.classList.remove('completed')
                        habitCard.classList.add('pending')
                        habitCard.querySelector('.toggle-habit-btn').textContent = 'Mark Complete'
                    }
                }

                // Dispatch event to notify other components
                const event = new CustomEvent('habit:toggled', { detail: data })
                window.dispatchEvent(event)
            } else {
                console.error('Failed to toggle habit completion')
            }
        } catch (error) {
            console.error('Error toggling habit:', error)
        }
    }
} 