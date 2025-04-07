import { Application } from "@hotwired/stimulus"
import SettingsController from "../../../app/javascript/controllers/settings_controller"

describe("SettingsController", () => {
  let application
  let element
  let controller

  beforeEach(() => {
    // Set up a basic DOM structure
    document.body.innerHTML = `
      <div data-controller="settings">
        <div data-settings-target="errorContainer" class="d-none"></div>
        <div data-settings-target="successContainer" class="d-none"></div>
        <form data-settings-target="form">
          <input type="checkbox" data-settings-target="notificationsEnabled" checked>
          <input type="checkbox" data-settings-target="emailNotificationsEnabled" checked>
          <div data-settings-target="advancedNotificationOptions"></div>
          <select data-settings-target="emailFrequency">
            <option value="immediately">Immediately</option>
            <option value="daily_digest">Daily Digest</option>
          </select>
          <input type="checkbox" data-settings-target="pushEnabled">
          <input type="checkbox" data-settings-target="smsEnabled">
          <select data-settings-target="pushFrequency"></select>
          <select data-settings-target="smsFrequency"></select>
        </form>
      </div>
    `

    element = document.querySelector('[data-controller="settings"]')
    
    // Create a Stimulus application and register our controller
    application = Application.start()
    application.register("settings", SettingsController)
    
    // Get a reference to the controller instance
    controller = application.getControllerForElementAndIdentifier(element, "settings")
  })

  afterEach(() => {
    document.body.innerHTML = ''
  })

  describe("initialization", () => {
    test("toggleAdvancedOptions should be called on connect", () => {
      // Create a spy on the toggleAdvancedOptions method
      const spy = jest.spyOn(controller, "toggleAdvancedOptions")
      
      // Reconnect the controller to trigger the connect method
      controller.connect()
      
      // Verify toggleAdvancedOptions was called
      expect(spy).toHaveBeenCalled()
    })
  })

  describe("toggleAdvancedOptions", () => {
    test("should show advanced options when notifications are enabled", () => {
      // Set notifications to enabled
      controller.notificationsEnabledTarget.checked = true
      
      // Call the method
      controller.toggleAdvancedOptions()
      
      // Check if the advanced options are visible
      expect(controller.advancedNotificationOptionsTarget.classList.contains("d-none")).toBe(false)
    })
    
    test("should hide advanced options when notifications are disabled", () => {
      // Set notifications to disabled
      controller.notificationsEnabledTarget.checked = false
      
      // Call the method
      controller.toggleAdvancedOptions()
      
      // Check if the advanced options are hidden
      expect(controller.advancedNotificationOptionsTarget.classList.contains("d-none")).toBe(true)
    })
  })

  describe("toggleEmailOptions", () => {
    test("should enable email frequency when email notifications are enabled", () => {
      // Set email notifications to enabled
      controller.emailNotificationsEnabledTarget.checked = true
      
      // Call the method
      controller.toggleEmailOptions()
      
      // Check if email frequency is enabled
      expect(controller.emailFrequencyTarget.disabled).toBe(false)
    })
    
    test("should disable email frequency when email notifications are disabled", () => {
      // Set email notifications to disabled
      controller.emailNotificationsEnabledTarget.checked = false
      
      // Call the method
      controller.toggleEmailOptions()
      
      // Check if email frequency is disabled
      expect(controller.emailFrequencyTarget.disabled).toBe(true)
    })
  })

  describe("showError and showSuccess", () => {
    test("showError should display error message", () => {
      const errorMessage = "Test error message"
      
      // Call showError method
      controller.showError(errorMessage)
      
      // Check if error container is visible with the message
      expect(controller.errorContainerTarget.classList.contains("d-none")).toBe(false)
      expect(controller.errorContainerTarget.textContent).toBe(errorMessage)
    })
    
    test("showSuccess should display success message", () => {
      const successMessage = "Test success message"
      
      // Call showSuccess method
      controller.showSuccess(successMessage)
      
      // Check if success container is visible with the message
      expect(controller.successContainerTarget.classList.contains("d-none")).toBe(false)
      expect(controller.successContainerTarget.textContent).toBe(successMessage)
    })
  })
}) 