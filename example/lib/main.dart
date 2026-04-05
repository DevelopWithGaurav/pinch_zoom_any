import 'package:flutter/material.dart';
import 'package:pinch_zoom_any/pinch_zoom_any.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pinch_zoom_any Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('pinch_zoom_any Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionTitle('Image — stay zoomed (default)'),
          SizedBox(height: 8),
          _ImageExample(),
          SizedBox(height: 32),
          _SectionTitle('Text Card — reset on release'),
          SizedBox(height: 8),
          _TextCardExample(),
          SizedBox(height: 32),
          _SectionTitle('Custom Widget — with scale indicator'),
          SizedBox(height: 8),
          _ScaleIndicatorExample(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
}

// ── Example 1: Image ─────────────────────────────────────────────────────────

class _ImageExample extends StatelessWidget {
  const _ImageExample();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: PinchZoomAny(
        maxScale: 5.0,
        doubleTapScale: 2.5,
        child: Image.network(
          'https://picsum.photos/seed/flutter/800/500',
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Example 2: Text card with resetOnRelease ──────────────────────────────────

class _TextCardExample extends StatelessWidget {
  const _TextCardExample();

  @override
  Widget build(BuildContext context) {
    return PinchZoomAny(
      resetOnRelease: true,
      doubleTapScale: 2.0,
      child: Card(
        color: Colors.indigo.shade50,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Zoom any widget', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'This card uses resetOnRelease: true. '
                'Pinch to zoom in, release your fingers, '
                'and it snaps right back to its original size. '
                'Double-tap also works to toggle zoom.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 12),
              Chip(label: Text('resetOnRelease: true')),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Example 3: Scale indicator ────────────────────────────────────────────────

class _ScaleIndicatorExample extends StatefulWidget {
  const _ScaleIndicatorExample();

  @override
  State<_ScaleIndicatorExample> createState() => _ScaleIndicatorExampleState();
}

class _ScaleIndicatorExampleState extends State<_ScaleIndicatorExample> {
  double _currentScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PinchZoomAny(
          maxScale: 4.0,
          doubleTapScale: 2.0,
          onScaleChanged: (scale) {
            setState(() => _currentScale = scale);
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.purple.shade300, Colors.blue.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text('Pinch or double-tap me!', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Chip(
            key: ValueKey(_currentScale.toStringAsFixed(1)),
            avatar: const Icon(Icons.zoom_in, size: 16),
            label: Text('Scale: ${_currentScale.toStringAsFixed(2)}x'),
          ),
        ),
      ],
    );
  }
}
