import SwiftUI
import AppKit

struct TimelineBarView: View {
    let segments: [TimelineSegment]
    let onSegmentTap: (String) -> Void

    @State private var hoveredSegment: UUID?

    private var totalDuration: TimeInterval {
        segments.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Time labels
            HStack {
                if let first = segments.first {
                    Text(formatTime(first.startTime))
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                Text(formatTime(Date()))
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            // Timeline bar
            GeometryReader { geometry in
                HStack(spacing: 1) {
                    ForEach(segments) { segment in
                        SegmentView(
                            segment: segment,
                            width: widthForSegment(segment, in: geometry.size.width),
                            isHovered: hoveredSegment == segment.id,
                            onTap: { onSegmentTap(segment.bundleID) }
                        )
                        .onHover { hovering in
                            hoveredSegment = hovering ? segment.id : nil
                        }
                    }
                }
            }
            .frame(height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            // Hover tooltip
            if let hovered = segments.first(where: { $0.id == hoveredSegment }) {
                HStack(spacing: 8) {
                    if let icon = hovered.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    Text(hovered.appName)
                        .font(.system(size: 11, weight: .medium))
                    Spacer()
                    Text(hovered.durationString)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text(hovered.timeRangeString)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    private func widthForSegment(_ segment: TimelineSegment, in totalWidth: CGFloat) -> CGFloat {
        guard totalDuration > 0 else { return 0 }
        let ratio = segment.duration / totalDuration
        let width = totalWidth * ratio - 1 // Account for spacing
        return max(width, 4) // Minimum width of 4px
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct SegmentView: View {
    let segment: TimelineSegment
    let width: CGFloat
    let isHovered: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Rectangle()
                    .fill(segment.color)
                    .opacity(isHovered ? 1.0 : 0.8)

                if width > 30, let icon = segment.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: width)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

#Preview {
    TimelineBarView(
        segments: [
            TimelineSegment(appName: "Chrome", bundleID: "com.google.Chrome", startTime: Date().addingTimeInterval(-3600)),
            TimelineSegment(appName: "Slack", bundleID: "com.tinyspeck.slackmacgap", startTime: Date().addingTimeInterval(-2400)),
            TimelineSegment(appName: "VS Code", bundleID: "com.microsoft.VSCode", startTime: Date().addingTimeInterval(-1200))
        ],
        onSegmentTap: { _ in }
    )
    .padding()
    .frame(width: 340)
}
