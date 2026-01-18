import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class CustomSnackbar {
  static final Duration _defaultDuration = const Duration(seconds: 2);

  static void _show(
    BuildContext context,
    Widget child, {
    Duration duration = const Duration(seconds: 2),
    bool dismissible = true,
    bool isTop = false,
  }) {
    // Try root navigator overlay first (may throw if no Navigator), then Get navigatorKey, then Overlay.of
    OverlayState? overlayState;
    try {
      overlayState = Navigator.of(context, rootNavigator: true).overlay;
    } catch (_) {
      overlayState = null;
    }

    if (overlayState == null) {
      // Overlay.of returns non-nullable in this SDK, use it as fallback
      overlayState = Overlay.of(context);
    }

    late OverlayEntry entry;
    Timer? timer;

    void removeEntry() {
      try {
        if (timer?.isActive ?? false) timer?.cancel();
      } catch (_) {}
      if (entry.mounted) entry.remove();
    }

    entry = OverlayEntry(builder: (ctx) {
      return _SnackbarOverlay(
        child: child,
        dismissible: dismissible,
        isTop: isTop,
        onDismiss: removeEntry,
      );
    });

    // overlayState is guaranteed non-null by previous fallback, but guard anyway
    if (overlayState != null) {
      overlayState.insert(entry);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final s = Overlay.of(context);
          s.insert(entry);
        } catch (_) {
          // ignore
        }
      });
    }

    timer = Timer(duration, () {
      if (entry.mounted) entry.remove();
    });
  }

  /// A light, subtle snackbar used for "Add to Cart".
  static void showLight(String title, String message, {BuildContext? context, Duration? duration}) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    // Try to locate an Overlay; if not available, fallback to ScaffoldMessenger
    OverlayState? overlayState;
    try {
      overlayState = Navigator.of(ctx, rootNavigator: true).overlay;
    } catch (_) {
      overlayState = null;
    }
    overlayState ??= Overlay.of(ctx);

    if (overlayState != null) {
      final content = _buildLightContent(title, message);
      _show(
        ctx,
        content,
        duration: duration ?? _defaultDuration,
        dismissible: true,
        isTop: false,
      );
    } else {
      // Safe fallback: use ScaffoldMessenger
      try {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF199A8E).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF199A8E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(message, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          duration: duration ?? _defaultDuration,
        ));
      } catch (_) {
        // Last resort: print
        if (kDebugMode) print('Snackbar fallback failed: $title - $message');
      }
    }
  }

  /// A more prominent accent snackbar for errors, warnings or confirmations.
  static void showAccent(String title, String message, {BuildContext? context, Duration? duration}) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    OverlayState? overlayState;
    try {
      overlayState = Navigator.of(ctx, rootNavigator: true).overlay;
    } catch (_) {
      overlayState = null;
    }
    overlayState ??= Overlay.of(ctx);

    if (overlayState != null) {
      final content = _buildAccentContent(title, message);
      _show(
        ctx,
        content,
        duration: duration ?? const Duration(seconds: 3),
        dismissible: true,
        isTop: true,
      );
    } else {
      try {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          backgroundColor: const Color(0xFF199A8E),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 2),
              Text(message, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          duration: duration ?? const Duration(seconds: 3),
        ));
      } catch (_) {
        if (kDebugMode) print('Snackbar fallback failed: $title - $message');
      }
    }
  }

  // Convenience API compatible with previous SnackbarUtils
  static void showError(String title, String message, {BuildContext? context, Duration? duration}) {
    showAccent(title, message, context: context, duration: duration);
  }

  static void showSuccess(String title, String message, {BuildContext? context, Duration? duration}) {
    // Use accent for success as well for visibility (can be changed to light)
    showAccent(title, message, context: context, duration: duration);
  }

  static void showCopied(String item, {BuildContext? context, Duration? duration}) {
    showLight('Copied', '$item copied to clipboard', context: context, duration: duration ?? const Duration(seconds: 2));
  }

  static void showInfo(String title, String message, {BuildContext? context, Duration? duration}) {
    showLight(title, message, context: context, duration: duration);
  }

  static Widget _buildLightContent(String title, String message) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF199A8E).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Color(0xFF199A8E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Close will be handled by overlay removal triggered by the duration
                    // But we can call Navigator.pop if desired; overlay doesn't have direct API here.
                    final ctx = Get.context;
                    if (ctx != null) {
                      // trigger a rebuild to remove overlay by inserting a zero-delay future
                      // (no-op but keeps consistent behavior). In this implementation, we rely
                      // on the duration to auto-remove.
                    }
                  },
                  child: Icon(Icons.close, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildAccentContent(String title, String message) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF199A8E), Color(0xFF17C3B2)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(46),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 800),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated overlay wrapper that handles entrance/exit animations and dismiss gestures.
class _SnackbarOverlay extends StatefulWidget {
  final Widget child;
  final bool dismissible;
  final bool isTop;
  final VoidCallback onDismiss;

  const _SnackbarOverlay({
    Key? key,
    required this.child,
    required this.dismissible,
    required this.onDismiss,
    this.isTop = false,
  }) : super(key: key);

  @override
  State<_SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<_SnackbarOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final Animation<Offset> _offset;
  late final Animation<double> _fade;
  bool _isHiding = false;

  @override
  void initState() {
    super.initState();
    final beginOffset = widget.isTop ? const Offset(0, -0.25) : const Offset(0, 0.25);
    _offset = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  Future<void> _hide() async {
    if (_isHiding) return;
    _isHiding = true;
    await _ctrl.reverse();
    try {
      widget.onDismiss();
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Background tap to dismiss
            if (widget.dismissible)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hide,
                child: const SizedBox.expand(),
              ),
            // Animated child (slide + fade)
            SafeArea(
              child: Align(
                alignment: widget.isTop ? Alignment.topCenter : Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: SlideTransition(
                    position: _offset,
                    child: FadeTransition(
                      opacity: _fade,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
