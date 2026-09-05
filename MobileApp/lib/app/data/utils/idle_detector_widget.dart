import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widget_manager.dart';

/// Widget wrapper that monitors user activity and app lifecycle to detect
/// when the app is idle for more than a specified duration (default: 8 minutes)
/// and displays an alert snackbar on both Android and iOS.
class IdleDetectorWidget extends StatefulWidget {
  final Widget child;
  final Duration idleDuration;

  const IdleDetectorWidget({
    super.key,
    required this.child,
    this.idleDuration = const Duration(minutes: 8),
  });

  @override
  State<IdleDetectorWidget> createState() => _IdleDetectorWidgetState();
}

class _IdleDetectorWidgetState extends State<IdleDetectorWidget>
    with WidgetsBindingObserver {
  Timer? _idleTimer;
  DateTime? _lastBackgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetIdleTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _lastBackgroundTime = DateTime.now();
      _idleTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastBackgroundTime != null) {
        final backgroundDuration = DateTime.now().difference(
          _lastBackgroundTime!,
        );
        if (backgroundDuration >= widget.idleDuration) {
          _showIdleSnackbar();
        }
      }
      _resetIdleTimer();
    }
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(widget.idleDuration, () {
      _showIdleSnackbar();
      // Restart timer after showing snackbar
      _resetIdleTimer();
    });
  }

  void _showIdleSnackbar() {
    print("show idle app.......");
    WidgetManager.showSnackBar(
      title: 'Idle Alert',
      message: 'You have been inactive for more than 8 minutes.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF28283C),
      textColor: Colors.white,
      icon: Icons.timer_outlined,
      duration: const Duration(seconds: 4),
    );
  }

  void _userInteracted() {
    _resetIdleTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _userInteracted(),
      onPointerMove: (_) => _userInteracted(),
      onPointerUp: (_) => _userInteracted(),
      child: widget.child,
    );
  }
}
