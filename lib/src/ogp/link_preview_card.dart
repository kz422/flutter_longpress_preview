import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'ogp_data.dart';

/// Default card widget shown inside [LongPressLinkPreview].
class LinkPreviewCard extends StatelessWidget {
  final OgpData data;
  final bool showFavicon;
  final bool showDescription;
  final int maxDescriptionLines;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? siteNameStyle;

  const LinkPreviewCard({
    super.key,
    required this.data,
    this.showFavicon = true,
    this.showDescription = true,
    this.maxDescriptionLines = 3,
    this.titleStyle,
    this.descriptionStyle,
    this.siteNameStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // OGP Image
        if (data.imageUrl != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: kIsWeb
                  ? Image.network(data.imageUrl!, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: data.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined, size: 40),
                      ),
                    ),
            ),
          ),

        // Text content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Site name + favicon
              if (showFavicon || data.siteName != null)
                Row(
                  children: [
                    if (showFavicon && data.faviconUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: kIsWeb
                            ? Image.network(data.faviconUrl!,
                                width: 16, height: 16)
                            : CachedNetworkImage(
                                imageUrl: data.faviconUrl!,
                                width: 16,
                                height: 16,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.language, size: 16),
                              ),
                      ),
                    if (data.siteName != null)
                      Expanded(
                        child: Text(
                          data.siteName!,
                          style: siteNameStyle ??
                              theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),

              if (data.siteName != null) const SizedBox(height: 6),

              // Title
              if (data.title != null)
                Text(
                  data.title!,
                  style: titleStyle ??
                      theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              // Description
              if (showDescription && data.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  data.description!,
                  style: descriptionStyle ?? theme.textTheme.bodySmall,
                  maxLines: maxDescriptionLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // URL
              const SizedBox(height: 8),
              Text(
                Uri.parse(data.url).host,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
