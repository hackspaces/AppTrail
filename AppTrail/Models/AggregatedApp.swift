import Foundation
import SwiftUI
import AppKit

struct AggregatedApp: Identifiable {
    let id = UUID()
    let appName: String
    let bundleID: String
    let totalDuration: TimeInterval
    let icon: NSImage?

    var durationString: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        let seconds = Int(totalDuration) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var color: Color {
        Color(hue: Double(abs(bundleID.hashValue) % 360) / 360.0, saturation: 0.6, brightness: 0.85)
    }

    var percentage: Double {
        0 // Will be calculated in view
    }
}
