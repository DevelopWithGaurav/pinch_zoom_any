# pinch_zoom_any — Example App

A Flutter example app demonstrating all features of the [`pinch_zoom_any`](https://pub.dev/packages/pinch_zoom_any) package.

---

## Screens

### 1. Image — Stay Zoomed (default)
Wraps a network image with `PinchZoomAny` using default settings.

- Pinch to zoom up to 5×
- Pan/drag while zoomed
- Double-tap to jump to 2.5×
- Double-tap again to reset to 1×
- Stays at the zoomed position when you release

### 2. Text Card — Reset on Release
Demonstrates `resetOnRelease: true` on a `Card` widget.

- Pinch to zoom — snaps back to 1× the moment you release your fingers
- Double-tap also works to toggle zoom temporarily

### 3. Custom Widget — Scale Indicator
Demonstrates the `onScaleChanged` callback on a custom gradient container.

- Live scale readout displayed below the widget via an animated `Chip`
- Shows how to react to zoom changes in your own UI

---

## Running the app

```bash
cd example
flutter pub get
flutter run
```

---

## Project structure

```
example/
├── lib/
│   └── main.dart        # All three demo screens
└── pubspec.yaml         # Depends on pinch_zoom_any via path
```

---

## Notes

- The example uses `Image.network` — make sure the device/emulator has internet access.
- All demos are stacked in a single scrollable `ListView` on one screen for easy comparison.