import Foundation
import Combine

// Local Log entry representation for self-awareness logs.
struct LogEntry: Identifiable, Codable {
    var id = UUID()
    var timestamp: Date
    var appName: String
    var action: String
    var result: String
}

// Session schedule structure for Custom Scroll Sessions.
struct ScrollSession: Identifiable, Codable {
    var id = UUID()
    var startTime: String // HH:MM
    var endTime: String   // HH:MM
    var isActive: Bool
}

// Global AppState manager, implementing Privacy-First locally stored UserDefaults data.
class AppState: ObservableObject {
    @Published var isOnboarded: Bool {
        didSet { UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded") }
    }

    @Published var managedApps: [String] {
        didSet { UserDefaults.standard.set(managedApps, forKey: "managedApps") }
    }

    @Published var pauseDuration: Int {
        didSet { UserDefaults.standard.set(pauseDuration, forKey: "pauseDuration") }
    }

    @Published var hasPremium: Bool {
        didSet { UserDefaults.standard.set(hasPremium, forKey: "hasPremium") }
    }

    @Published var streak: Int {
        didSet { UserDefaults.standard.set(streak, forKey: "streak") }
    }

    @Published var dailyScrollMinutes: Int {
        didSet { UserDefaults.standard.set(dailyScrollMinutes, forKey: "dailyScrollMinutes") }
    }

    @Published var longestSessionMinutes: Int {
        didSet { UserDefaults.standard.set(longestSessionMinutes, forKey: "longestSessionMinutes") }
    }

    @Published var nudgesTriggered: Int {
        didSet { UserDefaults.standard.set(nudgesTriggered, forKey: "nudgesTriggered") }
    }

    @Published var nudgesResisted: Int {
        didSet { UserDefaults.standard.set(nudgesResisted, forKey: "nudgesResisted") }
    }

    @Published var enableIntentionPrompt: Bool {
        didSet { UserDefaults.standard.set(enableIntentionPrompt, forKey: "enableIntentionPrompt") }
    }

    @Published var enableQuietHours: Bool {
        didSet { UserDefaults.standard.set(enableQuietHours, forKey: "enableQuietHours") }
    }

    @Published var quietHoursStart: String {
        didSet { UserDefaults.standard.set(quietHoursStart, forKey: "quietHoursStart") }
    }

    @Published var quietHoursEnd: String {
        didSet { UserDefaults.standard.set(quietHoursEnd, forKey: "quietHoursEnd") }
    }

    @Published var scrollSessions: [ScrollSession] {
        didSet {
            if let encoded = try? JSONEncoder().encode(scrollSessions) {
                UserDefaults.standard.set(encoded, forKey: "scrollSessions")
            }
        }
    }

    @Published var logHistory: [LogEntry] {
        didSet {
            if let encoded = try? JSONEncoder().encode(logHistory) {
                UserDefaults.standard.set(encoded, forKey: "logHistory")
            }
        }
    }

    init() {
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        self.managedApps = UserDefaults.standard.stringArray(forKey: "managedApps") ?? ["Instagram", "TikTok", "Twitter / X", "YouTube", "Reddit"]
        self.pauseDuration = UserDefaults.standard.integer(forKey: "pauseDuration") == 0 ? 10 : UserDefaults.standard.integer(forKey: "pauseDuration")
        self.hasPremium = UserDefaults.standard.bool(forKey: "hasPremium")
        self.streak = UserDefaults.standard.integer(forKey: "streak") == 0 ? 3 : UserDefaults.standard.integer(forKey: "streak")
        self.dailyScrollMinutes = UserDefaults.standard.integer(forKey: "dailyScrollMinutes") == 0 ? 42 : UserDefaults.standard.integer(forKey: "dailyScrollMinutes")
        self.longestSessionMinutes = UserDefaults.standard.integer(forKey: "longestSessionMinutes") == 0 ? 18 : UserDefaults.standard.integer(forKey: "longestSessionMinutes")
        self.nudgesTriggered = UserDefaults.standard.integer(forKey: "nudgesTriggered") == 0 ? 12 : UserDefaults.standard.integer(forKey: "nudgesTriggered")
        self.nudgesResisted = UserDefaults.standard.integer(forKey: "nudgesResisted") == 0 ? 5 : UserDefaults.standard.integer(forKey: "nudgesResisted")

        self.enableIntentionPrompt = UserDefaults.standard.object(forKey: "enableIntentionPrompt") == nil ? true : UserDefaults.standard.bool(forKey: "enableIntentionPrompt")
        self.enableQuietHours = UserDefaults.standard.bool(forKey: "enableQuietHours")
        self.quietHoursStart = UserDefaults.standard.string(forKey: "quietHoursStart") ?? "09:00"
        self.quietHoursEnd = UserDefaults.standard.string(forKey: "quietHoursEnd") ?? "17:00"

        // Load Scroll Sessions
        if let data = UserDefaults.standard.data(forKey: "scrollSessions"),
           let decoded = try? JSONDecoder().decode([ScrollSession].self, from: data) {
            self.scrollSessions = decoded
        } else {
            self.scrollSessions = [
                ScrollSession(startTime: "08:00", endTime: "08:30", isActive: true),
                ScrollSession(startTime: "12:00", endTime: "13:00", isActive: false),
                ScrollSession(startTime: "19:00", endTime: "20:00", isActive: true)
            ]
        }

        // Load Log History
        if let data = UserDefaults.standard.data(forKey: "logHistory"),
           let decoded = try? JSONDecoder().decode([LogEntry].self, from: data) {
            self.logHistory = decoded
        } else {
            let calendar = Calendar.current
            self.logHistory = [
                LogEntry(timestamp: calendar.date(byAdding: .minute, value: -45, to: Date())!, appName: "Instagram", action: "App Opened", result: "Resisted / Closed"),
                LogEntry(timestamp: calendar.date(byAdding: .hour, value: -2, to: Date())!, appName: "TikTok", action: "App Opened", result: "Continued (15 min feed)"),
                LogEntry(timestamp: calendar.date(byAdding: .hour, value: -4, to: Date())!, appName: "YouTube", action: "App Opened", result: "Resisted / Closed")
            ]
        }
    }

    func logAction(appName: String, action: String, result: String) {
        let entry = LogEntry(timestamp: Date(), appName: appName, action: action, result: result)
        self.logHistory.insert(entry, at: 0)
        if self.logHistory.count > 30 {
            self.logHistory.removeLast()
        }
    }

    func resetState() {
        self.isOnboarded = false
        self.managedApps = ["Instagram", "TikTok", "Twitter / X", "YouTube", "Reddit"]
        self.pauseDuration = 10
        self.hasPremium = false
        self.streak = 3
        self.dailyScrollMinutes = 42
        self.longestSessionMinutes = 18
        self.nudgesTriggered = 12
        self.nudgesResisted = 5
        self.enableIntentionPrompt = true
        self.enableQuietHours = false
        self.quietHoursStart = "09:00"
        self.quietHoursEnd = "17:00"
        self.scrollSessions = [
            ScrollSession(startTime: "08:00", endTime: "08:30", isActive: true),
            ScrollSession(startTime: "12:00", endTime: "13:00", isActive: false),
            ScrollSession(startTime: "19:00", endTime: "20:00", isActive: true)
        ]
        self.logHistory = []
    }
}
