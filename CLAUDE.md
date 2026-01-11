# AppTrail

macOS menu bar app that tracks application switches with a visual timeline.

## Quick Start for Agents

Run these checks before installing:

```bash
# Check macOS version (needs 14.0+)
sw_vers -productVersion

# Check if XcodeGen is installed
which xcodegen || echo "Install with: brew install xcodegen"

# Check if Xcode CLI tools are available
xcode-select -p
```

## Install Steps

```bash
# 1. Generate the Xcode project
xcodegen generate

# 2. Build the app
xcodebuild -scheme AppTrail -configuration Release build

# 3. Copy to Applications
cp -r ~/Library/Developer/Xcode/DerivedData/AppTrail-*/Build/Products/Release/AppTrail.app /Applications/

# 4. Launch
open /Applications/AppTrail.app
```

## Project Structure

```
AppTrail/
├── project.yml          # XcodeGen config
├── AppTrail/
│   ├── Info.plist       # App config (LSUIElement=true for menu bar)
│   ├── AppTrail.entitlements
│   ├── AppTrailApp.swift
│   ├── AppDelegate.swift
│   ├── Models/
│   │   ├── AppSwitch.swift
│   │   └── TimelineSegment.swift
│   ├── Services/
│   │   └── AppTracker.swift
│   └── Views/
│       ├── MenuView.swift
│       └── TimelineBarView.swift
```

## Tech Stack

- Swift 5.9, SwiftUI, AppKit
- macOS 14.0+ (Sonoma)
- Uses NSWorkspace.didActivateApplicationNotification
- Click timeline segments to switch apps

## Verify It Works

After launching, switch between a few apps. Click the menu bar icon to see the timeline showing colored blocks for each app you used.
