import Foundation
import AppKit

struct AppSwitch: Identifiable, Equatable {
    let id: UUID
    let appName: String
    let bundleID: String
    let timestamp: Date
    let icon: NSImage?

    init(appName: String, bundleID: String, timestamp: Date = Date(), icon: NSImage? = nil) {
        self.id = UUID()
        self.appName = appName
        self.bundleID = bundleID
        self.timestamp = timestamp
        self.icon = icon
    }

    static func == (lhs: AppSwitch, rhs: AppSwitch) -> Bool {
        lhs.id == rhs.id
    }
}
