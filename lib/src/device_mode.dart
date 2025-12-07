/// Enum representing the device mode for the wrapper
enum DeviceMode {
  /// Mobile device mode (iPhone 16 Pro - 393x852)
  mobile,
  
  /// Tablet device mode (iPad Pro 11" - 834x1194)
  tablet,
  
  /// Screen only mode - just the screen without device frame
  screenOnly,
}

/// Extension to provide additional properties for DeviceMode
extension DeviceModeExtension on DeviceMode {
  /// Get the display name for the device mode
  String get displayName {
    switch (this) {
      case DeviceMode.mobile:
        return 'Mobile';
      case DeviceMode.tablet:
        return 'Tablet';
      case DeviceMode.screenOnly:
        return 'Screen Only';
    }
  }

  /// Get the icon for the device mode
  String get iconName {
    switch (this) {
      case DeviceMode.mobile:
        return 'phone_android';
      case DeviceMode.tablet:
        return 'tablet_android';
      case DeviceMode.screenOnly:
        return 'crop_free';
    }
  }
}
