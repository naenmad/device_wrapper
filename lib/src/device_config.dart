import 'package:flutter/material.dart';

import 'device_mode.dart';

/// Configuration class for device dimensions and styling
class DeviceConfig {
  final String name;

  final IconData icon;

  final DeviceMode mode;

  /// Width of the device frame (logical pixels / device points)
  final double width;

  /// Height of the device frame (logical pixels / device points)
  final double height;

  /// Device pixel ratio (scale factor for content)
  /// iPhone uses 3.0, iPad uses 2.0
  final double devicePixelRatio;

  /// Border radius for the device frame
  final double borderRadius;

  /// Border width for the device frame
  final double borderWidth;

  /// Border color for the device frame
  final Color borderColor;

  /// Background color behind the device frame
  final Color? backgroundColor;

  /// Grid color behind the device frame
  final Color? gridColor;

  /// Shadow configuration for the device frame
  final List<BoxShadow> shadows;

  /// Whether to show the device notch (for mobile)
  final bool showNotch;

  /// Whether to show the home indicator
  final bool showHomeIndicator;

  /// Whether to show the status bar
  final bool showStatusBar;

  /// Device safe padding
  final EdgeInsets? _safePadding;

  EdgeInsets get safePadding =>
      _safePadding ??
      EdgeInsets.only(
        top: showNotch ? 59.0 : 24.0,
        bottom: showHomeIndicator ? 34.0 : 0.0,
      );

  const DeviceConfig({
    required this.name,
    required this.width,
    required this.height,
    required this.icon,
    EdgeInsets? safePadding,
    this.mode = DeviceMode.mobile,
    this.devicePixelRatio = 3.0,
    this.borderRadius = 55.0,
    this.borderWidth = 5.0,
    this.borderColor = const Color(0xFF1C1C1E),
    this.backgroundColor,
    this.gridColor,
    this.shadows = const [
      BoxShadow(
        color: Color(0x50000000),
        blurRadius: 40,
        spreadRadius: 2,
        offset: Offset(0, 20),
      ),
      BoxShadow(
        color: Color(0x15000000),
        blurRadius: 80,
        spreadRadius: 5,
        offset: Offset(0, 40),
      ),
    ],
    this.showNotch = true,
    this.showHomeIndicator = true,
    this.showStatusBar = true,
  }) : _safePadding = safePadding;

  /// All DeviceConfig
  static const List<DeviceConfig> deviceList = [
    mobile,
    tablet,
    desktop,
    screenOnly
  ];

  /// iPhone 16 Pro configuration
  /// Physical resolution: 1179 x 2556 pixels @ 3x scale
  /// Logical resolution (device points): 393 x 852
  /// Aspect ratio: ~1:2.17 (9:19.5 Dynamic Island)
  static const DeviceConfig mobile = DeviceConfig(
    name: 'Mobile',
    icon: Icons.phone_android_outlined,
    mode: DeviceMode.mobile,
    width: 394,
    height: 852,
    devicePixelRatio: 3.0,
    borderRadius: 55.0,
    borderWidth: 12.0,
    showNotch: true,
    showHomeIndicator: true,
    showStatusBar: true,
  );

  /// iPad Pro 11" / iPad Air configuration
  /// Physical resolution: 1668 x 2388 pixels @ 2x scale
  /// Logical resolution (device points): 834 x 1194
  /// Aspect ratio: ~1:1.43
  static const DeviceConfig tablet = DeviceConfig(
    name: 'Tablet',
    icon: Icons.tablet_android_outlined,
    mode: DeviceMode.tablet,
    width: 834,
    height: 1194,
    devicePixelRatio: 2.0,
    borderRadius: 18.0,
    borderWidth: 14.0,
    showNotch: false,
    showHomeIndicator: true,
    showStatusBar: true,
  );

  /// Screen only configuration (no device frame, just screen)
  /// Uses mobile dimensions by default
  static const DeviceConfig screenOnly = DeviceConfig(
    name: 'ScreenOnly',
    icon: Icons.crop_free,
    mode: DeviceMode.mobile,
    width: 394,
    height: 852,
    devicePixelRatio: 3.0,
    borderRadius: 0.0,
    borderWidth: 0.0,
    showNotch: false,
    showHomeIndicator: false,
    showStatusBar: false,
  );

  static const DeviceConfig desktop = DeviceConfig(
    name: 'Desktop',
    icon: Icons.desktop_windows_outlined,
    mode: DeviceMode.desktop,
    width: 1280,
    height: 832,
    devicePixelRatio: 2.0,
    borderRadius: 18.0,
    borderWidth: 14.0,
    showNotch: false,
    showHomeIndicator: false,
    showStatusBar: true,
  );

  /// Create a copy with modified properties
  DeviceConfig copyWith({
    String? name,
    IconData? icon,
    DeviceMode? mode,
    double? width,
    double? height,
    double? devicePixelRatio,
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    Color? backgroundColor,
    List<BoxShadow>? shadows,
    bool? showNotch,
    bool? showHomeIndicator,
    bool? showStatusBar,
    EdgeInsets? safePadding,
    Color? gridColor,
  }) {
    return DeviceConfig(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      mode: mode ?? this.mode,
      width: width ?? this.width,
      height: height ?? this.height,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadows: shadows ?? this.shadows,
      showNotch: showNotch ?? this.showNotch,
      showHomeIndicator: showHomeIndicator ?? this.showHomeIndicator,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      safePadding: safePadding ?? this.safePadding,
      gridColor: gridColor ?? this.gridColor,
    );
  }
}
