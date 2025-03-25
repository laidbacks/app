import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="habit-list"
export default class extends Controller {
    static targets = ["habitContainer", "loadingIndicator", "emptyState"]

    connect() {
        console.log("HabitList controller connected")

        // First ensure modal is hidden on page load
        const modal = document.getElementById('addHabitModal')
        if (modal) {
            console.log("Ensuring modal is hidden on connect")
            modal.classList.add('hidden')
        }

        // Then load habits
        this.loadHabits()

        // Listen for habit creation events
        window.addEventListener('habit:created', this.handleHabitCreated.bind(this))
    }

    disconnect() {
        window.removeEventListener('habit:created', this.handleHabitCreated.bind(this))
    }

    showAddHabitModal(event) {
        if (event) {
            event.preventDefault();
        }
        console.log("showAddHabitModal called in HabitList controller");

        // Use the global function if available
        if (typeof window.showAddHabitModal === 'function') {
            console.log("Using global showAddHabitModal function");
            window.showAddHabitModal();
            return;
        }

        // Fallback to direct manipulation
        console.log("Using fallback to show modal");
        const modal = document.getElementById('addHabitModal');
        if (!modal) {
            console.error("Modal element not found!");
            return;
        }

        // Force show the modal by removing the hidden class AND setting display flex
        modal.classList.remove('hidden');
        modal.style.display = 'flex';

        // For debugging only
        console.log("Modal current display:", getComputedStyle(modal).display);
        console.log("Modal current visibility:", getComputedStyle(modal).visibility);
        console.log("Modal has hidden class?", modal.classList.contains('hidden'));

        // Setup close button event handler - using once:true to avoid duplicate handlers
        const closeBtn = modal.querySelector('.close-modal');
        if (closeBtn) {
            closeBtn.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                console.log("Close button clicked");
                this.hideModal(modal);
            }, { once: true });
        }

        // Setup click outside to close - using once:true to avoid duplicate handlers
        const clickOutsideHandler = (event) => {
            if (event.target === modal) {
                console.log("Clicked outside modal, closing");
                this.hideModal(modal);
                modal.removeEventListener('click', clickOutsideHandler);
            }
        };

        modal.addEventListener('click', clickOutsideHandler);

        // Prevent clicks inside modal content from closing the modal
        const modalContent = modal.querySelector('.modal-content');
        if (modalContent) {
            modalContent.addEventListener('click', (event) => {
                event.stopPropagation();
            }, { once: true });
        }
    }

    hideModal(modal) {
        if (!modal) {
            modal = document.getElementById('addHabitModal');
        }

        if (modal) {
            modal.classList.add('hidden');
            console.log("Modal hidden");
        }
    }

    async loadHabits() {
        console.log("Loading habits...")
        if (this.hasLoadingIndicatorTarget) {
            this.loadingIndicatorTarget.classList.remove('hidden')
        }

        try {
            console.log("Fetching habits from API...")

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
                console.log("Loaded habits:", habits, typeof habits)

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
            console.error("No habit container target found")
            return
        }

        this.habitContainerTarget.innerHTML = ''
        console.log("Rendering", habits.length, "habits")

        if (habits.length === 0) {
            if (this.hasEmptyStateTarget) {
                console.log("No habits, showing empty state")
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
        <p class="habit-description">${habit.description || ''}</p>
      </div>
      <div class="habit-actions">
        <button class="toggle-habit-btn" data-action="click->habit-list#toggleHabit" data-habit-list-habit-id-param="${habit.id}">
          ${habit.completed_today ? 'Completed' : 'Mark Complete'}
        </button>
        <button class="edit-habit-btn" data-action="click->habit-list#editHabit" data-habit-list-habit-id-param="${habit.id}">
          Edit
        </button>
        <button class="delete-habit-btn" data-action="click->habit-list#deleteHabit" data-habit-list-habit-id-param="${habit.id}">
          Delete
        </button>
      </div>
    `

        return habitCard
    }

    async toggleHabit(event) {
        const habitId = event.currentTarget.dataset.habitListHabitIdParam

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
                        habitCard.querySelector('.toggle-habit-btn').textContent = 'Completed'
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

    editHabit(event) {
        const habitId = event.currentTarget.dataset.habitListHabitIdParam
        window.location.href = `/habits/${habitId}`
    }

    async deleteHabit(event) {
        if (!confirm('Are you sure you want to delete this habit?')) return

        const habitId = event.currentTarget.dataset.habitListHabitIdParam

        try {
            const response = await fetch(`/api/habits/${habitId}`, {
                method: 'DELETE',
                headers: {
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                }
            })

            if (response.ok) {
                // Remove the habit from the UI
                const habitCard = this.habitContainerTarget.querySelector(`[data-habit-id="${habitId}"]`)
                if (habitCard) {
                    habitCard.remove()
                }

                // Check if we need to show the empty state
                if (this.habitContainerTarget.children.length === 0 && this.hasEmptyStateTarget) {
                    this.emptyStateTarget.classList.remove('hidden')
                }

                // Dispatch event to notify other components
                const event = new CustomEvent('habit:deleted', { detail: { id: habitId } })
                window.dispatchEvent(event)
            } else {
                console.error('Failed to delete habit')
            }
        } catch (error) {
            console.error('Error deleting habit:', error)
        }
    }

    handleHabitCreated(event) {
        // Reload the habits list to include the new habit
        this.loadHabits()
    }
} 