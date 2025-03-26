// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import SidebarController from "./sidebar_controller"
application.register("sidebar", SidebarController)

// Import our new habit controllers
import HabitFormController from "../components/HabitForm"
import HabitListController from "../components/HabitList"
import HabitDetailController from "../components/HabitDetail"
import HabitLogController from "../components/HabitLog"
import HabitCalendarController from "../components/HabitCalendar"
import HabitStatsController from "../components/HabitStats"
import DashboardHabitsController from "../components/DashboardHabits"

application.register("habit-form", HabitFormController)
application.register("habit-list", HabitListController)
application.register("habit-detail", HabitDetailController)
application.register("habit-log", HabitLogController)
application.register("habit-calendar", HabitCalendarController)
application.register("habit-stats", HabitStatsController)
application.register("dashboard-habits", DashboardHabitsController)

console.log("Registered all Stimulus controllers:",
    ["habit-form", "habit-list", "habit-detail", "habit-log",
        "habit-calendar", "habit-stats", "dashboard-habits"]);
