import Foundation
import SwiftUI
import AppKit

struct TimelineSegment: Identifiable {
    let id: UUID
    let appName: String
    let bundleID: String
    let startTime: Date
    var endTime: Date
    let icon: NSImage?

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var color: Color {
        Color(hue: colorHue, saturation: 0.6, brightness: 0.85)
    }

    private var colorHue: Double {
        // Generate consistent color from bundle ID hash
        let hash = bundleID.hashValue
        return Double(abs(hash) % 360) / 360.0
    }

    var durationString: String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))

        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    init(appName: String, bundleID: String, startTime: Date, endTime: Date? = nil, icon: NSImage? = nil) {
        self.id = UUID()
        self.appName = appName
        self.bundleID = bundleID
        self.startTime = startTime
        self.endTime = endTime ?? Date()
        self.icon = icon
    }
}
