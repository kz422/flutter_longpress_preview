## 0.1.9

* Remove `screenshots` section from pubspec.yaml — animated GIFs are not supported by pana's WebP converter, causing score penalty. Screenshots remain in README via GitHub raw URLs.
* Update banner SVG: move popup card upward, rename "Image zoom" pill to "Image preview".

## 0.1.8

* Fix `LongPressImagePreview` using `BoxFit.cover` to eliminate black bars on non-square images.
* Revamp example app: richer article feed, styled saved-links list, and photo gallery with location overlays.
* Replace screenshots with new GIFs covering all three widget types.
* Add pub.dev link to README.

## 0.1.7

* Add `onPreviewTap` callback to `LongPressPreview` — called when the preview popup itself is tapped, enabling peek-and-pop style navigation.
* Update example app: tapping the preview or the "Open" action navigates to a full `ArticleDetailPage`.
* Update screenshot.

## 0.1.6

* Remove `cached_network_image` dependency to restore WASM compatibility and full platform support (Windows, Linux, Web).
* Add missing dartdoc comments to constructors and `OgpData.description`.
* Compress `on_image_widget.gif` screenshot to satisfy pub.dev 4 MB limit.

## 0.1.3

* Fix `MissingPluginException` on Flutter Web when using `LongPressLinkPreview` — OGP images now use `Image.network` on web instead of `CachedNetworkImage`.

## 0.1.2

* Update screenshot to show context menu actions in English.

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
