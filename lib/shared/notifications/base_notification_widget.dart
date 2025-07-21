import 'package:flutter/material.dart';
import 'notification_contracts.dart';

/// Universal notification widget with smooth animations
class BaseNotificationWidget extends StatefulWidget implements INotificationWidget {
  @override
  final INotificationConfig config;
  @override
  final VoidCallback? onDismiss;
  
  final dynamic colors;
  final NotificationAnimation animation;
  final NotificationGesture gesture;
  final NotificationPosition position;

  const BaseNotificationWidget({
    super.key,
    required this.config,
    this.onDismiss,
    this.colors,
    this.animation = const NotificationAnimation(),
    this.gesture = const NotificationGesture(),
    this.position = const NotificationPosition(),
  });

  @override
  State<BaseNotificationWidget> createState() => _BaseNotificationWidgetState();
}

class _BaseNotificationWidgetState extends State<BaseNotificationWidget>
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
      duration: widget.animation.entranceDuration,
      reverseDuration: widget.animation.exitDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.animation.slideBegin,
      end: widget.animation.slideEnd,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animation.entranceCurve,
      reverseCurve: widget.animation.exitCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: widget.animation.fadeBegin,
      end: widget.animation.fadeEnd,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.animation.scaleBegin,
      end: widget.animation.scaleEnd,
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
      widget.onDismiss?.call();
      widget.config.onDismiss?.call();
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.gesture.enableSwipeToDismiss) return;
    
    if (details.delta.dy > widget.gesture.swipeThreshold) {
      dismiss();
    }
  }

  void _handleTap() {
    if (widget.gesture.enableTapToDismiss) {
      dismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.config.getStyle(widget.colors);
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
              child: Align(
                alignment: widget.position.alignment,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: widget.position.maxWidth ?? double.infinity,
                    minHeight: widget.position.minHeight ?? 0,
                  ),
                  margin: widget.position.margin.copyWith(
                    bottom: widget.position.margin.bottom + mediaQuery.padding.bottom,
                  ),
                  child: GestureDetector(
                    onPanUpdate: _handlePanUpdate,
                    onTap: _handleTap,
                    child: Material(
                      elevation: style.elevation ?? 12,
                      borderRadius: BorderRadius.circular(16),
                      color: style.backgroundColor,
                      shadowColor: style.backgroundColor.withOpacity(0.3),
                      child: Container(
                        padding: widget.position.padding,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: style.backgroundColor,
                          border: style.borderColor != null
                              ? Border.all(
                                  color: style.borderColor!,
                                  width: 1,
                                )
                              : null,
                        ),
                        child: _buildContent(style),
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

  Widget _buildContent(NotificationStyle style) {
    return Row(
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
    );
  }
}

/// Specialized loading notification widget with spinning indicator
class LoadingNotificationWidget extends StatefulWidget implements INotificationWidget {
  @override
  final INotificationConfig config;
  @override
  final VoidCallback? onDismiss;
  
  final dynamic colors;
  final NotificationAnimation animation;
  final NotificationPosition position;

  const LoadingNotificationWidget({
    super.key,
    required this.config,
    this.onDismiss,
    this.colors,
    this.animation = const NotificationAnimation(),
    this.position = const NotificationPosition(),
  });

  @override
  State<LoadingNotificationWidget> createState() => _LoadingNotificationWidgetState();
}

class _LoadingNotificationWidgetState extends State<LoadingNotificationWidget>
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
      duration: widget.animation.entranceDuration,
      reverseDuration: widget.animation.exitDuration,
      vsync: this,
    );

    _spinController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _slideAnimation = Tween<Offset>(
      begin: widget.animation.slideBegin,
      end: widget.animation.slideEnd,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: widget.animation.entranceCurve,
      reverseCurve: widget.animation.exitCurve,
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
      widget.onDismiss?.call();
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
    final style = widget.config.getStyle(widget.colors);

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: widget.position.margin,
              child: Material(
                elevation: style.elevation ?? 8,
                borderRadius: BorderRadius.circular(16),
                color: style.backgroundColor,
                child: Container(
                  padding: widget.position.padding,
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