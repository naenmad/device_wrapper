# Device Wrapper

[![pub package](https://img.shields.io/pub/v/device_wrapper.svg)](https://pub.dev/packages/device_wrapper)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter package to wrap pages with realistic device frames (iPhone 16 Pro, Samsung Galaxy S25, iPad Pro 11", Samsung Galaxy Tab S9) for web/desktop preview. Features auto-scaling to fit any screen size, Dynamic Island, punch-hole camera, and smooth mode switching animations.

## Features

- 📱 **5 Device Options**: iPhone, Samsung Galaxy S25, iPad, Galaxy Tab, and Screen Only mode
- 🏝️ **Dynamic Island**: Modern iPhone-style Dynamic Island with camera lens effect
- ⚫ **Punch-Hole Camera**: Samsung-style centered punch-hole camera for Galaxy devices
- 📐 **Auto-Scaling**: Automatically scales device to fit within browser/window size
- 🔄 **Mode Toggle**: Built-in animated toggle to switch between all device modes
- 📲 **Mobile Device Support**: Smart detection with optional toggle to show/hide device frame on real devices
- 🖥️ **Screen Only Mode**: Display just the screen without device frame for cleaner previews
- 🎨 **Titanium Frame**: Gradient frame design mimicking real device bezels
- ⚙️ **Customizable**: Configure device dimensions, colors, and styling
- 🎬 **Smooth Animations**: Animated transitions when switching between modes

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  device_wrapper: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

Wrap your MaterialApp with `DeviceWrapper` for web preview:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_wrapper/device_wrapper.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp(
      home: MyHomePage(),
    );

    // Only use DeviceWrapper on web
    if (kIsWeb) {
      return DeviceWrapper(
        initialMode: DeviceMode.iphone,
        showModeToggle: true,
        child: materialApp,
      );
    }

    return materialApp;
  }
}
```

### With Mode Change Callback

```dart
DeviceWrapper(
  initialMode: DeviceMode.iphone,
  showModeToggle: true,
  onModeChanged: (mode) {
    print('Device mode changed to: ${mode.displayName}');
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
  tabletConfig: DeviceConfig(
    width: 834,
    height: 1194,
    borderRadius: 20.0,
    borderWidth: 6.0,
    showNotch: false,
    showHomeIndicator: true,
  ),
  child: MyApp(),
)
```

### Custom Background Color

```dart
DeviceWrapper(
  backgroundColor: const Color(0xFF0D1117), // GitHub dark theme
  child: MyApp(),
)
```

### Disable Wrapper (for production)

```dart
DeviceWrapper(
  enabled: false, // Renders child directly without wrapper
  child: MyApp(),
)
```

### Mobile Device Behavior

Control how the wrapper behaves when running on a real mobile device (iOS/Android):

```dart
// Default: Show toggle button on mobile devices
DeviceWrapper(
  mobileDeviceBehavior: MobileDeviceBehavior.showToggle,
  child: MyApp(),
)

// Always show device frame even on mobile
DeviceWrapper(
  mobileDeviceBehavior: MobileDeviceBehavior.alwaysShowFrame,
  child: MyApp(),
)

// Always hide frame on mobile (render child directly)
DeviceWrapper(
  mobileDeviceBehavior: MobileDeviceBehavior.alwaysHideFrame,
  child: MyApp(),
)
```

## API Reference

### DeviceWrapper

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | required | The widget to wrap inside the device frame |
| `initialMode` | `DeviceMode` | `DeviceMode.iphone` | Initial device mode |
| `showModeToggle` | `bool` | `true` | Whether to show the mode toggle button |
| `mobileConfig` | `DeviceConfig?` | `null` | Custom configuration for mobile mode |
| `tabletConfig` | `DeviceConfig?` | `null` | Custom configuration for tablet mode |
| `onModeChanged` | `ValueChanged<DeviceMode>?` | `null` | Callback when device mode changes |
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
  screenOnly,    // Screen only without device frame
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
| `borderRadius` | `double` | `55.0` / `24.0` | Border radius for the device frame |
| `borderWidth` | `double` | `5.0` / `6.0` | Border width for the device frame (thin bezel) |
| `borderColor` | `Color` | `Color(0xFF1C1C1E)` | Titanium frame color |
| `backgroundColor` | `Color` | `Color(0xFF000000)` | Background color (black) |
| `shadows` | `List<BoxShadow>` | default shadows | Shadow configuration |
| `showNotch` | `bool` | `true` / `false` | Whether to show Dynamic Island/punch-hole camera |
| `showHomeIndicator` | `bool` | `true` | Whether to show the home indicator |
| `isSamsung` | `bool` | `false` | Whether this is a Samsung device (affects camera style) |

## Default Device Configurations

### iPhone 16 Pro (393×852)
- Physical resolution: 1179×2556 @ 3x scale
- Border radius: 55px (rounded corners)
- Border width: 12px (titanium bezel)
- Dynamic Island with camera lens effect
- Home indicator bar

### Samsung Galaxy S25 (384×832)
- Physical resolution: 1080×2340 @ 2.8125x scale
- Border radius: 45px
- Border width: 10px
- Punch-hole centered camera
- No home indicator (gesture navigation)

### iPad Pro 11" (834×1194)
- Physical resolution: 1668×2388 @ 2x scale
- Border radius: 18px
- Border width: 14px
- Home indicator only (no notch)

### Samsung Galaxy Tab S9 (800×1280)
- Physical resolution: 1600×2560 @ 2x scale
- Border radius: 20px
- Border width: 12px
- No notch, no home indicator

## Auto-Scaling Behavior

The device frame automatically scales to fit within the available browser/window size:

- **Scales down** when window is smaller than device dimensions
- **Never scales up** beyond original size (max scale = 1.0)
- **Maintains aspect ratio** - device is never distorted or squished
- **Responsive** - automatically adjusts when resizing browser window
- **Minimum scale**: 0.1 (to ensure content remains visible on very small screens)

## Example

Check out the `example` folder for a complete demo application:

```bash
cd example
flutter run -d chrome
```

## Use Cases

- **Web Development**: Preview mobile/tablet layouts when developing on web
- **Client Demos**: Show clients how the app looks on different devices
- **Screenshot Generation**: Capture consistent device-framed screenshots
- **Responsive Testing**: Quickly switch between device sizes during development
- **Documentation**: Create device mockups for documentation

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Author

**Madnaen**

- GitHub: [@naenmad](https://github.com/naenmad)
