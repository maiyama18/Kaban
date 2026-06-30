# Kaban

A reusable SwiftUI component and design system library for iOS apps.

## Setup

```swift
.package(url: "https://github.com/maiyama18/Kaban.git", from: "0.1.0")
```

## Usage

### Accent Color

Kaban uses `.accentOrange` by default. Set `kabanAccentColor` on a parent view to change button and component accent colors.

```swift
import SwiftUI
import Kaban

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.kabanAccentColor, .accentBlue)
        }
    }
}
```

Available accent colors:

```swift
.accentPink
.accentOrange
.accentYellow
.accentGreen
.accentTeal
.accentBlue
.accentPurple
```

### Text and Colors

```swift
Text("Hello")
    .kabanTextStyle(.bodyLarge(weight: .semibold), color: .textPrimary)

Image(systemName: "checkmark.circle.fill")
    .kabanForegroundStyle(.accentGreen)
```

### Buttons

```swift
Button("Continue") {
    // Handle tap
}
.buttonStyle(.kabanPrimary(shape: .roundedRectangle))

Button("Cancel") {
    // Handle tap
}
.buttonStyle(.kabanSecondary(shape: .capsule))
```

## Features

- **DesignSystem** — `KabanColor`, `KabanFont`, accent color management
- **ButtonStyles** — Primary / Secondary button styles
- **Components** — `AsyncButton`, `LoadingStateView`, `PlaceholderTextEditor`, `SafariScreen`, `ActivityScreen`
- **Modifiers** — `onFirstAppear`, `onForeground`, `onBackground`, `onShake`
- **Navigation** — `NavigationFlow`, `NavigationFlowContainer`, `PresentableAlert`
- **Utilities** — `LoadingState`, `withRetry`, `withTimeout`, `Bundle.appVersionText`
