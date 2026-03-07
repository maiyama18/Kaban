# Kaban

A reusable SwiftUI component & design system library for iOS apps. Swift Package (swift-tools-version 6.2, iOS 26+/macOS 26+).

## Build

```
xcodebuild build -scheme Kaban -destination 'generic/platform=iOS'
```

`swift build` does not work — use xcodebuild only.

## Project Structure

```
Sources/Kaban/
├── DesignSystem/     # KabanColor, KabanFont, KabanAccentColor, KabanColor+View
├── ButtonStyles/     # KabanPrimaryButtonStyle, KabanSecondaryButtonStyle
├── Components/       # AsyncButton, SafariScreen, ActivityScreen, PlaceholderTextEditor, LoadingStateView
├── Modifiers/        # OnFirstAppearModifier, OnForegroundModifier, OnBackgroundModifier, OnShakeModifier
├── Navigation/       # NavigationFlow, NavigationFlowContainer, PresentableAlert
├── Utilities/        # LoadingState, ConcurrencyUtils, Bundle+Extension
└── Resources/        # Colors.xcassets, Localizable.xcstrings
```

## Conventions

### Visibility
- Mark `private` when possible
- Write `internal` explicitly (never implicit)
- Write `public` on each member — do NOT use `public extension` pattern
- Properties only used within the module should be `internal`, not `public`

### Naming
- Prefix public types with `Kaban` (e.g., `KabanColor`, `KabanFont`)
- ViewModifier structs: prefix with `On` when wrapping lifecycle events (e.g., `OnFirstAppearModifier`)
- UIViewControllerRepresentable wrappers: suffix with `Screen` (e.g., `SafariScreen`)
- ButtonStyle types: `Kaban{Variant}ButtonStyle` with static shorthand `.kaban{variant}`

### Colors
- Always use `KabanColor` — never raw `Color` or `Color(.system*)` in library code
- Accent color flows through `@Environment(\.kabanAccentColor)` as `KabanColor`
- Add new colors as ColorResource in `Resources/Colors.xcassets`, then expose via `KabanColor` static property

### Fonts
- `KabanFont` defines size/weight/relativeTo/lineSpacing; `KabanFontModifier` uses `@ScaledMetric` for Dynamic Type
- Apply via `View.kabanTextStyle(_:color:)` — `color` parameter has no default value (must be explicit)
- Use `kabanForegroundStyle(_:)` / `kabanTint(_:)` for color-only styling

### Localization
- Use String Catalog (`.xcstrings`) in `Sources/Kaban/Resources/`
- Set `"extractionState": "manual"` and use snake_case keys for symbol generation
- Reference via generated symbols: `Text(.retry)` (not `String(localized:bundle:)`)

### Previews
- Add `#Preview` for visual components (buttons, styles, views)
- For components using accent color, add a second `#Preview("Accent: Blue")` with `.environment(\.kabanAccentColor, .accentBlue)`

### File Organization
- One component/modifier/style per file
- File name matches the primary type name
- All resources go under `Sources/Kaban/Resources/` (single directory)
