import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_controller.dart';
import 'notification_types.dart';

/// Universal notification widget with consistent styling and animations
class UniversalNotification extends ConsumerStatefulWidget {
  final NotificationConfig config;

  const UniversalNotification({
    super.key,
    required this.config,
  });

  @override
  ConsumerState<UniversalNotification> createState() => _UniversalNotificationState();
}

class _UniversalNotificationState extends ConsumerState<UniversalNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide animation with bounce effect
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInQuart,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    ));

    // Scale animation for subtle entry effect
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      reverseCurve: Curves.easeIn,
    ));
  }

  void _startAnimation() {
    _controller.forward();
    
    // Auto-dismiss after duration
    Future.delayed(widget.config.duration, () {
      if (mounted) {
        dismiss();
      }
    });
  }

  Future<void> dismiss() async {
    if (_controller.isCompleted) {
      await _controller.reverse();
    }
    if (mounted) {
      widget.config.onDismiss?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;
    final style = widget.config.getStyle(colors);
    final mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: mediaQuery.padding.bottom + 16,
                ),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    // Swipe down to dismiss
                    if (details.delta.dy > 4) {
                      dismiss();
                    }
                  },
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(16),
                    color: style.backgroundColor,
                    shadowColor: style.backgroundColor.withOpacity(0.3),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: style.backgroundColor,
                        border: Border.all(
                          color: style.backgroundColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              style.icon,
                              color: style.iconColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Message
                          Expanded(
                            child: Text(
                              widget.config.message,
                              style: TextStyle(
                                color: style.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                          
                          // Action button
                          if (widget.config.action != null) ...[
                            const SizedBox(width: 12),
                            widget.config.action!,
                          ],
                        ],
                      ),
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

/// Specialized loading notification with spinning indicator
class LoadingNotificationWidget extends ConsumerStatefulWidget {
  final LoadingNotification config;

  const LoadingNotificationWidget({
    super.key,
    required this.config,
  });

  @override
  ConsumerState<LoadingNotificationWidget> createState() => _LoadingNotificationWidgetState();
}

class _LoadingNotificationWidgetState extends ConsumerState<LoadingNotificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _spinController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _spinController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
  }

  void _startAnimation() {
    _slideController.forward();
    
    // Auto-dismiss after duration
    Future.delayed(widget.config.duration, () {
      if (mounted) {
        dismiss();
      }
    });
  }

  Future<void> dismiss() async {
    if (_slideController.isCompleted) {
      await _slideController.reverse();
    }
    if (mounted) {
      widget.config.onDismiss?.call();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;
    final style = widget.config.getStyle(colors);

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: style.backgroundColor,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: style.backgroundColor,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Spinning loading indicator
                      AnimatedBuilder(
                        animation: _spinController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _spinController.value * 2 * 3.14159,
                            child: Icon(
                              Icons.refresh,
                              color: style.iconColor,
                              size: 22,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      
                      // Message
                      Expanded(
                        child: Text(
                          widget.config.message,
                          style: TextStyle(
                            color: style.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // Action button
                      if (widget.config.action != null) ...[
                        const SizedBox(width: 12),
                        widget.config.action!,
                      ],
                    ],
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