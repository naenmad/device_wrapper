/// Enum representing the device mode for the wrapper
enum DeviceMode {
  /// iPhone 16 Pro (393x852)
  iphone,

  /// Samsung Galaxy S25 (384x854)
  samsungPhone,

  /// iPad Pro 11" (834x1194)
  ipad,

  /// Samsung Galaxy Tab S9 (800x1280)
  samsungTablet,

  /// Screen only mode - just the screen without device frame
  screenOnly,
}

/// Extension to provide additional properties for DeviceMode
extension DeviceModeExtension on DeviceMode {
  /// Get the display name for the device mode
  String get displayName {
    switch (this) {
      case DeviceMode.iphone:
        return 'iPhone 16 Pro';
      case DeviceMode.samsungPhone:
        return 'Galaxy S25';
      case DeviceMode.ipad:
        return 'iPad Pro';
      case DeviceMode.samsungTablet:
        return 'Galaxy Tab';
      case DeviceMode.screenOnly:
        return 'Screen Only';
    }
  }

  /// Get short name for toggle button
  String get shortName {
    switch (this) {
      case DeviceMode.iphone:
        return 'iPhone';
      case DeviceMode.samsungPhone:
        return 'Galaxy';
      case DeviceMode.ipad:
        return 'iPad';
      case DeviceMode.samsungTablet:
        return 'Tab';
      case DeviceMode.screenOnly:
        return 'Screen';
    }
  }

  /// Check if this is a phone mode
  bool get isPhone {
    return this == DeviceMode.iphone || this == DeviceMode.samsungPhone;
  }

  /// Check if this is a tablet mode
  bool get isTablet {
    return this == DeviceMode.ipad || this == DeviceMode.samsungTablet;
  }

  /// Get the icon for the device mode
  String get iconName {
    switch (this) {
      case DeviceMode.iphone:
      case DeviceMode.samsungPhone:
        return 'phone_android';
      case DeviceMode.ipad:
      case DeviceMode.samsungTablet:
        return 'tablet_android';
      case DeviceMode.screenOnly:
        return 'crop_free';
    }
  }
}
