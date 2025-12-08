import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';

import 'device_config.dart';
import 'device_mode.dart';

/// Behavior when running on a mobile device
enum MobileDeviceBehavior {
  /// Always show the device frame wrapper
  alwaysShowFrame,

  /// Always render child directly without frame
  alwaysHideFrame,

  /// Show a toggle to let user choose
  showToggle,
}

/// A widget that wraps its child in a device frame with fixed dimensions.
///
/// This is useful for previewing mobile/tablet layouts on web or desktop,
/// simulating how the app would look on actual devices.
///
/// Example usage:
/// ```dart
/// DeviceWrapper(
///   initialMode: DeviceMode.mobile,
///   showModeToggle: true,
///   child: MyApp(),
/// )
/// ```
class DeviceWrapper extends StatefulWidget {
  /// The child widget to wrap inside the device frame
  final Widget child;

  /// Device List
  final List<DeviceConfig> deviceList;

  /// Initial device
  final DeviceConfig? initialDevice;

  /// Whether to show the mode toggle button
  final bool showModeToggle;

  /// Callback when device mode changes
  final ValueChanged<DeviceConfig>? onModeChanged;

  /// Whether the wrapper is enabled (if false, child is rendered directly)
  final bool enabled;

  /// Background color for the area outside the device frame
  final Color backgroundColor;

  /// Grid line color for the area outside the device frame
  final Color? gridColor;

  /// Default TextStyle for the area outside the device frame
  final TextStyle textStyle;

  /// Device brightness (If the DeviceWrapper child is MaterialApp, set brightness)
  final Brightness? brightness;

  /// Behavior when app is running on a mobile device (iOS/Android)
  /// - [MobileDeviceBehavior.alwaysShowFrame]: Always show device frame
  /// - [MobileDeviceBehavior.alwaysHideFrame]: Always render child directly
  /// - [MobileDeviceBehavior.showToggle]: Show toggle to let user choose
  final MobileDeviceBehavior mobileDeviceBehavior;

  const DeviceWrapper({
    super.key,
    required this.child,
    this.deviceList = DeviceConfig.deviceList,
    this.initialDevice,
    this.showModeToggle = true,
    this.onModeChanged,
    this.enabled = true,
    this.backgroundColor = Colors.black,
    this.gridColor = const Color(0x1AFFFFFF),
    this.brightness,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    this.mobileDeviceBehavior = MobileDeviceBehavior.showToggle,
  });

  @override
  State<DeviceWrapper> createState() => _DeviceWrapperState();
}

class _DeviceWrapperState extends State<DeviceWrapper>
    with SingleTickerProviderStateMixin {
  late DeviceConfig _currentDevice;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showDeviceFrame = true;

  /// Check if running on a mobile device (iOS or Android, not web)
  bool get _isOnMobileDevice {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  void initState() {
    super.initState();
    _currentDevice = widget.initialDevice ?? widget.deviceList.first;

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
    super.dispose();
  }

  void _setDevice(DeviceConfig device) async {
    await _animationController.forward();

    setState(() {
      _currentDevice = device;
    });

    widget.onModeChanged?.call(_currentDevice);

    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // If wrapper is disabled, render child directly
    if (!widget.enabled) {
      return widget.child;
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

    final config = _currentDevice;
    final bgColor = config.backgroundColor ?? widget.backgroundColor;

    final gridColor = config.gridColor ?? widget.gridColor;

    // Use Directionality to provide text direction context
    // since we're wrapping MaterialApp from outside
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        // Eliminate double underline warning on Text widgets
        style: widget.textStyle,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate scale factor to fit device within screen
            // Leave padding for toggle button (top) and device info (bottom)
            final availableHeight =
                constraints.maxHeight - 100; // 50 top + 50 bottom padding
            final availableWidth =
                constraints.maxWidth - 80; // 40 left + 40 right padding

            final deviceTotalHeight = config.height + (config.borderWidth * 2);
            final deviceTotalWidth = config.width + (config.borderWidth * 2);

            // Calculate scale to fit within available space
            final heightScale = availableHeight / deviceTotalHeight;
            final widthScale = availableWidth / deviceTotalWidth;

            // Use the smaller scale to ensure device fits both dimensions
            // But don't scale up beyond 1.0
            final scale = (heightScale < widthScale ? heightScale : widthScale)
                .clamp(0.3, 1.0);

            return Container(
              color: bgColor,
              child: Stack(
                children: [
                  if (gridColor != null)
                    // Background pattern
                    _buildBackgroundPattern(bgColor, gridColor),

                  // Device frame centered with auto-scaling
                  Center(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value * scale,
                          child: child,
                        );
                      },
                      child: _buildDeviceFrame(config),
                    ),
                  ),

                  // Mode toggle button
                  if (widget.showModeToggle)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: _buildModeToggle(),
                    ),

                  // Hide device frame button (only on mobile with showToggle behavior)
                  if (_isOnMobileDevice &&
                      widget.mobileDeviceBehavior ==
                          MobileDeviceBehavior.showToggle)
                    Positioned(
                      top: 20,
                      left: 20,
                      child: _buildHideFrameButton(),
                    ),

                  // Device info label
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: _buildDeviceInfoLabel(config),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build overlay for mobile devices with toggle option
  Widget _buildMobileToggleOverlay() {
    return Stack(
      children: [
        // Render the actual app
        widget.child,

        // Floating button to show device frame
        Positioned(
          bottom: 20,
          right: 20,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showDeviceFrame = true;
                  });
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_iphone,
                        color: widget.textStyle.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Show Device Frame',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build button to hide device frame (shown when frame is visible on mobile)
  Widget _buildHideFrameButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _showDeviceFrame = false;
          });
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fullscreen_exit,
                color: widget.textStyle.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Hide Frame',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(Color bgColor, Color gridColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            bgColor.withValues(alpha: 0.8),
            bgColor,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _GridPatternPainter(
          color: gridColor,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildDeviceFrame(DeviceConfig config) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: config.width + (config.borderWidth * 2),
      height: config.height + (config.borderWidth * 2),
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
        // fix side buttons clipping
        clipBehavior: Clip.none,
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
                  color: Colors.white,
                  child: MediaQuery(
                    data: MediaQueryData(
                      size: Size(config.width, config.height),
                      devicePixelRatio: config.devicePixelRatio,
                      // fix CupertinoNavigationBar safe padding is zero
                      viewPadding: _currentDevice.safePadding,
                      padding: _currentDevice.safePadding,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),

          // Dynamic Island (for iPhone 17 Pro style)
          if (config.showNotch && _currentDevice.mode == DeviceMode.mobile)
            Positioned(
              top: config.borderWidth + 12,
              left: 0,
              right: 0,
              child: _buildDynamicIsland(config),
            ),

          // Status bar
          if (config.showStatusBar && _currentDevice.mode != DeviceMode.desktop)
            Positioned(
              top: config.borderWidth +
                  math.max((config.safePadding.top - 24) / 2, 0),
              left: config.borderWidth,
              right: config.borderWidth,
              child: _buildStatusBar(config),
            ),

          // Home indicator
          if (config.showHomeIndicator)
            Positioned(
              bottom: config.borderWidth + 8,
              left: 0,
              right: 0,
              child: _buildHomeIndicator(config),
            ),

          // Traffic Light Buttons
          if (config.showStatusBar && _currentDevice.mode == DeviceMode.desktop)
            Positioned(
              top: config.borderWidth +
                  math.max((config.safePadding.top - 24) / 2, 0),
              left: config.borderWidth + 10,
              child: _buildTrafficLightButtons(config),
            ),

          // Side buttons (volume, power)
          if (_currentDevice.borderWidth > 0 &&
              (_currentDevice.mode == DeviceMode.mobile ||
                  _currentDevice.mode == DeviceMode.tablet))
            ..._buildSideButtons(config),
        ],
      ),
    );
  }

  /// Dynamic Island style notch for iPhone 17 Pro
  Widget _buildDynamicIsland(DeviceConfig config) {
    return Center(
      child: Container(
        width: 126,
        height: 38,
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

  Widget _buildStatusBar(DeviceConfig config) {
    final brightness = widget.brightness ?? Theme.of(context).brightness;
    return Container(
      height: 24,
      width: config.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          centerSlice: const Rect.fromLTWH(80, 0, 10, 24),
          image: AssetImage(
            'assets/images/iphone_status_bar_${brightness == Brightness.light ? 'black' : 'white'}.png',
            package: 'device_wrapper',
          ),
          fit: BoxFit.fill,
          scale: 3,
        ),
      ),
    );
  }

  Widget _buildHomeIndicator(DeviceConfig config) {
    final brightness = widget.brightness ?? Theme.of(context).brightness;
    return Center(
      child: Container(
        width: _currentDevice.mode == DeviceMode.mobile ? 134 : 180,
        height: 5,
        decoration: BoxDecoration(
          color: (brightness == Brightness.light ? Colors.black : Colors.white)
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  List<Widget> _buildSideButtons(DeviceConfig config) {
    const buttonColor = Color(0xFF2a2a2e);

    return [
      // Power button (right side) - iPhone style
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
      // Action button (left side, top) - iPhone 15+ style
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
    ];
  }

  Widget _buildTrafficLightButtons(DeviceConfig config) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 24,
      child: Row(
        spacing: 8,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFF605C),
              shape: BoxShape.circle,
            ),
            width: 10,
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFBD44),
              shape: BoxShape.circle,
            ),
            width: 10,
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00CA4E),
              shape: BoxShape.circle,
            ),
            width: 10,
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.deviceList
            .map((device) => _buildModeButton(device))
            .toList(),
      ),
    );
  }

  Widget _buildModeButton(DeviceConfig device) {
    final isSelected = _currentDevice == device;

    return GestureDetector(
      onTap: () {
        if (_currentDevice != device) {
          _setDevice(device);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              device.icon,
              color: isSelected
                  ? widget.textStyle.color
                  : widget.textStyle.color?.withValues(alpha: 0.6),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(device.name),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoLabel(DeviceConfig config) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${config.width.toInt()} × ${config.height.toInt()} • ${_currentDevice.name}',
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
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
