import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
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

  const DeviceWrapper({
    super.key,
    required this.child,
    this.initialMode = DeviceMode.mobile,
    this.showModeToggle = true,
    this.mobileConfig,
    this.tabletConfig,
    this.onModeChanged,
    this.enabled = true,
    this.backgroundColor,
    this.mobileDeviceBehavior = MobileDeviceBehavior.showToggle,
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

  /// Check if running on a mobile device (iOS or Android, not web)
  bool get _isOnMobileDevice {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
           defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    
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

  void _toggleMode() async {
    await _animationController.forward();
    
    setState(() {
      _currentMode = _currentMode == DeviceMode.mobile 
          ? DeviceMode.tablet 
          : DeviceMode.mobile;
    });
    
    widget.onModeChanged?.call(_currentMode);
    
    await _animationController.reverse();
  }

  DeviceConfig get _currentConfig {
    if (_currentMode == DeviceMode.mobile) {
      return widget.mobileConfig ?? DeviceConfig.mobile;
    } else {
      return widget.tabletConfig ?? DeviceConfig.tablet;
    }
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

    final config = _currentConfig;
    final bgColor = widget.backgroundColor ?? config.backgroundColor;

    // Use Directionality to provide text direction context
    // since we're wrapping MaterialApp from outside
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scale factor to fit device within screen
          // Leave padding for toggle button (top) and device info (bottom)
          final availableHeight = constraints.maxHeight - 100; // 50 top + 50 bottom padding
          final availableWidth = constraints.maxWidth - 80; // 40 left + 40 right padding
          
          final deviceTotalHeight = config.height + (config.borderWidth * 2);
          final deviceTotalWidth = config.width + (config.borderWidth * 2);
          
          // Calculate scale to fit within available space
          final heightScale = availableHeight / deviceTotalHeight;
          final widthScale = availableWidth / deviceTotalWidth;
          
          // Use the smaller scale to ensure device fits both dimensions
          // But don't scale up beyond 1.0
          final scale = (heightScale < widthScale ? heightScale : widthScale).clamp(0.3, 1.0);
          
          return Container(
            color: bgColor,
            child: Stack(
              children: [
                // Background pattern
                _buildBackgroundPattern(bgColor),
                
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
                if (_isOnMobileDevice && widget.mobileDeviceBehavior == MobileDeviceBehavior.showToggle)
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_iphone,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Show Device Frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fullscreen_exit,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Hide Frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(Color bgColor) {
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
          color: Colors.white.withValues(alpha: 0.03),
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
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: config.width * config.devicePixelRatio,
                      height: config.height * config.devicePixelRatio,
                      child: MediaQuery(
                        data: MediaQueryData(
                          size: Size(
                            config.width * config.devicePixelRatio,
                            config.height * config.devicePixelRatio,
                          ),
                          devicePixelRatio: 1.0,
                          padding: EdgeInsets.only(
                            top: config.showNotch 
                                ? 59.0 * config.devicePixelRatio 
                                : 24.0 * config.devicePixelRatio,
                            bottom: config.showHomeIndicator 
                                ? 34.0 * config.devicePixelRatio 
                                : 0.0,
                          ),
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Dynamic Island (for iPhone 17 Pro style)
          if (config.showNotch && _currentMode == DeviceMode.mobile)
            Positioned(
              top: config.borderWidth + 12,
              left: 0,
              right: 0,
              child: _buildDynamicIsland(config),
            ),
          
          // Home indicator
          if (config.showHomeIndicator)
            Positioned(
              bottom: config.borderWidth + 8,
              left: 0,
              right: 0,
              child: _buildHomeIndicator(config),
            ),
          
          // Side buttons (volume, power)
          _buildSideButtons(config),
        ],
      ),
    );
  }

  /// Dynamic Island style notch for iPhone 17 Pro
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

  Widget _buildHomeIndicator(DeviceConfig config) {
    return Center(
      child: Container(
        width: _currentMode == DeviceMode.mobile ? 134 : 180,
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
      ],
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
        children: [
          _buildModeButton(DeviceMode.mobile, Icons.phone_android),
          _buildModeButton(DeviceMode.tablet, Icons.tablet_android),
        ],
      ),
    );
  }

  Widget _buildModeButton(DeviceMode mode, IconData icon) {
    final isSelected = _currentMode == mode;
    
    return GestureDetector(
      onTap: () {
        if (_currentMode != mode) {
          _toggleMode();
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
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                mode.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
          '${config.width.toInt()} × ${config.height.toInt()} • ${_currentMode.displayName}',
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
