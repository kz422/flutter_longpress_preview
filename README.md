<p align="center">
  <img src="https://raw.githubusercontent.com/kz422/flutter_longpress_preview/main/screenshots/banner.svg" alt="flutter_longpress_preview" width="100%"/>
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_longpress_preview"><img src="https://img.shields.io/pub/v/flutter_longpress_preview.svg" alt="pub version"/></a>
  <a href="https://pub.dev/packages/flutter_longpress_preview/score"><img src="https://img.shields.io/pub/points/flutter_longpress_preview" alt="pub points"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="license: MIT"/></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%3E%3D3.10-blue.svg" alt="Flutter"/></a>
</p>

<p align="center">
  A Flutter package that shows a preview popup on long press —<br/>
  inspired by Safari's link preview and Instagram's peek feature.
</p>

---

<table>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/kz422/flutter_longpress_preview/main/screenshots/preview_with_context_menu.gif" width="220"/><br/><sub>Widget preview + context menu</sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/kz422/flutter_longpress_preview/main/screenshots/links_preview.gif" width="220"/><br/><sub>OGP link preview</sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/kz422/flutter_longpress_preview/main/screenshots/images_preview.gif" width="220"/><br/><sub>Image preview</sub></td>
  </tr>
</table>

---

## Features

- **Universal widget preview** — wrap any widget with `LongPressPreview` to peek at any content before committing to a tap.
- **Automatic OGP link previews** — `LongPressLinkPreview` fetches Open Graph metadata (title, description, image, favicon) from any URL and renders a rich card.
- **Zoomable image previews** — `LongPressImagePreview` shows an enlarged, pinch-to-zoom view of any `ImageProvider`.
- **Three animation styles** — `scaleFromChild` (Safari-style), `slideFromBottom` (Instagram-style), `fadeIn`.
- **Blur backdrop** — frosted glass background behind the popup.
- **Drag-to-dismiss** — swipe the popup down to close it.
- **Haptic feedback** — medium impact on long press (configurable).
- **In-memory OGP cache** — repeated previews for the same URL are instant.
- **Context menu actions** — attach labelled actions (with optional icons and destructive styling) that appear below the popup; the popup stays open until the user taps an action or the backdrop.
- **Flexible positioning** — pin the popup anywhere via `Alignment`, or leave it at the default centre position.
- **Fully customisable** — colours, sizes, border radius, animation duration, loading/error widgets, and custom preview builders.
- **Dart 3 / Flutter 3.10+** — null-safe, uses records, switch expressions.

---

## Installation

**[View on pub.dev →](https://pub.dev/packages/flutter_longpress_preview)**

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_longpress_preview: ^latest_version
```

Then run:

```sh
flutter pub get
```

---

## Quick start

```dart
import 'package:flutter_longpress_preview/flutter_longpress_preview.dart';

// Wrap any widget — long press to peek, tap to navigate.
LongPressPreview(
  preview: ArticleDetailWidget(),
  onPreviewTap: () => Navigator.push(context, ...),
  config: PreviewConfig(
    animation: PreviewAnimation.scaleFromChild,
    actions: [
      PreviewAction(label: 'Open',     icon: Icons.open_in_new, onTap: () { ... }),
      PreviewAction(label: 'Bookmark', icon: Icons.bookmark_outline, onTap: () { ... }),
      PreviewAction(label: 'Delete',   icon: Icons.delete_outline, isDestructive: true, onTap: () { ... }),
    ],
  ),
  child: ArticleCard(),
)
```

---

## Usage

### 1. LongPressPreview — any widget

Wrap any widget to preview arbitrary content on long press.

```dart
LongPressPreview(
  preview: MyDetailWidget(),   // shown in the popup
  child: MyThumbnailWidget(),  // the widget that receives the long press
  onTap: () => Navigator.push(context, ...),
  onPreviewOpen: () => debugPrint('opened'),
  onPreviewClose: () => debugPrint('closed'),
)
```

#### With custom config

```dart
LongPressPreview(
  preview: MyDetailWidget(),
  config: const PreviewConfig(
    animation: PreviewAnimation.slideFromBottom,
    previewHeight: 400,
    borderRadius: 24,
    backgroundColor: Color(0xFF1C1C1E),
    barrierColor: Color(0xAA000000),
    animationDuration: Duration(milliseconds: 300),
    enableHaptics: true,
  ),
  child: MyThumbnailWidget(),
)
```

---

### 2. LongPressLinkPreview — automatic OGP card

Fetches Open Graph metadata from the URL and shows a rich card with the OGP image, title, description, site name, and favicon.

```dart
LongPressLinkPreview(
  url: 'https://flutter.dev',
  child: Text(
    'Flutter',
    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
  ),
  onTap: () => launchUrl(Uri.parse('https://flutter.dev')),
)
```

#### With a custom preview builder

```dart
LongPressLinkPreview(
  url: 'https://dart.dev',
  previewBuilder: (context, ogpData) {
    return MyCustomCard(data: ogpData);
  },
  child: const Text('Dart'),
)
```

#### Web / CORS proxy support

```dart
LongPressLinkPreview(
  url: 'https://example.com/article',
  proxyUrl: 'https://my-cors-proxy.example.com/?url=',
  child: const Text('Article'),
)
```

---

### 3. LongPressImagePreview — zoomable image

Long-pressing shows the full image with optional pinch-to-zoom. Pass a `heroTag` that matches the destination screen to get a seamless Hero transition when navigating.

```dart
LongPressImagePreview(
  imageProvider: NetworkImage('https://example.com/photo.jpg'),
  enableZoom: true,
  heroTag: 'photo_42',
  config: const PreviewConfig(
    backgroundColor: Colors.black,
  ),
  onTap: () => Navigator.push(context, PhotoDetailRoute()),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      'https://example.com/photo.jpg',
      fit: BoxFit.cover,
    ),
  ),
)
```

Works with any `ImageProvider`: `NetworkImage`, `AssetImage`, `FileImage`, etc.

```dart
LongPressImagePreview(
  imageProvider: const AssetImage('assets/photo.jpg'),
  child: const SizedBox(width: 80, height: 80, child: FlutterLogo()),
)
```

---

## PreviewConfig reference

| Property | Type | Default | Description |
|---|---|---|---|
| `previewHeight` | `double?` | 60% of screen height | Maximum height of the popup |
| `previewWidth` | `double?` | 90% of screen width | Width of the popup |
| `borderRadius` | `double` | `16.0` | Corner radius of the popup |
| `backgroundColor` | `Color` | `Colors.white` | Background colour of the popup |
| `barrierColor` | `Color` | `0x88000000` | Colour of the dimmed backdrop |
| `animationDuration` | `Duration` | `220ms` | Open/close animation duration |
| `animation` | `PreviewAnimation` | `scaleFromChild` | Animation style |
| `alignment` | `Alignment` | `Alignment.center` | Where to position the popup on screen |
| `actions` | `List<PreviewAction>` | `[]` | Context menu actions shown below the popup |
| `enableHaptics` | `bool` | `true` | Haptic feedback on long press |
| `longPressDuration` | `Duration` | `300ms` | How long to hold before preview opens |

### PreviewAction properties

| Property | Type | Default | Description |
|---|---|---|---|
| `label` | `String` | required | Button text |
| `onTap` | `VoidCallback` | required | Called when the action is tapped |
| `icon` | `IconData?` | `null` | Optional leading icon |
| `isDestructive` | `bool` | `false` | Renders the label in red |

### PreviewAnimation values

| Value | Description |
|---|---|
| `PreviewAnimation.scaleFromChild` | Scales up from the child's position (Safari-style) |
| `PreviewAnimation.slideFromBottom` | Slides up from the bottom of the screen (Instagram-style) |
| `PreviewAnimation.fadeIn` | Simple opacity fade |

---

## LongPressLinkPreview reference

| Property | Type | Default | Description |
|---|---|---|---|
| `url` | `String` | required | URL to fetch OGP data from |
| `child` | `Widget` | required | Trigger widget |
| `config` | `PreviewConfig` | `PreviewConfig()` | Appearance config |
| `proxyUrl` | `String?` | `null` | CORS proxy prefix for web |
| `showFavicon` | `bool` | `true` | Show site favicon in card |
| `showDescription` | `bool` | `true` | Show OGP description |
| `maxDescriptionLines` | `int` | `3` | Max lines for description |
| `loadingWidget` | `Widget?` | `CircularProgressIndicator` | Custom loading state |
| `errorWidget` | `Widget?` | Text message | Custom error state |
| `previewBuilder` | `Widget Function(BuildContext, OgpData)?` | `null` | Fully custom preview widget |
| `onPreviewOpen` | `VoidCallback?` | `null` | Called when popup opens |
| `onPreviewClose` | `VoidCallback?` | `null` | Called when popup closes |
| `onTap` | `VoidCallback?` | `null` | Called on normal tap |

---

## LongPressImagePreview reference

| Property | Type | Default | Description |
|---|---|---|---|
| `imageProvider` | `ImageProvider` | required | Image to show in preview |
| `child` | `Widget` | required | Trigger widget (thumbnail) |
| `config` | `PreviewConfig` | `PreviewConfig()` | Appearance config |
| `enableZoom` | `bool` | `true` | Pinch-to-zoom in preview |
| `heroTag` | `Object?` | `null` | Hero animation tag |
| `onTap` | `VoidCallback?` | `null` | Called on normal tap |

---

## Platform support

| Platform | Supported |
|---|---|
| Android | Yes |
| iOS | Yes |
| macOS | Yes |
| Web | Yes (use `proxyUrl` for OGP fetching due to CORS) |
| Windows | Yes |
| Linux | Yes |

> **Note:** Haptic feedback (`enableHaptics`) is a no-op on platforms that do not support it (web, desktop). No error is thrown.

---

## How OGP fetching works

`OgpFetcher.fetch(url)` makes a single HTTP GET request with a bot `User-Agent`, parses the HTML for `og:*` / `twitter:*` meta tags, and falls back to the `<title>` tag and `<meta name="description">`. Results are cached in a static `Map` for the lifetime of the app. Call `OgpFetcher.clearCache()` to flush the cache.

On Flutter Web, same-origin policy prevents direct fetching of arbitrary URLs. Pass a `proxyUrl` (e.g. a simple server-side proxy or a CORS-anywhere instance) to route requests through it.

---

## Example app

A full example app is included in the `example/` directory demonstrating all three widget types across three tabs.

```sh
cd example
flutter run
```

---

## Contributing

Pull requests are welcome. Please open an issue first to discuss significant changes.

1. Fork the repository.
2. Create a feature branch: `git checkout -b feat/my-feature`.
3. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/).
4. Open a pull request.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
