import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'device_mode.dart';
import 'device_config.dart';

/// Behavior when running on a mobile device
enum MobileDeviceBehavior {
  /// Always show the device frame wrapper
  alwaysShowFrame,

  /// Always render child directly without frame
  alwaysHideFrame,

  /// Show a toggle to let user choose
  showToggle,
}

/// Orientation mode for devices
enum DeviceOrientation {
  /// Portrait mode (taller than wide)
  portrait,

  /// Landscape mode (wider than tall)
  landscape,
}

/// Theme mode for the wrapper
enum WrapperTheme {
  /// Light theme with white background
  light,

  /// Dark theme with gray background
  dark,
}

/// A widget that wraps its child in a device frame with fixed dimensions.
///
/// This is useful for previewing mobile/tablet layouts on web or desktop,
/// simulating how the app would look on actual devices.
///
/// Keyboard Shortcuts:
/// - Ctrl+Shift+S: Take screenshot
/// - Ctrl+Shift+R: Rotate device (portrait/landscape)
/// - Ctrl+Shift+T: Toggle theme (light/dark)
/// - Ctrl+Shift+D: Toggle device/screen mode
/// - Ctrl+Shift+W: Toggle wrapper visibility
/// - Ctrl+Shift+1-7: Select device (1=iPhone, 2=Galaxy, 3=iPad, 4=Tab, 5=MacBook, 6=Surface, 7=Watch)
///
/// Example usage:
/// ```dart
/// DeviceWrapper(
///   initialMode: DeviceMode.iphone,
///   showModeToggle: true,
///   child: MyApp(),
/// )
/// ```
class DeviceWrapper extends StatefulWidget {
  /// The child widget to wrap inside the device frame
  final Widget child;

  /// Initial device mode (mobile or tablet)
  final DeviceMode initialMode;

  /// Whether to show the mode toggle button
  final bool showModeToggle;

  /// Custom configuration for mobile mode
  final DeviceConfig? mobileConfig;

  /// Custom configuration for tablet mode
  final DeviceConfig? tabletConfig;

  /// Callback when device mode changes
  final ValueChanged<DeviceMode>? onModeChanged;

  /// Whether the wrapper is enabled (if false, child is rendered directly)
  final bool enabled;

  /// Background color for the area outside the device frame
  final Color? backgroundColor;

  /// Behavior when app is running on a mobile device (iOS/Android)
  /// - [MobileDeviceBehavior.alwaysShowFrame]: Always show device frame
  /// - [MobileDeviceBehavior.alwaysHideFrame]: Always render child directly
  /// - [MobileDeviceBehavior.showToggle]: Show toggle to let user choose
  final MobileDeviceBehavior mobileDeviceBehavior;

  /// Initial theme mode
  final WrapperTheme initialTheme;

  /// Initial orientation
  final DeviceOrientation initialOrientation;

  /// Callback when screenshot is taken
  final ValueChanged<ui.Image>? onScreenshot;

  const DeviceWrapper({
    super.key,
    required this.child,
    this.initialMode = DeviceMode.iphone,
    this.showModeToggle = true,
    this.mobileConfig,
    this.tabletConfig,
    this.onModeChanged,
    this.enabled = true,
    this.backgroundColor,
    this.mobileDeviceBehavior = MobileDeviceBehavior.showToggle,
    this.initialTheme = WrapperTheme.light,
    this.initialOrientation = DeviceOrientation.portrait,
    this.onScreenshot,
  });

  @override
  State<DeviceWrapper> createState() => _DeviceWrapperState();
}

class _DeviceWrapperState extends State<DeviceWrapper>
    with SingleTickerProviderStateMixin {
  late DeviceMode _currentMode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showDeviceFrame = true;
  bool _isScreenOnly = false;
  DeviceMode _lastDeviceMode = DeviceMode.iphone;
  late WrapperTheme _theme;
  late DeviceOrientation _orientation;
  bool _wrapperEnabled = true;
  final GlobalKey _screenshotKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  /// Check if running on a mobile device (iOS or Android, not web)
  bool get _isOnMobileDevice {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  /// Get background color based on theme
  Color get _backgroundColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return _theme == WrapperTheme.light
        ? const Color(0xFFF5F5F5)
        : const Color(0xFF2D2D2D);
  }

  /// Get text/icon color based on theme
  Color get _foregroundColor {
    return _theme == WrapperTheme.light
        ? const Color(0xFF333333)
        : const Color(0xFFFFFFFF);
  }

  /// Get button background color based on theme
  Color get _buttonBackgroundColor {
    return _theme == WrapperTheme.light
        ? Colors.black.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.1);
  }

  /// Get active button background color based on theme
  Color get _activeButtonBackgroundColor {
    return _theme == WrapperTheme.light
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);
  }

  /// Get border color based on theme
  Color get _borderColor {
    return _theme == WrapperTheme.light
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.2);
  }

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _lastDeviceMode = widget.initialMode;
    _theme = widget.initialTheme;
    _orientation = widget.initialOrientation;

    // Set initial device frame visibility based on mobile behavior
    if (_isOnMobileDevice) {
      switch (widget.mobileDeviceBehavior) {
        case MobileDeviceBehavior.alwaysShowFrame:
          _showDeviceFrame = true;
          break;
        case MobileDeviceBehavior.alwaysHideFrame:
          _showDeviceFrame = false;
          break;
        case MobileDeviceBehavior.showToggle:
          _showDeviceFrame = false; // Default to hide on mobile
          break;
      }
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle keyboard shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final bool isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
    final bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    // Ctrl+Shift+S - Screenshot
    if (isCtrlPressed &&
        isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.keyS) {
      _takeScreenshot();
      return KeyEventResult.handled;
    }

    // Ctrl+Shift+R - Rotate
    if (isCtrlPressed &&
        isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.keyR) {
      _toggleOrientation();
      return KeyEventResult.handled;
    }

    // Ctrl+Shift+T - Toggle theme
    if (isCtrlPressed &&
        isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.keyT) {
      _toggleTheme();
      return KeyEventResult.handled;
    }

    // Ctrl+Shift+D - Toggle device/screen
    if (isCtrlPressed &&
        isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.keyD) {
      _toggleScreenOnly();
      return KeyEventResult.handled;
    }

    // Ctrl+Shift+W - Toggle wrapper
    if (isCtrlPressed &&
        isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.keyW) {
      _toggleWrapper();
      return KeyEventResult.handled;
    }

    // 1-7 keys for device selection (with Ctrl+Shift)
    if (isCtrlPressed && isShiftPressed) {
      if (event.logicalKey == LogicalKeyboardKey.digit1) {
        _selectDevice(DeviceMode.iphone);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        _selectDevice(DeviceMode.samsungPhone);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        _selectDevice(DeviceMode.ipad);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        _selectDevice(DeviceMode.samsungTablet);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
        _selectDevice(DeviceMode.macbook);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
        _selectDevice(DeviceMode.surface);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
        _selectDevice(DeviceMode.appleWatch);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _selectDevice(DeviceMode mode) {
    if (_lastDeviceMode != mode) {
      setState(() {
        _lastDeviceMode = mode;
        if (!_isScreenOnly) {
          _currentMode = mode;
        }
      });
      widget.onModeChanged?.call(_currentMode);
    }
  }

  void _toggleScreenOnly() async {
    await _animationController.forward();

    setState(() {
      _isScreenOnly = !_isScreenOnly;
      if (_isScreenOnly) {
        _currentMode = DeviceMode.screenOnly;
      } else {
        _currentMode = _lastDeviceMode;
      }
    });

    widget.onModeChanged?.call(_currentMode);

    await _animationController.reverse();
  }

  void _toggleTheme() {
    setState(() {
      _theme =
          _theme == WrapperTheme.light ? WrapperTheme.dark : WrapperTheme.light;
    });
  }

  void _toggleOrientation() async {
    await _animationController.forward();

    setState(() {
      _orientation = _orientation == DeviceOrientation.portrait
          ? DeviceOrientation.landscape
          : DeviceOrientation.portrait;
    });

    await _animationController.reverse();
  }

  void _toggleWrapper() {
    setState(() {
      _wrapperEnabled = !_wrapperEnabled;
    });
  }

  Future<void> _takeScreenshot() async {
    try {
      // Ensure the current frame is fully drawn before capturing
      await SchedulerBinding.instance.endOfFrame;

      final boundary = _screenshotKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(
        pixelRatio: ui.window.devicePixelRatio * 2.0,
      );
      widget.onScreenshot?.call(image);

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Screenshot captured!'),
            backgroundColor:
                _theme == WrapperTheme.light ? Colors.black87 : Colors.white70,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Screenshot failed: $e');
    }
  }

  DeviceConfig get _currentConfig {
    // For screen only mode, use the last device's config
    if (_isScreenOnly) {
      return _getConfigForMode(_lastDeviceMode).copyWith(
        borderRadius: 12.0,
        borderWidth: 0.0,
        showNotch: false,
        showHomeIndicator: false,
      );
    }
    return _getConfigForMode(_currentMode);
  }

  DeviceConfig _getConfigForMode(DeviceMode mode) {
    switch (mode) {
      case DeviceMode.iphone:
        return widget.mobileConfig ?? DeviceConfig.iphone;
      case DeviceMode.samsungPhone:
        return DeviceConfig.samsungPhone;
      case DeviceMode.ipad:
        return widget.tabletConfig ?? DeviceConfig.ipad;
      case DeviceMode.samsungTablet:
        return DeviceConfig.samsungTablet;
      case DeviceMode.macbook:
        return DeviceConfig.macbook;
      case DeviceMode.surface:
        return DeviceConfig.surface;
      case DeviceMode.appleWatch:
        return DeviceConfig.appleWatch;
      case DeviceMode.screenOnly:
        return widget.mobileConfig ?? DeviceConfig.iphone;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If wrapper is disabled globally
    if (!widget.enabled || !_wrapperEnabled) {
      return Stack(
        children: [
          widget.child,
          if (!_wrapperEnabled)
            Positioned(
              top: 16,
              right: 16,
              child: _buildReEnableButton(),
            ),
        ],
      );
    }

    // Handle mobile device behavior
    if (_isOnMobileDevice) {
      switch (widget.mobileDeviceBehavior) {
        case MobileDeviceBehavior.alwaysHideFrame:
          return widget.child;
        case MobileDeviceBehavior.showToggle:
          if (!_showDeviceFrame) {
            return _buildMobileToggleOverlay();
          }
          break;
        case MobileDeviceBehavior.alwaysShowFrame:
          break;
      }
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          child: Stack(
            children: [
              // Background
              Positioned.fill(
                child: _buildBackground(),
              ),

              // Device frame with aspect ratio
              Positioned.fill(
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    Expanded(
                      child: Center(
                        child: _buildDeviceWithAspectRatio(),
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),

              // Mode toggle at top
              if (widget.showModeToggle)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildModeToggle()),
                ),

              // Bottom toolbar
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: _buildBottomToolbar(),
              ),

              // Mobile device toggle
              if (_isOnMobileDevice &&
                  widget.mobileDeviceBehavior ==
                      MobileDeviceBehavior.showToggle)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildDeviceFrameToggle(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReEnableButton() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _toggleWrapper,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Show Wrapper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceWithAspectRatio() {
    final config = _currentConfig;

    // Apply orientation
    double deviceWidth = config.width + (config.borderWidth * 2);
    double deviceHeight = config.height + (config.borderWidth * 2);

    // Add laptop body for desktop devices
    if (_currentMode.isDesktop && !_isScreenOnly) {
      deviceHeight += 30; // Laptop base
    }

    // Add watch band space
    if (_currentMode.isWatch && !_isScreenOnly) {
      deviceHeight += 80; // Watch bands
    }

    // Swap for landscape (except desktop and watch which are naturally landscape)
    if (_orientation == DeviceOrientation.landscape &&
        !_currentMode.isDesktop &&
        !_currentMode.isWatch) {
      final temp = deviceWidth;
      deviceWidth = deviceHeight;
      deviceHeight = temp;
    }

    final aspectRatio = deviceWidth / deviceHeight;

    return RepaintBoundary(
      key: _screenshotKey,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: deviceWidth,
              height: deviceHeight,
              child: _buildDeviceFrame(config),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileToggleOverlay() {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDeviceFrame = true;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Show Frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceFrameToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDeviceFrame = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Hide Frame',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final bgColor = _backgroundColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            bgColor.withValues(alpha: 0.95),
            bgColor,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _GridPatternPainter(
          color: _theme == WrapperTheme.light
              ? Colors.black.withValues(alpha: 0.03)
              : Colors.white.withValues(alpha: 0.03),
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildDeviceFrame(DeviceConfig config) {
    // For screenOnly mode, just render the screen without frame
    if (_currentMode == DeviceMode.screenOnly) {
      return _buildScreenOnly(config);
    }

    // Desktop devices (MacBook, Surface)
    if (_currentMode.isDesktop) {
      return _buildDesktopFrame(config);
    }

    // Watch device
    if (_currentMode.isWatch) {
      return _buildWatchFrame(config);
    }

    // Phone/Tablet devices
    return _buildMobileFrame(config);
  }

  Widget _buildMobileFrame(DeviceConfig config) {
    final isLandscape = _orientation == DeviceOrientation.landscape;

    double width = config.width + (config.borderWidth * 2);
    double height = config.height + (config.borderWidth * 2);

    if (isLandscape) {
      final temp = width;
      width = height;
      height = temp;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Gradient for realistic titanium/aluminum frame
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.borderColor.withValues(alpha: 0.95),
            config.borderColor,
            config.borderColor.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(config.borderRadius),
        boxShadow: config.shadows,
        border: Border.all(
          color: Colors.grey.shade800,
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          // Screen content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(config.borderWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  config.borderRadius - config.borderWidth,
                ),
                child: Stack(
                  children: [
                    // Main content
                    Container(
                      color: Colors.white,
                      child: MediaQuery(
                        data: MediaQueryData(
                          size: isLandscape
                              ? Size(config.height, config.width)
                              : Size(config.width, config.height),
                          devicePixelRatio: config.devicePixelRatio,
                          padding: EdgeInsets.only(
                            top: config.showNotch ? 59.0 : 24.0,
                            bottom: config.showHomeIndicator ? 34.0 : 0.0,
                          ),
                        ),
                        child: widget.child,
                      ),
                    ),
                    // Status bar overlay
                    _buildStatusBar(config, isLandscape),
                  ],
                ),
              ),
            ),
          ),

          // Dynamic Island / Punch hole camera
          if (config.showNotch && _currentMode.isPhone) ...[
            // Base sizes for notch widgets (unrotated)
            () {
              final double notchBaseWidth = config.isSamsung ? 14.0 : 126.0;
              final double notchBaseHeight = config.isSamsung ? 14.0 : 37.0;
              final double notchWidth = isLandscape ? notchBaseHeight : notchBaseWidth;
              final double notchHeight = isLandscape ? notchBaseWidth : notchBaseHeight;

              return Positioned(
                // Center vertically for landscape using computed rotated height
                top: isLandscape ? (height - notchHeight) / 2 : config.borderWidth + 12,
                left: isLandscape ? config.borderWidth + 12 : 0,
                right: isLandscape ? null : 0,
                // Only provide an explicit width when in landscape
                width: isLandscape ? notchWidth : null,
                height: notchHeight,
                child: isLandscape
                    ? RotatedBox(
                        quarterTurns: 1,
                        child: config.isSamsung
                            ? _buildPunchHoleCamera(config)
                            : _buildDynamicIsland(config),
                      )
                    : config.isSamsung
                        ? _buildPunchHoleCamera(config)
                        : _buildDynamicIsland(config),
              );
            }(),
          ],

          // Home indicator
          if (config.showHomeIndicator)
            Positioned(
              bottom: isLandscape ? null : config.borderWidth + 8,
              right: isLandscape ? config.borderWidth + 8 : null,
              left: isLandscape ? null : 0,
              top: isLandscape ? 0 : null,
              child: isLandscape
                  ? RotatedBox(
                      quarterTurns: 1,
                      child: _buildHomeIndicator(config),
                    )
                  : _buildHomeIndicator(config),
            ),

          // Side buttons
          if (!isLandscape) _buildSideButtons(config),
        ],
      ),
    );
  }

  Widget _buildStatusBar(DeviceConfig config, bool isLandscape) {
    final isSamsung = config.isSamsung;
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: isLandscape ? 24 : (config.showNotch ? 54 : 32),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isLandscape ? 4 : 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Time (for iPhone) or nothing (for Samsung)
            if (!isSamsung)
              Padding(
                padding: EdgeInsets.only(top: config.showNotch ? 10 : 0),
                child: Text(
                  timeString,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              const SizedBox(width: 50),

            // Right side - Icons
            Padding(
              padding: EdgeInsets.only(top: config.showNotch ? 10 : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Signal bars
                  _buildSignalBars(),
                  const SizedBox(width: 4),
                  // WiFi
                  _buildWifiIcon(),
                  const SizedBox(width: 4),
                  // Battery
                  _buildBatteryIcon(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalBars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        return Container(
          width: 3,
          height: 4.0 + (index * 2.5),
          margin: const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildWifiIcon() {
    return const Icon(
      Icons.wifi,
      color: Colors.black,
      size: 15,
    );
  }

  Widget _buildBatteryIcon() {
    return Container(
      width: 22,
      height: 11,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 1,
            top: 1,
            bottom: 1,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Positioned(
            right: -3,
            top: 3,
            child: Container(
              width: 2,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFrame(DeviceConfig config) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Screen
        Container(
          width: config.width + (config.borderWidth * 2),
          height: config.height + (config.borderWidth * 2),
          decoration: BoxDecoration(
            color: config.borderColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(config.borderRadius),
              topRight: Radius.circular(config.borderRadius),
            ),
            boxShadow: config.shadows,
          ),
          child: Stack(
            children: [
              // Screen content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(config.borderWidth),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          config.borderRadius - config.borderWidth),
                      topRight: Radius.circular(
                          config.borderRadius - config.borderWidth),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: MediaQuery(
                        data: MediaQueryData(
                          size: Size(config.width, config.height),
                          devicePixelRatio: config.devicePixelRatio,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
              // Camera notch for MacBook
              if (config.showNotch)
                Positioned(
                  top: config.borderWidth - 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a1a2e),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3a3a4e),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Laptop hinge
        Container(
          width: config.width + (config.borderWidth * 2) + 20,
          height: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                config.borderColor,
                config.borderColor.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        // Laptop base
        Container(
          width: config.width + (config.borderWidth * 2) + 40,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                config.borderColor.withValues(alpha: 0.9),
                config.borderColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchFrame(DeviceConfig config) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top band
        Container(
          width: config.width * 0.6,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF3a3a3a),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF2a2a2a),
                Color(0xFF3a3a3a),
                Color(0xFF2a2a2a),
              ],
            ),
          ),
        ),
        // Watch body
        Container(
          width: config.width + (config.borderWidth * 2),
          height: config.height + (config.borderWidth * 2),
          decoration: BoxDecoration(
            color: config.borderColor,
            borderRadius: BorderRadius.circular(config.borderRadius),
            boxShadow: config.shadows,
            border: Border.all(
              color: const Color(0xFF4a4a4a),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Screen content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(config.borderWidth),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      config.borderRadius - config.borderWidth,
                    ),
                    child: Container(
                      color: Colors.black,
                      child: MediaQuery(
                        data: MediaQueryData(
                          size: Size(config.width, config.height),
                          devicePixelRatio: config.devicePixelRatio,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
              // Digital Crown
              Positioned(
                right: -6,
                top: config.height * 0.3,
                child: Container(
                  width: 8,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4a4a4a),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 0),
                      ),
                    ],
                  ),
                ),
              ),
              // Side button
              Positioned(
                right: -5,
                top: config.height * 0.5,
                child: Container(
                  width: 6,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3a3a3a),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom band
        Container(
          width: config.width * 0.6,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF3a3a3a),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF2a2a2a),
                Color(0xFF3a3a3a),
                Color(0xFF2a2a2a),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build screen only mode (without device frame)
  Widget _buildScreenOnly(DeviceConfig config) {
    final isLandscape = _orientation == DeviceOrientation.landscape &&
        !config.isDesktop &&
        !config.isWatch;

    double width = config.width;
    double height = config.height;

    if (isLandscape) {
      final temp = width;
      width = height;
      height = temp;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MediaQuery(
          data: MediaQueryData(
            size: Size(width, height),
            devicePixelRatio: config.devicePixelRatio,
            padding: const EdgeInsets.only(
              top: 24.0,
              bottom: 0.0,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }

  /// Dynamic Island style notch for iPhone
  Widget _buildDynamicIsland(DeviceConfig config) {
    return Center(
      child: Container(
        width: 126,
        height: 37,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            // Front camera
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF3a3a4e),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563eb),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  /// Punch hole camera style for Samsung phones
  Widget _buildPunchHoleCamera(DeviceConfig config) {
    return Center(
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: const Color(0xFF0a0a0a),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF2a2a2e),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF1a1a3e),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator(DeviceConfig config) {
    return Center(
      child: Container(
        width: _currentMode.isPhone ? 134 : 180,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildSideButtons(DeviceConfig config) {
    const buttonColor = Color(0xFF2a2a2e);

    return Stack(
      children: [
        // Power button (right side)
        Positioned(
          right: -2,
          top: config.height * 0.22,
          child: Container(
            width: 3,
            height: 80,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
          ),
        ),
        // Action button (left side, top)
        Positioned(
          left: -2,
          top: config.height * 0.15,
          child: Container(
            width: 3,
            height: 32,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(-1, 0),
                ),
              ],
            ),
          ),
        ),
        // Volume buttons (left side)
        Positioned(
          left: -2,
          top: config.height * 0.22,
          child: Column(
            children: [
              // Volume Up
              Container(
                width: 3,
                height: 45,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 2,
                      offset: const Offset(-1, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Volume Down
              Container(
                width: 3,
                height: 45,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 2,
                      offset: const Offset(-1, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phones group
          _buildDeviceGroup(
              'Phones', [DeviceMode.iphone, DeviceMode.samsungPhone]),
          const SizedBox(width: 8),
          // Tablets group
          _buildDeviceGroup(
              'Tablets', [DeviceMode.ipad, DeviceMode.samsungTablet]),
          const SizedBox(width: 8),
          // Desktop group
          _buildDeviceGroup(
              'Desktop', [DeviceMode.macbook, DeviceMode.surface]),
          const SizedBox(width: 8),
          // Watch
          _buildDeviceGroup('Watch', [DeviceMode.appleWatch]),
        ],
      ),
    );
  }

  Widget _buildDeviceGroup(String label, List<DeviceMode> modes) {
    return Container(
      decoration: BoxDecoration(
        color: _buttonBackgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modes.map((mode) => _buildModeButton(mode)).toList(),
      ),
    );
  }

  Widget _buildModeButton(DeviceMode mode) {
    // Check if this mode is selected (considering screen only state)
    final isSelected =
        _isScreenOnly ? _lastDeviceMode == mode : _currentMode == mode;

    return GestureDetector(
      onTap: () {
        if (_lastDeviceMode != mode || _isScreenOnly) {
          setState(() {
            _lastDeviceMode = mode;
            if (!_isScreenOnly) {
              _currentMode = mode;
            }
          });
          widget.onModeChanged?.call(_currentMode);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _activeButtonBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          mode.shortName,
          style: TextStyle(
            color: isSelected
                ? _foregroundColor
                : _foregroundColor.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _buttonBackgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Screen / Device toggle
              _buildToolbarButton(
                label: 'Screen',
                isActive: _isScreenOnly,
                onTap: () {
                  if (!_isScreenOnly) _toggleScreenOnly();
                },
              ),
              _buildToolbarButton(
                label: 'Device',
                isActive: !_isScreenOnly,
                onTap: () {
                  if (_isScreenOnly) _toggleScreenOnly();
                },
              ),
              _buildToolbarDivider(),
              // Orientation toggle
              _buildToolbarButton(
                label: _orientation == DeviceOrientation.portrait
                    ? 'Portrait'
                    : 'Landscape',
                isActive: false,
                onTap: _toggleOrientation,
                tooltip: 'Ctrl+Shift+R',
              ),
              _buildToolbarDivider(),
              // Theme toggle
              _buildToolbarButton(
                label: _theme == WrapperTheme.light ? 'Light' : 'Dark',
                isActive: false,
                onTap: _toggleTheme,
                tooltip: 'Ctrl+Shift+T',
              ),
              _buildToolbarDivider(),
              // Screenshot button
              _buildToolbarButton(
                label: 'Screenshot',
                isActive: false,
                onTap: _takeScreenshot,
                tooltip: 'Ctrl+Shift+S',
              ),
              _buildToolbarDivider(),
              // Hide wrapper button
              _buildToolbarButton(
                label: 'Hide',
                isActive: false,
                onTap: _toggleWrapper,
                tooltip: 'Ctrl+Shift+W',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final button = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _activeButtonBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? _foregroundColor
                : _foregroundColor.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );

    // Avoid using Tooltip here because on some platforms it created
    // a translucent hover overlay that looked like a gray box.
    // Use a MouseRegion to keep pointer interactions without showing
    // the tooltip overlay.
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: button,
    );
  }

  Widget _buildToolbarDivider() {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: _borderColor,
    );
  }
}

/// Custom painter for the grid pattern background
class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
