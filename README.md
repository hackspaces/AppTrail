# AppTrail

A macOS menu bar app that tracks application switches throughout the day with a visual timeline.

![Screenshot](screenshot.png)

## Features

- Visual timeline bar showing app usage throughout the day
- Aggregated time per app with percentages
- Click any app in the timeline to switch back to it
- Tracks total time and switch count
- Menu bar shows current app name

## Requirements

- macOS 14.0 (Sonoma) or later

## Building

1. Install XcodeGen: `brew install xcodegen`
2. Generate project: `xcodegen generate`
3. Open `AppTrail.xcodeproj` in Xcode
4. Build and run

## How It Works

Listens to `NSWorkspace.didActivateApplicationNotification` to detect app switches. Each switch is recorded as a timeline segment with start/end times, which are then visualized as colored blocks proportional to time spent.

## License

MIT
