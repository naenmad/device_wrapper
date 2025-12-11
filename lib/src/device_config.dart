import 'package:flutter/material.dart';
import 'device_mode.dart';

/// Configuration class for device dimensions and styling
class DeviceConfig {
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
  final Color backgroundColor;

  /// Shadow configuration for the device frame
  final List<BoxShadow> shadows;

  /// Whether to show the device notch (for mobile)
  final bool showNotch;

  /// Whether to show the home indicator
  final bool showHomeIndicator;

  /// Whether this is a Samsung device (for different notch style)
  final bool isSamsung;

  /// Whether this is a desktop/laptop device
  final bool isDesktop;

  /// Whether this is a watch device
  final bool isWatch;

  const DeviceConfig({
    required this.width,
    required this.height,
    this.devicePixelRatio = 3.0,
    this.borderRadius = 55.0,
    this.borderWidth = 5.0,
    this.borderColor = const Color(0xFF1C1C1E),
    this.backgroundColor = const Color(0xFF000000),
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
    this.isSamsung = false,
    this.isDesktop = false,
    this.isWatch = false,
  });

  /// iPhone 16 Pro configuration
  /// Physical resolution: 1179 x 2556 pixels @ 3x scale
  /// Logical resolution (device points): 393 x 852
  /// Aspect ratio: ~1:2.17 (9:19.5 Dynamic Island)
  static const DeviceConfig iphone = DeviceConfig(
    width: 393,
    height: 852,
    devicePixelRatio: 3.0,
    borderRadius: 55.0,
    borderWidth: 12.0,
    showNotch: true,
    showHomeIndicator: true,
    isSamsung: false,
  );

  /// Samsung Galaxy S25 configuration
  /// Physical resolution: 1080 x 2340 pixels @ 2.8125x scale
  /// Logical resolution (device points): ~384 x 832
  /// Aspect ratio: ~1:2.17 (19.5:9)
  static const DeviceConfig samsungPhone = DeviceConfig(
    width: 384,
    height: 832,
    devicePixelRatio: 2.8125,
    borderRadius: 45.0,
    borderWidth: 10.0,
    showNotch: true,
    showHomeIndicator: false,
    isSamsung: true,
  );

  /// iPad Pro 11" / iPad Air configuration
  /// Physical resolution: 1668 x 2388 pixels @ 2x scale
  /// Logical resolution (device points): 834 x 1194
  /// Aspect ratio: ~1:1.43
  static const DeviceConfig ipad = DeviceConfig(
    width: 834,
    height: 1194,
    devicePixelRatio: 2.0,
    borderRadius: 18.0,
    borderWidth: 14.0,
    showNotch: false,
    showHomeIndicator: true,
    isSamsung: false,
  );

  /// Samsung Galaxy Tab S9 configuration
  /// Physical resolution: 1600 x 2560 pixels @ 2x scale
  /// Logical resolution (device points): 800 x 1280
  /// Aspect ratio: ~1:1.6 (10:16)
  static const DeviceConfig samsungTablet = DeviceConfig(
    width: 800,
    height: 1280,
    devicePixelRatio: 2.0,
    borderRadius: 20.0,
    borderWidth: 12.0,
    showNotch: false,
    showHomeIndicator: false,
    isSamsung: true,
  );

  /// MacBook Pro 14" configuration
  /// Physical resolution: 3024 x 1964 pixels @ 2x scale
  /// Logical resolution (device points): 1512 x 982
  /// Aspect ratio: ~1.54:1 (standard laptop)
  static const DeviceConfig macbook = DeviceConfig(
    width: 1512,
    height: 982,
    devicePixelRatio: 2.0,
    borderRadius: 16.0,
    borderWidth: 16.0,
    borderColor: Color(0xFF2D2D2D),
    showNotch: true,
    showHomeIndicator: false,
    isSamsung: false,
    isDesktop: true,
  );

  /// Microsoft Surface Pro configuration
  /// Physical resolution: 2736 x 1824 pixels @ 2x scale
  /// Logical resolution (device points): 1368 x 912
  /// Aspect ratio: 3:2
  static const DeviceConfig surface = DeviceConfig(
    width: 1368,
    height: 912,
    devicePixelRatio: 2.0,
    borderRadius: 12.0,
    borderWidth: 18.0,
    borderColor: Color(0xFF1a1a1a),
    showNotch: false,
    showHomeIndicator: false,
    isSamsung: false,
    isDesktop: true,
  );

  /// Apple Watch Series 10 (45mm) configuration
  /// Physical resolution: 396 x 484 pixels @ 2x scale
  /// Logical resolution (device points): 198 x 242
  /// Has rounded square display
  static const DeviceConfig appleWatch = DeviceConfig(
    width: 198,
    height: 242,
    devicePixelRatio: 2.0,
    borderRadius: 52.0,
    borderWidth: 8.0,
    borderColor: Color(0xFF2D2D2D),
    showNotch: false,
    showHomeIndicator: false,
    isSamsung: false,
    isWatch: true,
  );

  /// Screen only configuration (no device frame, just screen)
  /// Uses mobile dimensions by default
  static const DeviceConfig screenOnly = DeviceConfig(
    width: 393,
    height: 852,
    devicePixelRatio: 3.0,
    borderRadius: 0.0,
    borderWidth: 0.0,
    showNotch: false,
    showHomeIndicator: false,
    isSamsung: false,
  );

  /// Get configuration for a specific device mode
  static DeviceConfig fromMode(DeviceMode mode) {
    switch (mode) {
      case DeviceMode.iphone:
        return iphone;
      case DeviceMode.samsungPhone:
        return samsungPhone;
      case DeviceMode.ipad:
        return ipad;
      case DeviceMode.samsungTablet:
        return samsungTablet;
      case DeviceMode.macbook:
        return macbook;
      case DeviceMode.surface:
        return surface;
      case DeviceMode.appleWatch:
        return appleWatch;
      case DeviceMode.screenOnly:
        return screenOnly;
    }
  }

  /// Create a copy with modified properties
  DeviceConfig copyWith({
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
    bool? isSamsung,
    bool? isDesktop,
    bool? isWatch,
  }) {
    return DeviceConfig(
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
      isSamsung: isSamsung ?? this.isSamsung,
      isDesktop: isDesktop ?? this.isDesktop,
      isWatch: isWatch ?? this.isWatch,
    );
  }
}
