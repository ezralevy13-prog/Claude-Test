# NWS Forecast - iOS App

A minimal native iOS app that displays Area Forecast Discussions (AFD) from the National Weather Service.

## Features

- **Automatic Location Detection**: Uses CoreLocation to detect your location and show relevant forecasts
- **Manual Search**: Search for any location using the built-in search bar
- **Clean, Native UI**: SwiftUI interface following iOS Human Interface Guidelines
- **Offline Support**: Caches the last forecast for offline viewing
- **Pull-to-Refresh**: Swipe down to refresh the forecast
- **Expandable Sections**: Tap section headers to expand/collapse content
- **Text Selection**: Long-press on forecast text to select and copy
- **Share**: Export the full forecast as plain text

## Requirements

- Xcode 15.0 or later
- iOS 17.0 or later
- macOS Ventura or later (for development)

## Setup Instructions

### Option 1: Create New Xcode Project

1. **Open Xcode** and create a new project:
   - File → New → Project
   - Choose "iOS" → "App"
   - Click "Next"

2. **Configure your project**:
   - Product Name: `NWSForecast`
   - Team: Select your development team
   - Organization Identifier: `com.yourname` (use your own)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: None
   - Uncheck "Include Tests"
   - Click "Next" and choose a location

3. **Delete default files**:
   - In the Project Navigator, delete:
     - `ContentView.swift` (we'll replace it)
     - `NWSForecastApp.swift` (we'll replace it)
   - Move them to Trash when prompted

4. **Add source files**:
   - Drag the entire `NWSForecast` folder from this repository into your Xcode project
   - In the dialog that appears:
     - Check "Copy items if needed"
     - Select "Create groups"
     - Ensure your app target is checked
     - Click "Finish"

5. **Update Info.plist**:
   - In Project Navigator, select your project (top blue icon)
   - Select the app target under "TARGETS"
   - Go to the "Info" tab
   - Add a new key: `Privacy - Location When In Use Usage Description`
   - Set value to: `We need your location to show the forecast discussion for your area.`

   Or replace the entire Info.plist:
   - Right-click `Info.plist` in Project Navigator
   - Choose "Open As" → "Source Code"
   - Replace contents with the `Info.plist` from this repository

6. **Configure build settings**:
   - Select your project in Project Navigator
   - Select the app target
   - Go to "Signing & Capabilities"
   - Check "Automatically manage signing"
   - Select your Team

7. **Build and Run**:
   - Select a simulator or your device
   - Press Cmd+R or click the Play button
   - When prompted, allow location access to test auto-detection

### Option 2: Command Line Setup (Advanced)

If you prefer using the command line:

```bash
# Create a new directory for your Xcode project
mkdir -p ~/NWSForecastProject
cd ~/NWSForecastProject

# Copy the source files
cp -r /path/to/nws-forecast-ios/NWSForecast .
cp /path/to/nws-forecast-ios/Info.plist .

# Open Xcode and create a new project in this directory
# Then add the files as described in Option 1, step 4
```

## Project Structure

```
NWSForecast/
├── NWSForecastApp.swift          # App entry point
├── ContentView.swift             # Main UI view
├── Models/
│   └── NWSModels.swift          # Data models for NWS API responses
├── Services/
│   ├── NWSService.swift         # NWS API networking layer
│   └── LocationManager.swift    # CoreLocation wrapper
├── ViewModels/
│   └── WeatherViewModel.swift   # Main view model with business logic
└── Utilities/
    └── AFDParser.swift          # Text parsing and cleaning
```

## How It Works

### Data Flow

1. **Location → Coordinates**
   - App requests location permission
   - If granted: uses CoreLocation to get coordinates
   - If denied: falls back to San Francisco (37.7749, -122.4194)

2. **Coordinates → WFO Code**
   - Calls `https://api.weather.gov/points/{lat},{lon}`
   - Extracts Weather Forecast Office (WFO) code from response

3. **WFO → Latest AFD Product**
   - Calls `https://api.weather.gov/products/types/AFD/locations/{WFO}`
   - Gets the most recent AFD product ID

4. **Product ID → Full Text**
   - Calls `https://api.weather.gov/products/{id}`
   - Retrieves complete AFD text

5. **Parse & Display**
   - `AFDParser` cleans the raw text
   - Extracts sections (Synopsis, Near Term, Long Term, etc.)
   - Displays in expandable sections

### Key Components

**WeatherViewModel**
- Manages all app state
- Coordinates location, API calls, and caching
- Implements offline support via UserDefaults
- Handles background refresh when cached data is shown

**NWSService**
- Async/await networking with URLSession
- Proper error handling and retries
- Custom User-Agent header for NWS API compliance

**LocationManager**
- Wraps CoreLocation APIs
- Publishes location updates via Combine
- Handles permissions gracefully
- Provides geocoding for search functionality

**AFDParser**
- Strips header codes and metadata
- Identifies common section headers
- Converts excessive ALL CAPS to sentence case
- Preserves acronyms and technical terms

**ContentView**
- Native SwiftUI components
- Supports Dynamic Type (accessibility)
- Pull-to-refresh gesture
- Searchable interface
- System share sheet integration

## Usage

### First Launch
1. App will request location permission
2. Tap "Allow While Using App" for auto-detection
3. Or tap "Don't Allow" to use San Francisco as default

### Searching for Locations
1. Tap the search icon (magnifying glass) in the top-left
2. Type a city name or address (e.g., "Seattle, WA")
3. Press Enter/Return
4. The forecast will update for that location

### Refreshing
- **Pull down** on the forecast to refresh
- **Tap the location name** to refresh your current location
- Tap the **refresh arrow** next to the location name

### Reading Forecasts
- Tap any section header to expand/collapse
- Long-press text to select and copy portions
- Tap the **share icon** in top-right to export entire forecast

### Offline Mode
- Last forecast is cached automatically
- Shows "Offline" badge when using cached data
- Refreshes in background when connection returns

## Customization

### Change Default Location
Edit `LocationManager.swift:25`:
```swift
static let defaultLocation = CLLocationCoordinate2D(
    latitude: 37.7749,  // Your latitude
    longitude: -122.4194 // Your longitude
)
```

### Adjust Cache Duration
Cached data persists until next successful refresh. To add expiration, modify `WeatherViewModel.loadCachedData()`.

### Add Dark Mode Support
The app already supports system dark mode automatically via SwiftUI's adaptive color system.

### Modify Section Parsing
Edit `AFDParser.swift:17` to add custom section patterns:
```swift
let sectionPatterns = [
    "SYNOPSIS",
    "YOUR CUSTOM SECTION",
    // ... more patterns
]
```

## Troubleshooting

### "No forecast available"
- Check your internet connection
- Verify the location has NWS coverage (US only)
- Try a different location

### Location not updating
- Check Settings → Privacy & Security → Location Services
- Ensure NWSForecast has "While Using" permission
- Try tapping the location name to refresh

### Build errors in Xcode
- Ensure deployment target is iOS 17.0 or later
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
- Restart Xcode

### Parsing issues
- Some AFD formats vary by office
- Open an issue with the problematic WFO code
- Cached forecast may show old format after updates

## API Reference

All NWS API endpoints used:

1. **Points API**: `GET https://api.weather.gov/points/{lat},{lon}`
   - Returns: WFO code, zone info, relative location

2. **Products List**: `GET https://api.weather.gov/products/types/AFD/locations/{WFO}`
   - Returns: Array of recent AFD product IDs

3. **Product Detail**: `GET https://api.weather.gov/products/{productId}`
   - Returns: Full AFD text and metadata

All requests include `User-Agent: NWSForecastApp/1.0` header as required by NWS API guidelines.

## Privacy

- Location data never leaves your device
- No analytics or tracking
- No network requests except to api.weather.gov
- Cached data stored locally in UserDefaults

## License

This is personal-use software. Not intended for App Store distribution.

## Credits

- Forecast data: [National Weather Service](https://www.weather.gov)
- NWS API: [weather.gov/documentation/services-web-api](https://www.weather.gov/documentation/services-web-api)
