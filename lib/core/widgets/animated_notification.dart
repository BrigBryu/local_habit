import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_controller.dart';

/// Custom animated notification widget that slides in from bottom
class AnimatedNotification extends ConsumerStatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;
  final Widget? action;
  final VoidCallback? onDismiss;

  const AnimatedNotification({
    super.key,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.action,
    this.onDismiss,
  });

  @override
  ConsumerState<AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends ConsumerState<AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // Start animation
    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;
    
    // Get colors based on type
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (widget.type) {
      case NotificationType.success:
        backgroundColor = colors.success;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = colors.error;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = colors.draculaOrange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case NotificationType.info:
        backgroundColor = colors.draculaCyan;
        textColor = colors.draculaBackground;
        icon = Icons.info;
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: backgroundColor,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    // Allow swipe down to dismiss
                    if (details.delta.dy > 3) {
                      _dismiss();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: backgroundColor,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (widget.action != null) ...[
                          const SizedBox(width: 12),
                          widget.action!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Overlay manager for showing notifications
class NotificationOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context,
    String message,
    NotificationType type, {
    Duration duration = const Duration(seconds: 3),
    Widget? action,
  }) {
    // Remove existing notification
    dismiss();

    final overlay = Overlay.of(context);
    
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: AnimatedNotification(
          message: message,
          type: type,
          duration: duration,
          action: action,
          onDismiss: () {
            dismiss();
          },
        ),
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

enum NotificationType {
  success,
  error,
  warning,
  info,
}