import 'package:flutter/material.dart';

/// A widget that wraps any child and adds pinch-to-zoom, pan,
/// double-tap to zoom, and double-tap to reset functionality.
class PinchZoomAny extends StatefulWidget {
  /// The widget to make zoomable.
  final Widget child;

  /// Minimum allowed scale. Defaults to [1.0].
  final double minScale;

  /// Maximum allowed scale. Defaults to [4.0].
  final double maxScale;

  /// Scale level jumped to on double-tap (when not already zoomed).
  /// Defaults to [2.0].
  final double doubleTapScale;

  /// If [true], the widget snaps back to its original scale and position
  /// when the user lifts all fingers. Defaults to [false].
  final bool resetOnRelease;

  /// Clipping behaviour applied to the zoomed child. Defaults to
  /// [Clip.hardEdge].
  final Clip clipBehavior;

  /// Called whenever the scale changes.
  final ValueChanged<double>? onScaleChanged;

  const PinchZoomAny({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.doubleTapScale = 2.0,
    this.resetOnRelease = false,
    this.clipBehavior = Clip.hardEdge,
    this.onScaleChanged,
  }) : assert(minScale > 0, 'minScale must be greater than 0'),
       assert(maxScale >= minScale, 'maxScale must be >= minScale'),
       assert(doubleTapScale >= minScale && doubleTapScale <= maxScale, 'doubleTapScale must be between minScale and maxScale');

  @override
  State<PinchZoomAny> createState() => _PinchZoomAnyState();
}

class _PinchZoomAnyState extends State<PinchZoomAny> with SingleTickerProviderStateMixin {
  // Current transformation state
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  // State captured at the start of each gesture
  double _initialScale = 1.0;
  Offset _initialOffset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;

  // Animation controller for snap-back
  late AnimationController _animationController;
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))..addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ── Animation ────────────────────────────────────────────────────────────

  void _animateTo({required double targetScale, required Offset targetOffset}) {
    _animationController.stop();

    _scaleAnimation = Tween<double>(
      begin: _scale,
      end: targetScale,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _offsetAnimation = Tween<Offset>(
      begin: _offset,
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward(from: 0);
  }

  void _onAnimationTick() {
    setState(() {
      if (_scaleAnimation != null) _scale = _scaleAnimation!.value;
      if (_offsetAnimation != null) _offset = _offsetAnimation!.value;
    });
    widget.onScaleChanged?.call(_scale);
  }

  // ── Gesture handlers ─────────────────────────────────────────────────────

  void _onScaleStart(ScaleStartDetails details) {
    _animationController.stop();
    _initialScale = _scale;
    _initialOffset = _offset;
    _initialFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = (_initialScale * details.scale).clamp(widget.minScale, widget.maxScale);

    // Pan delta: follow the focal point movement plus compensate for
    // the scale change relative to the focal point.
    final Offset scaleDelta = (details.focalPoint - _initialFocalPoint);
    final Offset scaleOffsetCompensation = (_initialFocalPoint - _initialOffset) * (1 - details.scale);
    final Offset newOffset = _initialOffset + scaleDelta + scaleOffsetCompensation;

    setState(() {
      _scale = newScale;
      _offset = newOffset;
    });
    widget.onScaleChanged?.call(_scale);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (widget.resetOnRelease) {
      _animateTo(targetScale: widget.minScale, targetOffset: Offset.zero);
      return;
    }

    // If scale went below minScale, snap back
    if (_scale < widget.minScale) {
      _animateTo(targetScale: widget.minScale, targetOffset: Offset.zero);
    }
  }

  void _onDoubleTap() {
    _animationController.stop();

    if (_scale > widget.minScale) {
      // Already zoomed → reset
      _animateTo(targetScale: widget.minScale, targetOffset: Offset.zero);
    } else {
      // Zoom in to doubleTapScale, centred
      _animateTo(targetScale: widget.doubleTapScale, targetOffset: Offset.zero);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: ClipRect(
        clipBehavior: widget.clipBehavior,
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
