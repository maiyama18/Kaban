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

To use a color from the app's Asset Catalog, create a `KabanColor` from its SwiftUI `Color`. Light and dark appearances defined in the asset are preserved.

```swift
let appAccentColor = KabanColor(Color("AppAccent"))

ContentView()
    .environment(\.kabanAccentColor, appAccentColor)
```

### Text and Colors

```swift
Text("Hello")
    .kabanTextStyle(.bodyLarge(weight: .semibold), color: .textPrimary)

Image(systemName: "checkmark.circle.fill")
    .kabanForegroundStyle(.accentGreen)

RoundedRectangle(cornerRadius: 12)
    .shadow(color: KabanColor.accentBlue.color.opacity(0.2), radius: 8)
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

### Navigation

Sheets and full-screen covers receive their own `NavigationFlow`. Call `dismiss()`
on that child flow to close its presentation without depending on SwiftUI's
`@Environment(\.dismiss)`.

```swift
@Environment(NavigationFlow<Route, Sheet, FullScreen>.self) private var flow

Button("Close") {
    flow.dismiss()
}
```

## Features

- **DesignSystem** — `KabanColor`, `KabanFont`, accent color management
- **ButtonStyles** — Primary / Secondary button styles
- **Components** — `AsyncButton`, `LoadingStateView`, `PlaceholderTextEditor`, `SafariScreen`, `ActivityScreen`
- **Modifiers** — `onFirstAppear`, `onForeground`, `onBackground`, `onShake`
- **Navigation** — `NavigationFlow`, `NavigationFlowContainer`, `PresentableAlert`
- **Utilities** — `LoadingState`, `withRetry`, `withTimeout`, `Bundle.appVersionText`
