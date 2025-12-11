# Device Wrapper

[![pub package](https://img.shields.io/pub/v/device_wrapper.svg)](https://pub.dev/packages/device_wrapper)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter package to wrap pages with realistic device frames (iPhone, Samsung Galaxy, iPad, Galaxy Tab, MacBook, Surface, Apple Watch) for web/desktop preview. Features auto-scaling, status bar, orientation change, dark/light themes, screenshots, and keyboard shortcuts.

## Features

- 📱 **8 Device Options**: iPhone 16 Pro, Galaxy S25, iPad Pro, Galaxy Tab S9, MacBook Pro, Surface Pro, Apple Watch, and Screen Only mode
- 🏝️ **Dynamic Island**: Modern iPhone-style Dynamic Island with camera lens effect
- ⚫ **Punch-Hole Camera**: Samsung-style centered punch-hole camera for Galaxy devices
- 💻 **Desktop Devices**: MacBook Pro and Surface Pro with realistic laptop body frames
- ⌚ **Apple Watch**: Watch frame with Digital Crown, side button, and watch bands
- 📊 **Status Bar**: iOS/Android style status bar with time, signal, WiFi, and battery
- 🔄 **Orientation**: Portrait/landscape rotation with proper notch/camera positioning
- 🎨 **Themes**: Light (white) and Dark (gray) theme modes
- 📸 **Screenshots**: Capture device frame as image
- ⌨️ **Keyboard Shortcuts**: Full keyboard control for all features
- 📐 **Auto-Scaling**: Automatically scales device to fit any screen size
- 📲 **Mobile Device Support**: Smart detection with optional toggle
- 🖥️ **Screen Only Mode**: Display just the screen without device frame
- 🎬 **Smooth Animations**: Animated transitions when switching modes

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  device_wrapper: ^1.2.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

Wrap your MaterialApp with `DeviceWrapper` for web preview:

```dart
import 'package:device_wrapper/device_wrapper.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DeviceWrapper(
        initialMode: DeviceMode.iphone,
        showModeToggle: true,
        child: MyHomePage(),
      ),
    );
  }
}
```

### With All Features

```dart
DeviceWrapper(
  initialMode: DeviceMode.iphone,
  showModeToggle: true,
  initialTheme: WrapperTheme.light,
  initialOrientation: DeviceOrientation.portrait,
  onModeChanged: (mode) {
    print('Device mode changed to: ${mode.displayName}');
  },
  onScreenshot: (image) {
    print('Screenshot taken: ${image.width}x${image.height}');
  },
  child: MyApp(),
)
```

### Custom Device Configuration

```dart
DeviceWrapper(
  initialMode: DeviceMode.iphone,
  mobileConfig: DeviceConfig(
    width: 375,
    height: 812,
    borderRadius: 44.0,
    borderWidth: 5.0,
    borderColor: Colors.black,
    showNotch: true,
    showHomeIndicator: true,
  ),
  child: MyApp(),
)
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+S` | Take screenshot |
| `Ctrl+Shift+R` | Rotate device (portrait/landscape) |
| `Ctrl+Shift+T` | Toggle theme (light/dark) |
| `Ctrl+Shift+D` | Toggle device/screen mode |
| `Ctrl+Shift+W` | Toggle wrapper visibility |
| `Ctrl+Shift+1` | Select iPhone |
| `Ctrl+Shift+2` | Select Galaxy S25 |
| `Ctrl+Shift+3` | Select iPad |
| `Ctrl+Shift+4` | Select Galaxy Tab |
| `Ctrl+Shift+5` | Select MacBook |
| `Ctrl+Shift+6` | Select Surface |
| `Ctrl+Shift+7` | Select Apple Watch |

## API Reference

### DeviceWrapper

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | required | The widget to wrap inside the device frame |
| `initialMode` | `DeviceMode` | `DeviceMode.iphone` | Initial device mode |
| `showModeToggle` | `bool` | `true` | Whether to show the mode toggle button |
| `initialTheme` | `WrapperTheme` | `WrapperTheme.light` | Initial theme (light/dark) |
| `initialOrientation` | `DeviceOrientation` | `DeviceOrientation.portrait` | Initial orientation |
| `mobileConfig` | `DeviceConfig?` | `null` | Custom configuration for mobile mode |
| `tabletConfig` | `DeviceConfig?` | `null` | Custom configuration for tablet mode |
| `onModeChanged` | `ValueChanged<DeviceMode>?` | `null` | Callback when device mode changes |
| `onScreenshot` | `ValueChanged<ui.Image>?` | `null` | Callback when screenshot is taken |
| `enabled` | `bool` | `true` | Whether the wrapper is enabled |
| `backgroundColor` | `Color?` | `null` | Background color for the area outside the device |
| `mobileDeviceBehavior` | `MobileDeviceBehavior` | `showToggle` | Behavior when running on mobile devices |

### DeviceMode

```dart
enum DeviceMode {
  iphone,        // iPhone 16 Pro (393×852)
  samsungPhone,  // Samsung Galaxy S25 (384×832)
  ipad,          // iPad Pro 11" (834×1194)
  samsungTablet, // Samsung Galaxy Tab S9 (800×1280)
  macbook,       // MacBook Pro 14" (1512×982)
  surface,       // Microsoft Surface Pro (1368×912)
  appleWatch,    // Apple Watch Series 10 (198×242)
  screenOnly,    // Screen only without device frame
}
```

### WrapperTheme

```dart
enum WrapperTheme {
  light,  // Light theme with white background (default)
  dark,   // Dark theme with gray background
}
```

### DeviceOrientation

```dart
enum DeviceOrientation {
  portrait,   // Portrait mode (taller than wide)
  landscape,  // Landscape mode (wider than tall)
}
```

### MobileDeviceBehavior

```dart
enum MobileDeviceBehavior {
  alwaysShowFrame,  // Always show the device frame wrapper
  alwaysHideFrame,  // Always render child directly without frame
  showToggle,       // Show a toggle to let user choose (default)
}
```

### DeviceConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `width` | `double` | varies | Width of the device screen |
| `height` | `double` | varies | Height of the device screen |
| `devicePixelRatio` | `double` | varies | Device pixel ratio |
| `borderRadius` | `double` | varies | Border radius for the device frame |
| `borderWidth` | `double` | varies | Border width for the device frame |
| `borderColor` | `Color` | `Color(0xFF1C1C1E)` | Frame color |
| `backgroundColor` | `Color` | `Color(0xFF000000)` | Background color |
| `shadows` | `List<BoxShadow>` | default shadows | Shadow configuration |
| `showNotch` | `bool` | varies | Whether to show Dynamic Island/camera |
| `showHomeIndicator` | `bool` | varies | Whether to show the home indicator |
| `isSamsung` | `bool` | `false` | Whether this is a Samsung device |
| `isDesktop` | `bool` | `false` | Whether this is a desktop device |
| `isWatch` | `bool` | `false` | Whether this is a watch device |

## Device Specifications

| Device | Logical Resolution | Pixel Ratio | Aspect Ratio |
|--------|-------------------|-------------|--------------|
| iPhone 16 Pro | 393 × 852 | 3.0 | 9:19.5 |
| Galaxy S25 | 384 × 832 | 2.8125 | 9:19.5 |
| iPad Pro 11" | 834 × 1194 | 2.0 | ~1:1.43 |
| Galaxy Tab S9 | 800 × 1280 | 2.0 | 10:16 |
| MacBook Pro 14" | 1512 × 982 | 2.0 | ~1.54:1 |
| Surface Pro | 1368 × 912 | 2.0 | 3:2 |
| Apple Watch | 198 × 242 | 2.0 | ~1:1.22 |

## Bottom Toolbar Features

The bottom toolbar includes:
- **Screen/Device**: Toggle between screen-only and device frame modes
- **Portrait/Landscape**: Change device orientation
- **Light/Dark**: Switch between light and dark themes
- **Screenshot**: Capture the device frame as an image
- **Hide**: Hide the wrapper and show just your app

## Example

Check out the [example](example/) directory for a complete demo app showcasing all features.

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
