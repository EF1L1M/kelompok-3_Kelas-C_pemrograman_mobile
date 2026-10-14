import 'package:flutter/material.dart';

import '../../models/anime.dart';
import 'poster_image.dart';

class AnimeListTile extends StatelessWidget {
  const AnimeListTile({super.key, required this.anime, this.onTap});

  final Anime anime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitle =
        '${anime.type ?? 'Anime'}, ${anime.episodes ?? '?'} episode';

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${anime.rank ?? '-'}',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PosterImage(
                url: anime.imageUrl,
                width: 52,
                height: 72,
                borderRadius: 10,
                semanticLabel: 'Poster ${anime.title}',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.star_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 4),
              Text(
                anime.score?.toStringAsFixed(1) ?? '-',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
