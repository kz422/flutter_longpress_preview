## 0.1.1

* Fix screenshot images not displaying on pub.dev (use absolute GitHub raw URLs).

## 0.1.0

* Initial release.
* `LongPressPreview` — shows any widget as a popup on long press.
* `LongPressLinkPreview` — auto-fetches OGP metadata and shows a rich link card.
* `LongPressImagePreview` — shows an enlarged, zoomable image on long press.
* Three animation styles: `scaleFromChild`, `slideFromBottom`, `fadeIn`.
* `PreviewConfig.alignment` — positions the popup anywhere on screen via `Alignment`; defaults to `Alignment.center`.
* `PreviewConfig.actions` — optional context menu shown below the preview; popup stays open until the user taps an action or the barrier.
* `PreviewAction` — label, optional icon, `isDestructive` flag, and `onTap` callback.
* Reduced default long-press trigger delay to 300 ms.
* Drag-down-to-dismiss gesture.
* Haptic feedback support.
* Full Dart 3 / Flutter 3.10+ compatibility.
