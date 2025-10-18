# Don't Be Late 🕐

**Never miss an important event again!** Don't Be Late is an intelligent iOS application designed specifically to combat the chronic lateness problem in Bucharest (and everywhere else!). The app seamlessly integrates with your calendar, blocks distracting apps before events, and uses real-time traffic data to ensure you're always on time.

## 🎯 The Problem

Everyone is late in Bucharest! Whether it's traffic, distractions, or poor time management, being late has become a cultural norm. **Let's change that.**

## ✨ Features

### 📅 Smart Calendar Sync
- Automatically syncs with your iOS Calendar
- Monitors all upcoming events in real-time
- Works with all calendar types (iCloud, Google, Exchange, etc.)

### 🚫 Intelligent App Blocking
- Block distracting apps before important events
- Customizable app list (Instagram, Facebook, Twitter, TikTok, etc.)
- Automatic blocking based on your schedule
- Blocks apps X minutes before events (user-configurable)

### 🚗 Traffic-Based Dynamic Timing
- Calculates real-time travel time to event locations
- Adjusts blocking time based on current traffic conditions
- Supports multiple transport types (car, walking, public transit)
- Adds buffer time for preparation

### 🔔 Smart Notifications
- Get notified before apps are blocked
- Traffic-aware alerts: "Time to leave now!"
- Clear messaging: "Event X starts soon. Your apps are blocked until you're ready."

### ⚙️ Highly Customizable
- Set default pre-event buffer time (5-60 minutes)
- Choose which apps to block
- Enable/disable traffic-based timing
- Select preferred transport type
- Toggle auto-blocking on/off

## 🏗️ Architecture

The app is built using modern iOS development best practices:

### Technology Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum iOS Version**: iOS 16.0
- **Architecture Pattern**: MVVM (Model-View-ViewModel)

### Key Frameworks
- **EventKit**: Calendar integration and event management
- **CoreLocation**: Location services and GPS
- **MapKit**: Route calculation and traffic data
- **UserNotifications**: Local notifications
- **FamilyControls**: App blocking (Screen Time API)
- **BackgroundTasks**: Background event monitoring

### Project Structure

```
DontBeLate/
├── DontBeLateApp/
│   ├── DontBeLateApp.swift          # App entry point
│   ├── ContentView.swift             # Main content router
│   │
│   ├── Models/                       # Data models
│   │   ├── AppState.swift           # Global app state
│   │   ├── Event.swift              # Event and blocking rule models
│   │   └── UserSettings.swift       # User preferences
│   │
│   ├── Services/                     # Business logic services
│   │   ├── CalendarService.swift    # Calendar integration
│   │   ├── LocationService.swift    # Location & routing
│   │   ├── NotificationService.swift # Notifications
│   │   └── AppBlockingService.swift # App blocking logic
│   │
│   ├── ViewModels/                   # View models
│   │   ├── EventMonitor.swift       # Event monitoring engine
│   │   ├── BackgroundTaskManager.swift # Background processing
│   │   └── HomeViewModel.swift      # Home screen logic
│   │
│   ├── Views/                        # SwiftUI views
│   │   ├── OnboardingView.swift     # First-time user experience
│   │   ├── HomeView.swift           # Main dashboard
│   │   ├── UpcomingEventsView.swift # Events list
│   │   ├── SettingsView.swift       # Settings screen
│   │   └── AppSelectorView.swift    # App selection interface
│   │
│   └── Info.plist                    # App configuration
│
├── DontBeLateApp.entitlements        # Required capabilities
└── README.md                          # This file
```

## 🚀 Getting Started

### Prerequisites

- macOS with Xcode 15.0 or later
- iOS 16.0+ target device or simulator
- Apple Developer Account (for Screen Time API)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/vladparau/DontBeLate.git
   cd DontBeLate
   ```

2. **Create the Xcode Project**
   
   The Swift source files are ready, but you need to create the Xcode project:
   
   **Follow the guide:** `CREATE_XCODE_PROJECT.md` (5 minutes)
   
   This will walk you through creating a new Xcode project and importing all the source files

3. **Configure Signing**
   - Select the project in Xcode's Project Navigator
   - Go to "Signing & Capabilities"
   - Select your Development Team
   - Ensure Bundle Identifier is unique (e.g., `com.yourname.dontbelate`)

4. **Add Required Capabilities**
   
   The following capabilities are already configured in the `.entitlements` file, but you may need to enable them in Xcode:
   
   - **Family Controls** (Required for app blocking)
     - In Xcode: Signing & Capabilities → "+" → Family Controls
   
   - **Background Modes**
     - Background fetch
     - Location updates
     - Background processing
   
   - **Push Notifications** (Optional)
     - For time-sensitive notifications

5. **Update Info.plist Strings** (Optional)
   
   Customize the permission request messages in `Info.plist` to match your branding.

6. **Build and Run**
   - Select your target device (iOS 16.0+)
   - Press `Cmd + R` or click the Run button
   - Grant permissions when prompted

## 📱 Usage

### First Launch - Onboarding

1. **Welcome Screen**: Learn about the app's features
2. **Permissions**: Grant required permissions:
   - Calendar Access
   - Location (When in Use)
   - Notifications
   - Screen Time (Family Controls)

### Main Interface

#### Home Tab
- View today's events
- See your next upcoming event
- Monitor active app blocks
- Quick refresh button

#### Events Tab
- Browse upcoming events (next 7 days)
- Events grouped by date
- View event details (time, location, calendar)

#### Settings Tab
- **General Settings**
  - Default Buffer Time: Time before events to start blocking
  - Auto Block Apps: Enable/disable automatic blocking
  
- **Traffic & Location**
  - Traffic-Based Timing: Use real-time traffic data
  - Transport Type: Car, Walking, or Public Transit
  
- **Blocked Apps**
  - Select apps to block from common list
  - Includes: Instagram, Facebook, Twitter, TikTok, etc.
  
- **Notifications**
  - Enable/disable notifications

### How It Works

1. **Event Detection**: The app monitors your calendar every 5 minutes
2. **Location Check**: If an event has a location, the app calculates travel time
3. **Traffic Analysis**: Real-time traffic data determines exact departure time
4. **App Blocking**: Apps are blocked at the calculated time
5. **Notification**: You receive a notification explaining the block
6. **Automatic Unblock**: Apps unblock when the event starts

### Example Scenarios

**Scenario 1: Meeting without location**
- Event: "Team Meeting" at 3:00 PM
- Default buffer: 15 minutes
- Result: Apps blocked at 2:45 PM

**Scenario 2: Meeting with location**
- Event: "Client Meeting" at 3:00 PM in Old Town
- Current location: Home (45 min drive in traffic)
- Traffic calculation: 45 minutes + 5 min buffer
- Result: Apps blocked at 2:10 PM

## ⚙️ Configuration

### Default Settings

```swift
// Default pre-event buffer time
defaultPreEventMinutes: 15

// Traffic calculation
enableTrafficCalculation: true
preferredTransportType: .automobile

// Auto-blocking
autoBlockEnabled: true

// Notifications
enableNotifications: true
```

### Customization

You can modify these defaults in `Models/UserSettings.swift`:

```swift
private init() {
    self.defaultPreEventMinutes = 15  // Change to your preference
    self.enableTrafficCalculation = true
    self.preferredTransportType = .automobile
    // ... other settings
}
```

## 🔧 Technical Details

### Calendar Integration

The app uses **EventKit** to access calendar events:

```swift
// Request calendar access
calendarService.requestAccess { granted, error in
    if granted {
        // Fetch events
    }
}
```

### Location & Traffic

**CoreLocation** and **MapKit** calculate travel times:

```swift
// Calculate travel time with traffic
locationService.calculateTravelTimeWithTraffic(to: destination) { travelTime, error in
    // Adjust blocking time based on traffic
}
```

### App Blocking

Uses **Screen Time API** (Family Controls framework):

```swift
// Block apps (requires Screen Time permission)
let store = ManagedSettingsStore()
store.shield.applications = blockedApps
```

⚠️ **Important**: App blocking requires:
- iOS 16.0+
- Family Controls entitlement
- User approval in Screen Time settings

### Background Monitoring

**BackgroundTasks** framework keeps the app updated:

```swift
// Register background task
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "com.dontbelate.eventcheck",
    using: nil
) { task in
    // Check for upcoming events
}
```

## 🎨 UI/UX Features

- **Modern SwiftUI Design**: Clean, intuitive interface
- **Dark Mode Support**: Fully compatible with iOS dark mode
- **Smooth Animations**: Polished transitions and interactions
- **Accessibility**: VoiceOver support and dynamic type
- **Responsive Layout**: Works on all iPhone sizes

## 🔒 Privacy & Permissions

### Required Permissions

1. **Calendar Access** (`NSCalendarsUsageDescription`)
   - Purpose: Read event details
   - Scope: Read-only access to all calendars

2. **Location** (`NSLocationWhenInUseUsageDescription`)
   - Purpose: Calculate travel time
   - Scope: Only when app is active or checking events

3. **Notifications** (`UNAuthorizationOptionAlert`)
   - Purpose: Alert before blocking apps
   - Scope: Local notifications only

4. **Family Controls** (`NSFamilyControlsUsageDescription`)
   - Purpose: Block distracting apps
   - Scope: User-selected apps only

### Data Privacy

- **No data collection**: All data stays on device
- **No analytics**: No tracking or telemetry
- **No server communication**: Completely offline app
- **Calendar data**: Never leaves your device
- **Location data**: Used only for routing calculations

## 🐛 Known Limitations

1. **Screen Time API Restrictions**
   - Requires iOS 16.0+
   - Must be approved by device owner
   - May not work in certain managed device configurations

2. **Background Refresh**
   - iOS may limit background refresh frequency
   - Events checked approximately every 15 minutes when backgrounded

3. **Traffic Calculation**
   - Requires events with structured locations
   - May not account for real-time incidents
   - Limited to Apple Maps data

4. **App Blocking**
   - Cannot block system apps (Phone, Messages, etc.)
   - Some apps may not be blockable due to iOS restrictions
   - Requires Screen Time to be enabled on device

## 🚧 Future Enhancements

### Planned Features

- [ ] Custom notification sounds
- [ ] Multiple pre-event reminders
- [ ] Calendar-specific settings
- [ ] Commute pattern learning
- [ ] Apple Watch companion app
- [ ] Shortcuts integration
- [ ] Focus mode integration
- [ ] Widget support
- [ ] Alternative route suggestions
- [ ] Historical lateness tracking
- [ ] Social features (share event status)

### Under Consideration

- [ ] Support for recurring event patterns
- [ ] Integration with ride-sharing apps (Uber, Lyft)
- [ ] Public transit schedules integration
- [ ] Weather-based time adjustments
- [ ] Parking time calculation
- [ ] Multi-language support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Guidelines

1. Follow Swift API Design Guidelines
2. Use SwiftUI for all UI components
3. Maintain MVVM architecture
4. Add comments for complex logic
5. Test on multiple iOS versions
6. Ensure accessibility compliance

### Testing

Before submitting a PR:
- Test on iOS 16.0+
- Verify all permissions work correctly
- Check background task execution
- Validate traffic calculations
- Ensure app blocking functions properly

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Vlad Parau**
- GitHub: [@vladparau](https://github.com/vladparau)
- Project: [DontBeLate](https://github.com/vladparau/DontBeLate)

## 🙏 Acknowledgments

- Built for the people of Bucharest who want to break the cycle of lateness
- Inspired by the need for better time management tools
- Uses Apple's EventKit, CoreLocation, and Screen Time frameworks

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Known Limitations](#-known-limitations) section
2. Review the [Technical Details](#-technical-details)
3. Open an issue on GitHub
4. Contact via GitHub profile

## 🎉 Let's End Lateness Together!

Download, build, and help make Bucharest (and the world) more punctual, one event at a time!

---

**Built with ❤️ in Bucharest to solve Bucharest's lateness problem**

