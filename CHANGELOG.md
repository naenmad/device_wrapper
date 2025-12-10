# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2025-12-10

### Added
- **Screen Only for All Devices**: Screen Only mode now works with any selected device
  - Toggle between Device frame and Screen Only mode using the new toggle button
  - Screen Only maintains the selected device's dimensions (iPhone, Galaxy S25, iPad, or Galaxy Tab)
- **Separate Screen Only Toggle**: New dedicated toggle button separated from device selector
  - Shows "Device" or "Screen" label to indicate current mode
  - Device selector remains active even in Screen Only mode

### Fixed
- **Browser Zoom Compensation**: Device size now stays consistent regardless of browser zoom level (Ctrl+/Ctrl-)
  - Device frame maintains the same visual size when zooming in or out
  - Uses devicePixelRatio compensation to counteract browser zoom

### Changed
- **UI Toggle Redesign**: Split into two parts
  - Device selector (iPhone, Galaxy, iPad, Tab) - 4 buttons
  - Screen/Device toggle - separate button on the right
- Device info label now shows device name even in Screen Only mode (e.g., "iPhone 16 Pro (Screen)")

## [1.1.0] - 2025-12-08

### Added
- **Samsung Galaxy S25**: New device option with punch-hole camera style
  - Resolution: 384×832 logical pixels @ 2.8125x scale
  - Aspect ratio: ~1:2.17 (19.5:9)
- **Samsung Galaxy Tab S9**: New tablet device option
  - Resolution: 800×1280 logical pixels @ 2x scale
  - Aspect ratio: ~1:1.6 (10:16)
- Punch-hole camera design for Samsung phones
- `isSamsung` property in DeviceConfig for device-specific styling
- `isPhone` and `isTablet` getters in DeviceMode for easier device type checking
- `shortName` getter in DeviceMode for compact toggle display

### Changed
- **DeviceMode enum**: Renamed values for clarity
  - `mobile` → `iphone` (iPhone 16 Pro)
  - `tablet` → `ipad` (iPad Pro 11")
  - Added `samsungPhone` (Galaxy S25)
  - Added `samsungTablet` (Galaxy Tab S9)
- **Mode Toggle UI**: Updated to show 5 device options with distinct icons
  - iPhone (phone_iphone icon)
  - Galaxy S25 (phone_android icon)
  - iPad (tablet_mac icon)
  - Galaxy Tab (tablet_android icon)
  - Screen Only (crop_free icon)
- **Improved Aspect Ratio**: Fixed scaling bug where device appeared squished/gepeng on some laptops at 100% zoom
  - Now uses fixed SizedBox to enforce exact device dimensions
  - Scale calculation ensures proper aspect ratio is maintained

### Fixed
- **Aspect Ratio Bug**: Device frame now maintains correct proportions regardless of browser/window zoom level
- Reduced minimum scale from 0.3 to 0.1 for better fit on smaller screens

## [1.0.6] - 2025-12-07

### Added
- **Screen Only Toggle Button**: Added dedicated toggle button for Screen Only mode in the mode switcher
  - Now shows 3 buttons: Mobile, Tablet, and Screen Only
  - Click directly on each mode instead of cycling through

### Changed
- **Default Background Color**: Changed from purple (#1A1A2E) to black (#000000) for cleaner appearance
- Mode switching now uses direct selection instead of cycling

## [1.0.5] - 2025-12-07

### Fixed
- Fixed pub.dev validation issues:
  - Shortened package description to meet 60-180 character requirement
  - Applied Dart formatter to all source files

## [1.0.4] - 2025-12-07

### Added
- **Screen Only Mode**: New `DeviceMode.screenOnly` option to display just the screen without device frame
  - Perfect for cleaner previews and documentation screenshots
  - Cycles through: Mobile → Tablet → Screen Only → Mobile

### Fixed
- **Critical Fix**: Fixed content rendering issue where app content appeared too zoomed in/large inside device frame
  - Removed incorrect FittedBox and devicePixelRatio multiplication that caused layout issues
  - MediaQuery now correctly reports device dimensions without scaling artifacts
  - Content now renders at proper size matching actual device dimensions

### Changed
- Simplified content rendering logic for more accurate device simulation
- Screen only mode uses clean rounded corners with subtle shadow

## [1.0.3] - 2025-12-03

### Added
- **Mobile Device Behavior**: New `mobileDeviceBehavior` parameter to control how the wrapper behaves on real mobile devices (iOS/Android)
  - `MobileDeviceBehavior.alwaysShowFrame`: Always show the device frame
  - `MobileDeviceBehavior.alwaysHideFrame`: Always render child directly without frame
  - `MobileDeviceBehavior.showToggle`: Show a floating toggle button to let users choose (default)
- Floating "Show Device Frame" button when running on mobile devices
- "Hide Frame" button to exit device frame view on mobile
- Auto-detection of mobile platform (iOS/Android, excluding web)

### Changed
- Updated device configurations:
  - **Mobile (iPhone 16 Pro)**: 393×852 logical pixels
  - **Tablet (iPad Pro 11")**: 834×1194 logical pixels
- Improved rendering with proper MediaQuery configuration

## [1.0.2] - 2025-12-03

### Changed
- Updated device configurations with accurate specifications:
  - **Mobile (iPhone 16 Pro)**: 393×852 logical pixels (1179×2556 @ 3x scale), border radius 55px, border width 12px
  - **Tablet (iPad 10th Gen)**: 820×1180 logical pixels (1640×2360 @ 2x scale), border radius 18px, border width 14px
- Improved documentation with actual device physical and logical resolutions
- Added aspect ratio information to device configs

### Fixed
- Fixed all static analysis lint issues (6 issues resolved)
- Added `const` to constant values and TextStyle constructors for better performance

## [1.0.0] - 2025-12-03

### Added
- Initial release of Device Wrapper
- **DeviceWrapper** widget for wrapping Flutter apps in device frames
- **DeviceMode** enum with `mobile` (iPhone 17 Pro) and `tablet` (iPad Gen 11) modes
- **DeviceConfig** class for customizing device appearance
- Auto-scaling to fit device within browser/window size
- Dynamic Island with camera lens effect for iPhone 17 Pro style
- Titanium gradient frame design with realistic bezels
- Mode toggle button with smooth animations
- Side buttons (power, volume, action button) for realistic appearance
- Home indicator bar
- Grid pattern background
- Device info label showing current mode and dimensions
- Support for custom configurations (dimensions, colors, shadows)
- `enabled` flag to disable wrapper for production builds
- `onModeChanged` callback for mode switch events

### Device Configurations
- **Mobile (iPhone 17 Pro)**: 393×852, border radius 55px, border width 5px
- **Tablet (iPad Gen 11)**: 820×1180, border radius 24px, border width 6px
