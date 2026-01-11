import SwiftUI
import AppKit

struct MenuView: View {
    @ObservedObject var tracker: AppTracker

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()

            if tracker.segments.isEmpty {
                emptyStateView
            } else {
                timelineSection
                Divider()
                statsView
            }

            Divider()
            footerView
        }
        .frame(width: 360)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var headerView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.purple)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Focus")
                    .font(.system(size: 14, weight: .semibold))
                Text(dateString)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: { tracker.clearHistory() }) {
                Text("Clear")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(nsColor: .separatorColor).opacity(0.3))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TimelineBarView(
                segments: tracker.segments,
                onSegmentTap: { bundleID in
                    tracker.activateApp(bundleID: bundleID)
                }
            )

            // Aggregated time by app
            if !tracker.aggregatedByApp.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Time by App")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text("Total: \(tracker.totalTrackedTimeString)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(tracker.aggregatedByApp) { app in
                                AggregatedAppRow(
                                    app: app,
                                    totalTime: tracker.totalTrackedTime
                                ) {
                                    tracker.activateApp(bundleID: app.bundleID)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 180)
                }
            }
        }
        .padding(16)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: "hourglass")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 4) {
                Text("Tracking Started")
                    .font(.system(size: 14, weight: .semibold))
                Text("Switch between apps to see your timeline")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var statsView: some View {
        HStack(spacing: 20) {
            StatBox(title: "Current", value: tracker.currentApp, icon: "app.fill")
            Divider().frame(height: 36)
            StatBox(title: "Switches", value: "\(tracker.switchCount)", icon: "arrow.left.arrow.right")
            Divider().frame(height: 36)
            StatBox(title: "Apps", value: "\(uniqueAppCount)", icon: "square.stack.3d.up")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var footerView: some View {
        HStack {
            Button(action: { tracker.clearHistory() }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11, weight: .medium))
                    Text("Reset")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: { NSApp.terminate(nil) }) {
                HStack(spacing: 6) {
                    Image(systemName: "power")
                        .font(.system(size: 11, weight: .medium))
                    Text("Quit")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(nsColor: .separatorColor).opacity(0.2))
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var uniqueAppCount: Int {
        Set(tracker.segments.map { $0.bundleID }).count
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)

            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AggregatedAppRow: View {
    let app: AggregatedApp
    let totalTime: TimeInterval
    let onTap: () -> Void

    @State private var isHovered = false

    private var percentage: Double {
        guard totalTime > 0 else { return 0 }
        return (app.totalDuration / totalTime) * 100
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 20, height: 20)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(app.color)
                        .frame(width: 20, height: 20)
                }

                Text(app.appName)
                    .font(.system(size: 12))
                    .lineLimit(1)

                Spacer()

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(nsColor: .separatorColor).opacity(0.3))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(app.color)
                            .frame(width: geo.size.width * (percentage / 100))
                    }
                }
                .frame(width: 50, height: 6)

                Text(app.durationString)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 55, alignment: .trailing)

                Text("\(Int(percentage))%")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .frame(width: 30, alignment: .trailing)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.5) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    MenuView(tracker: AppTracker())
        .frame(width: 360, height: 480)
}
