import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'ogp_data.dart';

/// Fetches and parses OGP (Open Graph Protocol) metadata from a URL.
class OgpFetcher {
  static final Map<String, OgpData> _cache = {};

  /// Fetches OGP data for the given [url].
  /// Results are cached in memory.
  static Future<OgpData> fetch(String url, {String? proxyUrl}) async {
    if (_cache.containsKey(url)) return _cache[url]!;

    try {
      final targetUrl = proxyUrl != null ? '$proxyUrl$url' : url;
      final response = await http.get(
        Uri.parse(targetUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (compatible; LongpressPreviewBot/1.0)',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return OgpData(url: url);
      }

      final document = html_parser.parse(response.body);
      final data = _parse(url, document);
      _cache[url] = data;
      return data;
    } catch (e) {
      debugPrint('[flutter_longpress_preview] OGP fetch error: $e');
      return OgpData(url: url);
    }
  }

  static OgpData _parse(String url, dom.Document document) {
    String? getMeta(String property) {
      return document
              .querySelector('meta[property="$property"]')
              ?.attributes['content'] ??
          document
              .querySelector('meta[name="$property"]')
              ?.attributes['content'];
    }

    final title = getMeta('og:title') ??
        getMeta('twitter:title') ??
        document.querySelector('title')?.text;

    final description = getMeta('og:description') ??
        getMeta('twitter:description') ??
        getMeta('description');

    final imageUrl = getMeta('og:image') ?? getMeta('twitter:image');

    final siteName = getMeta('og:site_name');

    // Try to resolve favicon
    String? faviconUrl;
    final faviconEl = document.querySelector('link[rel~="icon"]');
    if (faviconEl != null) {
      final href = faviconEl.attributes['href'];
      if (href != null) {
        final base = Uri.parse(url);
        faviconUrl = Uri.parse(href).isAbsolute
            ? href
            : '${base.scheme}://${base.host}$href';
      }
    }
    faviconUrl ??= '${Uri.parse(url).scheme}://${Uri.parse(url).host}/favicon.ico';

    return OgpData(
      url: url,
      title: title?.trim(),
      description: description?.trim(),
      imageUrl: imageUrl,
      faviconUrl: faviconUrl,
      siteName: siteName?.trim(),
    );
  }

  /// Clears the in-memory OGP cache.
  static void clearCache() => _cache.clear();
}
