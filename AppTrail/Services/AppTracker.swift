import Foundation
import AppKit
import Combine

final class AppTracker: ObservableObject {
    @Published private(set) var history: [AppSwitch] = []
    @Published private(set) var segments: [TimelineSegment] = []
    @Published private(set) var currentApp: String = ""
    @Published private(set) var currentBundleID: String = ""
    @Published private(set) var switchCount: Int = 0

    private var currentSegmentStart: Date?
    private var cancellables = Set<AnyCancellable>()

    var dayStartTime: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var totalTrackedTime: TimeInterval {
        segments.reduce(0) { $0 + $1.duration }
    }

    var aggregatedByApp: [AggregatedApp] {
        var appTotals: [String: (name: String, bundleID: String, duration: TimeInterval, icon: NSImage?)] = [:]

        for segment in segments {
            if var existing = appTotals[segment.bundleID] {
                existing.duration += segment.duration
                appTotals[segment.bundleID] = existing
            } else {
                appTotals[segment.bundleID] = (segment.appName, segment.bundleID, segment.duration, segment.icon)
            }
        }

        return appTotals.values
            .map { AggregatedApp(appName: $0.name, bundleID: $0.bundleID, totalDuration: $0.duration, icon: $0.icon) }
            .sorted { $0.totalDuration > $1.totalDuration }
    }

    var totalTrackedTimeString: String {
        formatDuration(totalTrackedTime)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    init() {
        setupNotifications()
        recordCurrentApp()
    }

    private func setupNotifications() {
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleAppActivation(notification)
            }
            .store(in: &cancellables)
    }

    private let selfBundleID = "com.yash.AppTrail"

    private func handleAppActivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let appName = app.localizedName,
              let bundleID = app.bundleIdentifier else {
            return
        }

        // Don't track AppTrail itself
        guard bundleID != selfBundleID else { return }

        // Don't record if same app
        guard bundleID != currentBundleID else { return }

        // Close current segment
        closeCurrentSegment()

        // Record the switch
        let icon = app.icon
        let appSwitch = AppSwitch(appName: appName, bundleID: bundleID, icon: icon)
        history.append(appSwitch)
        switchCount += 1

        // Start new segment
        currentApp = appName
        currentBundleID = bundleID
        currentSegmentStart = Date()

        let newSegment = TimelineSegment(
            appName: appName,
            bundleID: bundleID,
            startTime: currentSegmentStart!,
            icon: icon
        )
        segments.append(newSegment)
    }

    private func closeCurrentSegment() {
        guard !segments.isEmpty else { return }
        let lastIndex = segments.count - 1
        segments[lastIndex].endTime = Date()
    }

    private func recordCurrentApp() {
        guard let frontApp = NSWorkspace.shared.frontmostApplication,
              let appName = frontApp.localizedName,
              let bundleID = frontApp.bundleIdentifier else {
            return
        }

        currentApp = appName
        currentBundleID = bundleID
        currentSegmentStart = Date()

        let segment = TimelineSegment(
            appName: appName,
            bundleID: bundleID,
            startTime: currentSegmentStart!,
            icon: frontApp.icon
        )
        segments.append(segment)
    }

    func updateCurrentSegment() {
        guard !segments.isEmpty else { return }
        let lastIndex = segments.count - 1
        segments[lastIndex].endTime = Date()
    }

    func clearHistory() {
        history.removeAll()
        segments.removeAll()
        switchCount = 0
        recordCurrentApp()
    }

    func activateApp(bundleID: String) {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first else {
            // App not running, try to launch it
            NSWorkspace.shared.launchApplication(
                withBundleIdentifier: bundleID,
                options: [],
                additionalEventParamDescriptor: nil,
                launchIdentifier: nil
            )
            return
        }
        app.activate(options: [.activateIgnoringOtherApps])
    }
}
