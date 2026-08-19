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

// Pazu the Red Panda Animation / Behavioral States
enum PazuState: String, Codable, CaseIterable {
    case idle = "Idle"
    case happy = "Happy"
    case proud = "Proud"
    case clumsy = "Clumsy"
    case sleeping = "Sleeping"
    case curious = "Curious"
    case excited = "Excited"
    case gentleDisappointment = "Gentle Disappointment"
    case meditating = "Meditating"
    case playing = "Playing"
    case eating = "Eating"
    case greeting = "Greeting"
    case watching = "Watching"
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

    @Published var tokens: Int {
        didSet { UserDefaults.standard.set(tokens, forKey: "tokens") }
    }

    @Published var selectedBonsaiSeason: String {
        didSet { UserDefaults.standard.set(selectedBonsaiSeason, forKey: "selectedBonsaiSeason") }
    }

    @Published var unlockedSeasons: [String] {
        didSet { UserDefaults.standard.set(unlockedSeasons, forKey: "unlockedSeasons") }
    }

    @Published var koiColor: String {
        didSet { UserDefaults.standard.set(koiColor, forKey: "koiColor") }
    }

    @Published var unlockedKoiColors: [String] {
        didSet { UserDefaults.standard.set(unlockedKoiColors, forKey: "unlockedKoiColors") }
    }

    @Published var simulatedDaysElapsed: Int {
        didSet { UserDefaults.standard.set(simulatedDaysElapsed, forKey: "simulatedDaysElapsed") }
    }

    @Published var checkedInCount: Int {
        didSet { UserDefaults.standard.set(checkedInCount, forKey: "checkedInCount") }
    }

    // Pazu Red Panda State
    @Published var currentPazuState: PazuState {
        didSet { UserDefaults.standard.set(currentPazuState.rawValue, forKey: "currentPazuState") }
    }

    @Published var pazuHat: String {
        didSet { UserDefaults.standard.set(pazuHat, forKey: "pazuHat") }
    }

    @Published var pazuGlasses: String {
        didSet { UserDefaults.standard.set(pazuGlasses, forKey: "pazuGlasses") }
    }

    @Published var pazuScarf: String {
        didSet { UserDefaults.standard.set(pazuScarf, forKey: "pazuScarf") }
    }

    @Published var pazuOutfit: String {
        didSet { UserDefaults.standard.set(pazuOutfit, forKey: "pazuOutfit") }
    }

    @Published var pazuAccessory: String {
        didSet { UserDefaults.standard.set(pazuAccessory, forKey: "pazuAccessory") }
    }

    @Published var unlockedPazuItems: [String] {
        didSet { UserDefaults.standard.set(unlockedPazuItems, forKey: "unlockedPazuItems") }
    }

    @Published var gardenTree: String {
        didSet { UserDefaults.standard.set(gardenTree, forKey: "gardenTree") }
    }

    @Published var gardenPond: String {
        didSet { UserDefaults.standard.set(gardenPond, forKey: "gardenPond") }
    }

    @Published var gardenStructure: String {
        didSet { UserDefaults.standard.set(gardenStructure, forKey: "gardenStructure") }
    }

    @Published var gardenAmbient: String {
        didSet { UserDefaults.standard.set(gardenAmbient, forKey: "gardenAmbient") }
    }

    @Published var unlockedGardenDecorations: [String] {
        didSet { UserDefaults.standard.set(unlockedGardenDecorations, forKey: "unlockedGardenDecorations") }
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
        self.managedApps = UserDefaults.standard.stringArray(forKey: "managedApps") ?? ["Instagram", "TikTok", "Twitter / X", "YouTube", "Reddit", "Snapchat"]
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

        self.tokens = UserDefaults.standard.object(forKey: "tokens") == nil ? 15 : UserDefaults.standard.integer(forKey: "tokens")
        self.selectedBonsaiSeason = UserDefaults.standard.string(forKey: "selectedBonsaiSeason") ?? "Spring"
        self.unlockedSeasons = UserDefaults.standard.stringArray(forKey: "unlockedSeasons") ?? ["Spring"]
        self.koiColor = UserDefaults.standard.string(forKey: "koiColor") ?? "Orange"
        self.unlockedKoiColors = UserDefaults.standard.stringArray(forKey: "unlockedKoiColors") ?? ["Orange"]
        self.simulatedDaysElapsed = UserDefaults.standard.object(forKey: "simulatedDaysElapsed") == nil ? 1 : UserDefaults.standard.integer(forKey: "simulatedDaysElapsed")
        self.checkedInCount = UserDefaults.standard.object(forKey: "checkedInCount") == nil ? 4 : UserDefaults.standard.integer(forKey: "checkedInCount")

        // Pazu & Garden State Initialization
        let pazuRaw = UserDefaults.standard.string(forKey: "currentPazuState") ?? "Idle"
        self.currentPazuState = PazuState(rawValue: pazuRaw) ?? .idle
        self.pazuHat = UserDefaults.standard.string(forKey: "pazuHat") ?? "None"
        self.pazuGlasses = UserDefaults.standard.string(forKey: "pazuGlasses") ?? "None"
        self.pazuScarf = UserDefaults.standard.string(forKey: "pazuScarf") ?? "None"
        self.pazuOutfit = UserDefaults.standard.string(forKey: "pazuOutfit") ?? "None"
        self.pazuAccessory = UserDefaults.standard.string(forKey: "pazuAccessory") ?? "None"
        self.unlockedPazuItems = UserDefaults.standard.stringArray(forKey: "unlockedPazuItems") ?? ["None"]

        self.gardenTree = UserDefaults.standard.string(forKey: "gardenTree") ?? "Cherry Blossom"
        self.gardenPond = UserDefaults.standard.string(forKey: "gardenPond") ?? "Small Pond"
        self.gardenStructure = UserDefaults.standard.string(forKey: "gardenStructure") ?? "None"
        self.gardenAmbient = UserDefaults.standard.string(forKey: "gardenAmbient") ?? "None"
        self.unlockedGardenDecorations = UserDefaults.standard.stringArray(forKey: "unlockedGardenDecorations") ?? ["Cherry Blossom", "Small Pond"]

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

    // Autonomous behavior decision machine with lower chance of clumsy (e.g. 5%)
    func updatePazuBehavior() {
        if streak == 0 {
            currentPazuState = .sleeping
        } else if streak >= 7 {
            currentPazuState = .proud
        } else {
            let roll = Double.random(in: 0...1)
            if roll < 0.05 { // Lower chance of clumsy (5% instead of 30%)
                currentPazuState = .clumsy
            } else if roll < 0.25 {
                currentPazuState = .playing
            } else if roll < 0.45 {
                currentPazuState = .curious
            } else if roll < 0.60 {
                currentPazuState = .eating
            } else if roll < 0.75 {
                currentPazuState = .meditating
            } else {
                currentPazuState = .idle
            }
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
        self.managedApps = ["Instagram", "TikTok", "Twitter / X", "YouTube", "Reddit", "Snapchat"]
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
        self.tokens = 15
        self.selectedBonsaiSeason = "Spring"
        self.unlockedSeasons = ["Spring"]
        self.koiColor = "Orange"
        self.unlockedKoiColors = ["Orange"]
        self.simulatedDaysElapsed = 1
        self.checkedInCount = 4
        self.currentPazuState = .idle
        self.pazuHat = "None"
        self.pazuGlasses = "None"
        self.pazuScarf = "None"
        self.pazuOutfit = "None"
        self.pazuAccessory = "None"
        self.unlockedPazuItems = ["None"]
        self.gardenTree = "Cherry Blossom"
        self.gardenPond = "Small Pond"
        self.gardenStructure = "None"
        self.gardenAmbient = "None"
        self.unlockedGardenDecorations = ["Cherry Blossom", "Small Pond"]
        self.scrollSessions = [
            ScrollSession(startTime: "08:00", endTime: "08:30", isActive: true),
            ScrollSession(startTime: "12:00", endTime: "13:00", isActive: false),
            ScrollSession(startTime: "19:00", endTime: "20:00", isActive: true)
        ]
        self.logHistory = []
    }
}
