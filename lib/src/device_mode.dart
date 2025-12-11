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

  /// MacBook Pro 14" (1512x982 logical)
  macbook,

  /// Microsoft Surface Pro (1368x912 logical)
  surface,

  /// Apple Watch Series 10 (198x242)
  appleWatch,

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
      case DeviceMode.macbook:
        return 'MacBook Pro';
      case DeviceMode.surface:
        return 'Surface Pro';
      case DeviceMode.appleWatch:
        return 'Apple Watch';
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
      case DeviceMode.macbook:
        return 'MacBook';
      case DeviceMode.surface:
        return 'Surface';
      case DeviceMode.appleWatch:
        return 'Watch';
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

  /// Check if this is a desktop/laptop mode
  bool get isDesktop {
    return this == DeviceMode.macbook || this == DeviceMode.surface;
  }

  /// Check if this is a watch mode
  bool get isWatch {
    return this == DeviceMode.appleWatch;
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
      case DeviceMode.macbook:
      case DeviceMode.surface:
        return 'laptop';
      case DeviceMode.appleWatch:
        return 'watch';
      case DeviceMode.screenOnly:
        return 'crop_free';
    }
  }

  /// Get category name for grouping in UI
  String get category {
    if (isPhone) return 'Phone';
    if (isTablet) return 'Tablet';
    if (isDesktop) return 'Desktop';
    if (isWatch) return 'Watch';
    return 'Other';
  }
}
