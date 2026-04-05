import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinch_zoom_any/pinch_zoom_any.dart';

void main() {
  group('PinchZoomAny — constructor assertions', () {
    test('throws if minScale <= 0', () {
      expect(() => PinchZoomAny(minScale: 0, child: const SizedBox()), throwsAssertionError);
    });

    test('throws if maxScale < minScale', () {
      expect(() => PinchZoomAny(minScale: 2.0, maxScale: 1.0, child: const SizedBox()), throwsAssertionError);
    });

    test('throws if doubleTapScale is out of [minScale, maxScale]', () {
      expect(() => PinchZoomAny(minScale: 1.0, maxScale: 3.0, doubleTapScale: 5.0, child: const SizedBox()), throwsAssertionError);
    });

    test('does not throw with valid parameters', () {
      expect(() => PinchZoomAny(minScale: 1.0, maxScale: 4.0, doubleTapScale: 2.0, child: const SizedBox()), returnsNormally);
    });
  });

  group('PinchZoomAny — widget tree', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PinchZoomAny(child: Text('hello'))),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('renders GestureDetector and ClipRect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PinchZoomAny(child: SizedBox(width: 100, height: 100))),
        ),
      );

      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.byType(ClipRect), findsOneWidget);
    });
  });

  group('PinchZoomAny — double-tap', () {
    testWidgets('double-tap triggers without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: PinchZoomAny(doubleTapScale: 2.0, child: SizedBox(width: 200, height: 200))),
          ),
        ),
      );

      await tester.tap(find.byType(SizedBox).first);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(SizedBox).first);
      await tester.pumpAndSettle();

      // No exception = pass
    });
  });

  group('PinchZoomAny — onScaleChanged callback', () {
    testWidgets('onScaleChanged is not null when provided', (tester) async {
      double? lastScale;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinchZoomAny(onScaleChanged: (scale) => lastScale = scale, child: const SizedBox(width: 200, height: 200)),
          ),
        ),
      );

      // Initial state — callback not yet fired
      expect(lastScale, isNull);
    });
  });

  group('PinchZoomAny — default parameters', () {
    test('default values are correct', () {
      const widget = PinchZoomAny(child: SizedBox());
      expect(widget.minScale, 1.0);
      expect(widget.maxScale, 4.0);
      expect(widget.doubleTapScale, 2.0);
      expect(widget.resetOnRelease, false);
      expect(widget.clipBehavior, Clip.hardEdge);
    });
  });
}
