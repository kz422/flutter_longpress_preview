import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:longpress_preview/longpress_preview.dart';

// Shared helper: pumps a LongPressPreview and returns the started gesture.
Future<TestGesture> _longPress(
  WidgetTester tester,
  String childText, {
  Duration duration = const Duration(milliseconds: 400),
}) async {
  final gesture =
      await tester.startGesture(tester.getCenter(find.text(childText)));
  await tester.pump(duration);
  await tester.pumpAndSettle();
  return gesture;
}

void main() {
  group('LongPressPreview', () {
    testWidgets('renders child, preview hidden initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LongPressPreview(
              preview: Text('Preview content'),
              child: Text('Long press me'),
            ),
          ),
        ),
      );
      expect(find.text('Long press me'), findsOneWidget);
      expect(find.text('Preview content'), findsNothing);
    });

    testWidgets('shows preview on long press', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LongPressPreview(
              config: PreviewConfig(enableHaptics: false),
              preview: Text('Preview content'),
              child: Text('Long press me'),
            ),
          ),
        ),
      );

      final gesture = await _longPress(tester, 'Long press me');
      expect(find.text('Preview content'), findsOneWidget);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('dismisses preview when finger is lifted (no actions)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LongPressPreview(
              config: PreviewConfig(enableHaptics: false),
              preview: Text('Preview content'),
              child: Text('Long press me'),
            ),
          ),
        ),
      );

      final gesture = await _longPress(tester, 'Long press me');
      expect(find.text('Preview content'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Preview content'), findsNothing);
    });

    testWidgets('calls onTap on normal tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressPreview(
              preview: const Text('Preview'),
              onTap: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('calls onPreviewOpen and onPreviewClose', (tester) async {
      bool opened = false;
      bool closed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LongPressPreview(
              config: const PreviewConfig(enableHaptics: false),
              preview: const Text('Preview'),
              onPreviewOpen: () => opened = true,
              onPreviewClose: () => closed = true,
              child: const Text('Long press me'),
            ),
          ),
        ),
      );

      final gesture = await _longPress(tester, 'Long press me');
      expect(opened, isTrue);
      expect(closed, isFalse);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(closed, isTrue);
    });
  });

  group('LongPressPreview — actions', () {
    Widget _buildWithActions({required VoidCallback onActionTap}) {
      return MaterialApp(
        home: Scaffold(
          body: LongPressPreview(
            config: PreviewConfig(
              enableHaptics: false,
              actions: [
                PreviewAction(label: 'Open', onTap: onActionTap),
                PreviewAction(
                  label: 'Delete',
                  isDestructive: true,
                  onTap: () {},
                ),
              ],
            ),
            preview: const Text('Preview content'),
            child: const Text('Long press me'),
          ),
        ),
      );
    }

    testWidgets('keeps preview open after finger lifted when actions set',
        (tester) async {
      await tester.pumpWidget(_buildWithActions(onActionTap: () {}));

      final gesture = await _longPress(tester, 'Long press me');
      expect(find.text('Preview content'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
      // Preview should still be visible
      expect(find.text('Preview content'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('action onTap is called and preview closes', (tester) async {
      bool actionTapped = false;
      await tester.pumpWidget(
          _buildWithActions(onActionTap: () => actionTapped = true));

      final gesture = await _longPress(tester, 'Long press me');
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
      expect(find.text('Preview content'), findsNothing);
    });
  });

  group('LongPressImagePreview', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LongPressImagePreview(
              imageProvider: AssetImage('assets/placeholder.png'),
              child: Text('Image thumbnail'),
            ),
          ),
        ),
      );
      expect(find.text('Image thumbnail'), findsOneWidget);
    });
  });

  group('PreviewConfig', () {
    test('has correct defaults', () {
      const config = PreviewConfig();
      expect(config.borderRadius, 16.0);
      expect(config.enableHaptics, isTrue);
      expect(config.animation, PreviewAnimation.scaleFromChild);
      expect(config.alignment, Alignment.center);
      expect(config.longPressDuration, const Duration(milliseconds: 300));
      expect(config.actions, isEmpty);
    });
  });

  group('OgpData', () {
    test('holds all fields', () {
      const data = OgpData(
        url: 'https://example.com',
        title: 'Test Title',
        description: 'Test description',
        imageUrl: 'https://example.com/image.jpg',
        faviconUrl: 'https://example.com/favicon.ico',
        siteName: 'Example',
      );
      expect(data.url, 'https://example.com');
      expect(data.title, 'Test Title');
      expect(data.siteName, 'Example');
    });
  });
}
