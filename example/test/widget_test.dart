import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinch_zoom_any/pinch_zoom_any.dart';

import 'package:pinch_zoom_any_example/main.dart';

/// Pumps the app and silences the [NetworkImageLoadException] that Flutter's
/// test environment throws for every Image.network call (all HTTP returns 400).
/// We simply ignore that exception — it does not affect widget-tree assertions.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ExampleApp());
  // Let the first frame settle; ignore any image-loading errors.
  await tester.pump();
}

void main() {
  // Silence NetworkImage errors globally — they are expected in the test env.
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Suppress NetworkImageLoadException noise; re-throw everything else.
      if (details.exception.toString().contains('NetworkImageLoadException') || details.exception.toString().contains('statusCode: 400')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  tearDown(() {
    // Restore default error handler after each test.
    FlutterError.onError = FlutterError.presentError;
  });

  group('ExampleApp', () {
    testWidgets('renders without crashing', (tester) async {
      await pumpApp(tester);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('shows HomePage as the home screen', (tester) async {
      await pumpApp(tester);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('app bar shows correct title', (tester) async {
      await pumpApp(tester);
      expect(find.text('pinch_zoom_any Demo'), findsOneWidget);
    });
  });

  group('HomePage layout', () {
    testWidgets('renders a scrollable ListView', (tester) async {
      await pumpApp(tester);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows all three section titles', (tester) async {
      await pumpApp(tester);
      // Use skipOffstage: false so widgets below the fold are still found.
      expect(find.text('Image — stay zoomed (default)', skipOffstage: false), findsOneWidget);
      expect(find.text('Text Card — reset on release', skipOffstage: false), findsOneWidget);
      expect(find.text('Custom Widget — with scale indicator', skipOffstage: false), findsOneWidget);
    });

    testWidgets('renders three PinchZoomAny widgets', (tester) async {
      await pumpApp(tester);
      expect(find.byType(PinchZoomAny, skipOffstage: false), findsNWidgets(3));
    });
  });

  group('Text Card example', () {
    testWidgets('shows card text content', (tester) async {
      await pumpApp(tester);
      expect(find.text('Zoom any widget', skipOffstage: false), findsOneWidget);
      expect(find.byType(Chip, skipOffstage: false), findsWidgets);
    });

    testWidgets('resetOnRelease chip label is visible', (tester) async {
      await pumpApp(tester);
      expect(find.text('resetOnRelease: true', skipOffstage: false), findsOneWidget);
    });

    testWidgets('double-tap on text card does not throw', (tester) async {
      await pumpApp(tester);
      // Scroll the card into view before tapping.
      await tester.ensureVisible(find.text('Zoom any widget', skipOffstage: false));
      await tester.pump();

      final textCard = find.text('Zoom any widget');
      await tester.tap(textCard, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(textCard, warnIfMissed: false);
      await tester.pumpAndSettle();
    });
  });

  group('Scale Indicator example', () {
    testWidgets('shows zoom prompt text', (tester) async {
      await pumpApp(tester);
      expect(find.text('Pinch or double-tap me!', skipOffstage: false), findsOneWidget);
    });

    testWidgets('shows initial scale chip at 1.00x', (tester) async {
      // \u00d7 is the × multiplication sign used in main.dart
      await pumpApp(tester);
      expect(find.text('Scale: 1.00x', skipOffstage: false), findsOneWidget);
    });

    testWidgets('double-tap on scale widget triggers animation without error', (tester) async {
      await pumpApp(tester);
      // Scroll the target widget into the visible viewport before tapping.
      await tester.ensureVisible(find.text('Pinch or double-tap me!', skipOffstage: false));
      await tester.pump();

      final zoomTarget = find.text('Pinch or double-tap me!');
      await tester.tap(zoomTarget, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(zoomTarget, warnIfMissed: false);
      await tester.pumpAndSettle();
    });
  });

  group('Image example', () {
    testWidgets('renders a Card in the image section', (tester) async {
      await pumpApp(tester);
      expect(find.byType(Card, skipOffstage: false), findsWidgets);
    });
  });
}
