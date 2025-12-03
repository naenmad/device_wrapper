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

  const DeviceConfig({
    required this.width,
    required this.height,
    this.devicePixelRatio = 3.0,
    this.borderRadius = 55.0,
    this.borderWidth = 5.0,
    this.borderColor = const Color(0xFF1C1C1E),
    this.backgroundColor = const Color(0xFF1A1A2E),
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
  });

  /// iPhone 16 Pro configuration
  /// Physical resolution: 1179 x 2556 pixels @ 3x scale
  /// Logical resolution (device points): 393 x 852
  /// Aspect ratio: ~1:2.17 (9:19.5 Dynamic Island)
  static const DeviceConfig mobile = DeviceConfig(
    width: 393,
    height: 852,
    devicePixelRatio: 3.0,
    borderRadius: 55.0,
    borderWidth: 12.0,
    showNotch: true,
    showHomeIndicator: true,
  );

  /// iPad Pro 11" / iPad Air configuration  
  /// Physical resolution: 1668 x 2388 pixels @ 2x scale
  /// Logical resolution (device points): 834 x 1194
  /// Aspect ratio: ~1:1.43
  static const DeviceConfig tablet = DeviceConfig(
    width: 834,
    height: 1194,
    devicePixelRatio: 2.0,
    borderRadius: 18.0,
    borderWidth: 14.0,
    showNotch: false,
    showHomeIndicator: true,
  );

  /// Get configuration for a specific device mode
  static DeviceConfig fromMode(DeviceMode mode) {
    switch (mode) {
      case DeviceMode.mobile:
        return mobile;
      case DeviceMode.tablet:
        return tablet;
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
    );
  }
}
