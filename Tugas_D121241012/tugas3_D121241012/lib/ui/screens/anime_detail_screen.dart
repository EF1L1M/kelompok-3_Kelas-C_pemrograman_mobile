import 'package:flutter/material.dart';

import '../../models/anime.dart';
import '../formatters.dart';
import '../widgets/poster_image.dart';
import '../widgets/stat_card.dart';

class AnimeDetailScreen extends StatelessWidget {
  const AnimeDetailScreen({super.key, required this.anime});

  final Anime anime;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Anime')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Center(
            child: PosterImage(
              url: anime.imageUrl,
              width: 160,
              height: 226,
              borderRadius: 20,
              semanticLabel: 'Poster ${anime.title}',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            anime.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _DetailChip(label: formatAnimeStatus(anime.status)),
              if (anime.type != null) _DetailChip(label: anime.type!),
              if (anime.year != null) _DetailChip(label: '${anime.year}'),
              if (anime.rank != null)
                _DetailChip(label: 'Peringkat #${anime.rank}'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.star_outline_rounded,
                  label: 'Skor Kitsu',
                  value: anime.score?.toStringAsFixed(1) ?? '-',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.movie_outlined,
                  label: 'Episode',
                  value: anime.episodes?.toString() ?? '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatCard(
            icon: Icons.groups_outlined,
            label: 'Pengguna',
            value: formatAnimeUserCount(anime.userCount),
          ),
          const SizedBox(height: 24),
          Text(
            'Sinopsis',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            anime.synopsis?.trim().isNotEmpty == true
                ? anime.synopsis!
                : 'Sinopsis belum tersedia untuk anime ini.',
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
