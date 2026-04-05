import 'package:flutter/material.dart';
import '../models/preview_config.dart';
import 'blur_background.dart';

class _ActionButton extends StatefulWidget {
  final PreviewAction action;
  final VoidCallback onTap;

  const _ActionButton({required this.action, required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color =
        widget.action.isDestructive ? Colors.red : Colors.black87;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed
            ? Colors.black.withValues(alpha: 0.07)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (widget.action.icon != null) ...[
              Icon(widget.action.icon, size: 20, color: color),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                widget.action.label,
                style: TextStyle(fontSize: 15, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Manages the overlay entry for the preview popup.
class PreviewOverlayController {
  OverlayEntry? _entry;
  OverlayEntry? _bgEntry;
  AnimationController? _animController;

  bool get isShowing => _entry != null;

  void show({
    required BuildContext context,
    required Widget previewWidget,
    required PreviewConfig config,
    required VoidCallback onDismiss,
    VoidCallback? onPreviewTap,
  }) {
    if (isShowing) return;

    final overlay = Overlay.of(context);
    late final AnimationController ac;
    ac = AnimationController(
      vsync: Navigator.of(context),
      duration: config.animationDuration,
    );
    _animController = ac;

    final animation = CurvedAnimation(parent: ac, curve: Curves.easeOutBack);
    final fadeAnim = CurvedAnimation(parent: ac, curve: Curves.easeOut);

    _bgEntry = OverlayEntry(
      builder: (_) => BlurBackground(
        animation: fadeAnim,
        barrierColor: config.barrierColor,
        onTap: () => hide(onDismiss: onDismiss),
      ),
    );

    _entry = OverlayEntry(
      builder: (_) => _PreviewPopup(
        animation: animation,
        fadeAnimation: fadeAnim,
        previewWidget: previewWidget,
        config: config,
        onDismiss: () => hide(onDismiss: onDismiss),
        onPreviewTap: onPreviewTap,
      ),
    );

    overlay.insert(_bgEntry!);
    overlay.insert(_entry!);
    ac.forward();
  }

  void hide({required VoidCallback onDismiss}) {
    _animController?.reverse().then((_) {
      _entry?.remove();
      _bgEntry?.remove();
      _entry = null;
      _bgEntry = null;
      _animController?.dispose();
      _animController = null;
      onDismiss();
    });
  }
}

class _PreviewPopup extends StatefulWidget {
  final Animation<double> animation;
  final Animation<double> fadeAnimation;
  final Widget previewWidget;
  final PreviewConfig config;
  final VoidCallback onDismiss;
  final VoidCallback? onPreviewTap;

  const _PreviewPopup({
    required this.animation,
    required this.fadeAnimation,
    required this.previewWidget,
    required this.config,
    required this.onDismiss,
    this.onPreviewTap,
  });

  @override
  State<_PreviewPopup> createState() => _PreviewPopupState();
}

class _PreviewPopupState extends State<_PreviewPopup> {
  double _dragDelta = 0;

  /// Maps an alignment component (-1…1) to a pixel offset, clamped to screen.
  double _alignedPosition(double screen, double popup, double alignment) {
    const padding = 16.0;
    final pos = (alignment + 1) / 2 * (screen - popup - padding * 2) + padding;
    return pos.clamp(padding, screen - popup - padding);
  }

  Widget _buildStaticContent(double popupWidth, double popupHeight) {
    final popup = GestureDetector(
      onTap: widget.onPreviewTap != null
          ? () {
              widget.onDismiss();
              widget.onPreviewTap!();
            }
          : null,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: popupWidth,
          constraints: BoxConstraints(maxHeight: popupHeight),
          decoration: BoxDecoration(
            color: widget.config.backgroundColor,
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(child: widget.previewWidget),
        ),
      ),
    );

    final actions = widget.config.actions;
    if (actions.isEmpty) return popup;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        popup,
        const SizedBox(height: 8),
        SizedBox(
          width: popupWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: widget.config.backgroundColor,
                borderRadius: BorderRadius.circular(widget.config.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    _ActionButton(
                      action: actions[i],
                      onTap: () {
                        widget.onDismiss();
                        actions[i].onTap();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _applyAnimation(Widget child) {
    final opacity = widget.fadeAnimation.value.clamp(0.0, 1.0);
    switch (widget.config.animation) {
      case PreviewAnimation.scaleFromChild:
        return Transform.scale(
          scale: widget.animation.value,
          child: Opacity(opacity: opacity, child: child),
        );
      case PreviewAnimation.slideFromBottom:
        return Transform.translate(
          offset: Offset(0, (1 - widget.animation.value) * 80),
          child: Opacity(opacity: opacity, child: child),
        );
      case PreviewAnimation.fadeIn:
        return Opacity(opacity: opacity, child: child);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final popupWidth = widget.config.previewWidth ?? screenSize.width * 0.90;
    final popupHeight = widget.config.previewHeight ?? screenSize.height * 0.60;
    final baseTop = _alignedPosition(screenSize.height, popupHeight, widget.config.alignment.y);
    final left = _alignedPosition(screenSize.width, popupWidth, widget.config.alignment.x);

    return AnimatedBuilder(
      animation: widget.animation,
      child: _buildStaticContent(popupWidth, popupHeight),
      builder: (context, child) {
        return Positioned(
          top: baseTop + _dragDelta,
          left: left,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragDelta = (_dragDelta + details.delta.dy).clamp(-80.0, 80.0);
              });
              if (details.delta.dy > 12) widget.onDismiss();
            },
            onVerticalDragEnd: (_) => setState(() => _dragDelta = 0),
            child: _applyAnimation(child!),
          ),
        );
      },
    );
  }
}
