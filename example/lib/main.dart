import 'package:flutter/material.dart';
import 'package:flutter_longpress_preview/flutter_longpress_preview.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_longpress_preview example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_longpress_preview'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Widget'),
              Tab(text: 'Link'),
              Tab(text: 'Image'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _WidgetTab(),
            _LinkTab(),
            _ImageTab(),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: Generic widget preview ────────────────────────────────────────────

class _WidgetTab extends StatelessWidget {
  const _WidgetTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Long press a card to preview it.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        for (int i = 1; i <= 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LongPressPreview(
              preview: _ArticleDetail(index: i),
              config: PreviewConfig(
                animation: PreviewAnimation.scaleFromChild,
                actions: [
                  PreviewAction(
                    label: '開く',
                    icon: Icons.open_in_new,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opened article $i')),
                    ),
                  ),
                  PreviewAction(
                    label: 'コピー',
                    icon: Icons.copy,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied article $i')),
                    ),
                  ),
                  PreviewAction(
                    label: '削除',
                    icon: Icons.delete_outline,
                    isDestructive: true,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted article $i')),
                    ),
                  ),
                ],
              ),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped article $i')),
              ),
              child: _ArticleCard(index: i),
            ),
          ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final int index;
  const _ArticleCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('$index')),
        title: Text('Article $index'),
        subtitle: const Text('Long press to preview • Tap to open'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ArticleDetail extends StatelessWidget {
  final int index;
  const _ArticleDetail({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.indigo.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Icon(Icons.article,
                  size: 64, color: Colors.indigo.withValues(alpha: 0.5)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Article $index Preview',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is a preview of the article content. '
            'The full article contains much more detail. '
            'Long press to peek, release to dismiss.',
          ),
        ],
      ),
    );
  }
}

// ── Tab 2: Link (OGP) preview ─────────────────────────────────────────────────

class _LinkTab extends StatelessWidget {
  const _LinkTab();

  static const _links = [
    (label: 'Flutter official site', url: 'https://flutter.dev'),
    (label: 'Dart language', url: 'https://dart.dev'),
    (
      label: 'pub.dev package registry',
      url: 'https://pub.dev'
    ),
    (label: 'GitHub', url: 'https://github.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Long press a link to see its OGP preview.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        for (final link in _links)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LongPressLinkPreview(
              url: link.url,
              config: const PreviewConfig(
                animation: PreviewAnimation.slideFromBottom,
              ),
              onTap: () async {
                final uri = Uri.parse(link.url);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.link, color: Colors.indigo),
                  title: Text(link.label),
                  subtitle: Text(
                    link.url,
                    style: const TextStyle(
                      color: Colors.indigo,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Tab 3: Image preview ──────────────────────────────────────────────────────

class _ImageTab extends StatelessWidget {
  const _ImageTab();

  static const _images = [
    'https://picsum.photos/seed/flutter1/800/600',
    'https://picsum.photos/seed/flutter2/800/600',
    'https://picsum.photos/seed/flutter3/800/600',
    'https://picsum.photos/seed/flutter4/800/600',
    'https://picsum.photos/seed/flutter5/800/600',
    'https://picsum.photos/seed/flutter6/800/600',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _images.length,
      itemBuilder: (context, i) {
        return LongPressImagePreview(
          imageProvider: NetworkImage(_images[i]),
          enableZoom: true,
          heroTag: 'photo_$i',
          config: const PreviewConfig(
            animation: PreviewAnimation.scaleFromChild,
            backgroundColor: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _images[i],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
