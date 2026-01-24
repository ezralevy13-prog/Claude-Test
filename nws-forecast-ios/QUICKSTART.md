# Quick Start Guide

Get up and running with the NWS Forecast iOS app in 5 minutes.

## Prerequisites

- Mac with macOS Ventura or later
- Xcode 15.0 or later (free from Mac App Store)
- Apple ID (free, for code signing)

## Steps

### 1. Open Xcode

Launch Xcode from Applications or Spotlight.

### 2. Create New Project

1. File → New → Project (or Cmd+Shift+N)
2. Choose **iOS** → **App**
3. Click **Next**

### 3. Configure Project

- **Product Name**: `NWSForecast`
- **Team**: Select your Apple ID
- **Organization Identifier**: `com.yourname` (replace "yourname")
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- Click **Next**, choose where to save, click **Create**

### 4. Delete Default Files

In Project Navigator (left sidebar):
- Right-click `ContentView.swift` → Delete → Move to Trash
- Right-click `NWSForecastApp.swift` → Delete → Move to Trash

### 5. Add Source Code

**Drag and drop** the `NWSForecast` folder from this repository into your Xcode project:

1. Open Finder, navigate to `nws-forecast-ios/NWSForecast/`
2. Select the entire `NWSForecast` folder
3. Drag it into Xcode's Project Navigator (left sidebar)
4. In the dialog:
   - ✅ Check "Copy items if needed"
   - ✅ Select "Create groups"
   - ✅ Ensure your target is checked
   - Click **Finish**

Your project structure should look like:
```
NWSForecast
├── NWSForecastApp.swift
├── ContentView.swift
├── Models/
├── Services/
├── ViewModels/
└── Utilities/
```

### 6. Add Location Permission

1. Click the **blue project icon** at the top of Project Navigator
2. Select the **NWSForecast** target (under TARGETS)
3. Click the **Info** tab
4. Hover over any row and click the **+** button
5. Start typing "Privacy - Location When"
6. Select **Privacy - Location When In Use Usage Description**
7. Double-click the "Value" column
8. Enter: `We need your location to show the forecast discussion for your area.`

### 7. Set Deployment Target

1. Still in the project settings
2. Go to **General** tab
3. Under "Minimum Deployments", ensure **iOS 17.0** or later

### 8. Run the App

1. Select a simulator from the device menu (e.g., "iPhone 15 Pro")
2. Press **Cmd+R** or click the ▶️ Play button
3. Wait for the simulator to boot and the app to install

### 9. Test the App

1. When prompted, tap **"Allow While Using App"** for location access
2. Wait a few seconds for the forecast to load
3. Try tapping section headers to collapse/expand
4. Pull down to refresh
5. Tap the search icon to search for other locations

## Troubleshooting

**"Cannot find 'AFDParser' in scope"**
- Make sure you dragged the entire `NWSForecast` folder, not individual files
- Check that all folders (Models, Services, etc.) are visible in Project Navigator

**"No such module 'CoreLocation'"**
- This should never happen with iOS 17+, but if it does: Project Settings → General → Frameworks, Libraries → Add CoreLocation.framework

**"Signing for 'NWSForecast' requires a development team"**
- Project Settings → Signing & Capabilities → Team → Select your Apple ID
- If you don't see your Apple ID: Xcode → Settings → Accounts → Add Apple ID

**Simulator is slow**
- First launch is always slow
- Try a different simulator (iPhone 15 is fast)
- Close other apps to free up RAM

**Location always shows San Francisco**
- Simulator → Features → Location → Custom Location
- Or: Deny location permission to test fallback behavior

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Customize the default location
- Try running on your physical iPhone (requires free Apple Developer account)
- Explore the code to learn SwiftUI and async/await patterns

## Need Help?

1. Check the [README.md](README.md) troubleshooting section
2. Search for error messages in Xcode's issue navigator (⌘5)
3. Clean build folder: Product → Clean Build Folder (⇧⌘K)
4. Restart Xcode

Enjoy your weather forecasts! 🌤️
