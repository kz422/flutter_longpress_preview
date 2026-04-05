import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/preview_config.dart';
import '../overlay/preview_overlay.dart';

/// Wraps [child] so that long-pressing it shows [preview] as a popup overlay.
///
/// Similar to Safari's link preview or Instagram's peek feature.
///
/// ```dart
/// LongPressPreview(
///   preview: MyDetailWidget(),
///   child: MyThumbnailWidget(),
/// )
/// ```
class LongPressPreview extends StatefulWidget {
  /// The widget that the user long-presses to trigger the preview.
  final Widget child;

  /// The widget shown inside the preview popup.
  final Widget preview;

  /// Appearance and behavior configuration.
  final PreviewConfig config;

  /// Called when the preview popup opens.
  final VoidCallback? onPreviewOpen;

  /// Called when the preview popup closes.
  final VoidCallback? onPreviewClose;

  /// Called on a normal (non-long) tap.
  final VoidCallback? onTap;

  /// Called when the preview popup itself is tapped.
  final VoidCallback? onPreviewTap;

  /// Creates a [LongPressPreview].
  const LongPressPreview({
    super.key,
    required this.child,
    required this.preview,
    this.config = const PreviewConfig(),
    this.onPreviewOpen,
    this.onPreviewClose,
    this.onTap,
    this.onPreviewTap,
  });

  @override
  State<LongPressPreview> createState() => _LongPressPreviewState();
}

class _LongPressPreviewState extends State<LongPressPreview>
    with SingleTickerProviderStateMixin {
  final _overlayController = PreviewOverlayController();

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.stop();
    _scaleController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_overlayController.isShowing) return;
    if (widget.config.enableHaptics) {
      HapticFeedback.mediumImpact();
    }
    _scaleController.forward();

    _overlayController.show(
      context: context,
      previewWidget: widget.preview,
      config: widget.config,
      onDismiss: _onDismiss,
      onPreviewTap: widget.onPreviewTap,
    );

    widget.onPreviewOpen?.call();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _scaleController.reverse();
    // Keep the popup open when actions are configured so the user can tap one.
    if (_overlayController.isShowing && widget.config.actions.isEmpty) {
      _overlayController.hide(onDismiss: _onDismiss);
    }
  }

  void _onDismiss() {
    if (!mounted) return;
    widget.onPreviewClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
