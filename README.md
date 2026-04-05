# pinch_zoom_any

[![pub.dev](https://img.shields.io/pub/v/pinch_zoom_any.svg)](https://pub.dev/packages/pinch_zoom_any)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Add **pinch-to-zoom**, **pan**, **double-tap to zoom**, and **double-tap to reset** to *any* Flutter widget — with zero external dependencies.

---

## Features

- 🤏 **Pinch to zoom** — smooth, natural gesture using Flutter's scale gesture
- ✋ **Pan / drag while zoomed** — move freely around the zoomed content
- 👆 **Double-tap to zoom** — toggles between 1× and `doubleTapScale`
- 🔄 **Double-tap to reset** — if already zoomed, double-tap returns to 1×
- ⚡ **`resetOnRelease`** — snap back to original size when fingers lift
- 📡 **`onScaleChanged` callback** — react to scale changes in real time
- 🎨 **Works on any widget** — images, cards, text, custom widgets, anything

---

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  pinch_zoom_any: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## Usage

### Basic — wrap any widget

```dart
import 'package:pinch_zoom_any/pinch_zoom_any.dart';

PinchZoomAny(
  child: Image.network('https://example.com/photo.jpg'),
)
```

### With custom zoom limits

```dart
PinchZoomAny(
  minScale: 1.0,
  maxScale: 5.0,
  doubleTapScale: 2.5,
  child: Image.asset('assets/map.png'),
)
```

### Reset on release (e.g. for previews)

```dart
PinchZoomAny(
  resetOnRelease: true,
  child: Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('Pinch me — I snap back!'),
    ),
  ),
)
```

### React to scale changes

```dart
PinchZoomAny(
  onScaleChanged: (scale) {
    print('Current scale: $scale');
  },
  child: MyCustomWidget(),
)
```

---

## API Reference

### `PinchZoomAny`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | The widget to make zoomable |
| `minScale` | `double` | `1.0` | Minimum zoom level |
| `maxScale` | `double` | `4.0` | Maximum zoom level |
| `doubleTapScale` | `double` | `2.0` | Zoom level reached on double-tap |
| `resetOnRelease` | `bool` | `false` | Snap back to 1× when fingers lift |
| `clipBehavior` | `Clip` | `Clip.hardEdge` | Clipping applied to zoomed content |
| `onScaleChanged` | `ValueChanged<double>?` | `null` | Callback fired on every scale change |

---

## How it works

`PinchZoomAny` uses Flutter's built-in `GestureDetector` with `onScaleStart`, `onScaleUpdate`, and `onScaleEnd` to track the pinch gesture. A `Matrix4` transform is applied via `Transform` to scale and translate the child. An `AnimationController` handles smooth snap-back and double-tap transitions.

No external packages are used — this is pure Flutter.

---

## License

MIT — see [LICENSE](LICENSE).
