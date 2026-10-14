import 'package:flutter/material.dart';

import '../../models/anime.dart';
import 'poster_image.dart';

class AnimeHeroCard extends StatelessWidget {
  const AnimeHeroCard({
    super.key,
    required this.anime,
    required this.statusLabel,
    required this.updatedLabel,
    required this.onTap,
  });

  final Anime anime;
  final String statusLabel;
  final String updatedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mutedStyle = textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final scoreText = anime.score?.toStringAsFixed(1) ?? '-';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outlineVariant),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.secondaryContainer, scheme.primaryContainer],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text('Peringkat #${anime.rank ?? '-'}', style: mutedStyle),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      'Diperbarui $updatedLabel',
                      textAlign: TextAlign.end,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scoreText,
                          style: textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Skor Kitsu', style: mutedStyle),
                        const SizedBox(height: 16),
                        Text(
                          anime.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(statusLabel, style: mutedStyle),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  PosterImage(
                    url: anime.imageUrl,
                    width: 110,
                    height: 156,
                    borderRadius: 16,
                    semanticLabel: 'Poster ${anime.title}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
