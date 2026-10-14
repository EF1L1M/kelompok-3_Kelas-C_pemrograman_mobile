import 'package:flutter/material.dart';

import '../../models/anime.dart';
import '../../services/kitsu_service.dart';
import '../formatters.dart';
import '../widgets/anime_hero_card.dart';
import '../widgets/anime_list_tile.dart';
import '../widgets/error_view.dart';
import '../widgets/info_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/stat_card.dart';
import 'anime_detail_screen.dart';

enum _ViewStatus { loading, success, error }

/// Halaman pengatur state: loading, sukses, dan error.
class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key, required this.service});

  final KitsuService service;

  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  _ViewStatus _status = _ViewStatus.loading;
  List<Anime> _animeList = const [];
  String _errorMessage = '';
  DateTime? _updatedAt;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      if (_animeList.isEmpty) _status = _ViewStatus.loading;
    });

    try {
      final result = await widget.service.fetchTopAnime();
      if (!mounted) return;

      if (result.isEmpty) {
        _showLoadError('Kitsu API tidak mengembalikan data anime.');
        return;
      }

      setState(() {
        _animeList = result;
        _updatedAt = DateTime.now();
        _status = _ViewStatus.success;
      });
    } on KitsuException catch (e) {
      if (!mounted) return;
      _showLoadError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoadError(String message) {
    if (_animeList.isEmpty) {
      setState(() {
        _errorMessage = message;
        _status = _ViewStatus.error;
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data lama tetap ditampilkan. $message')),
    );
  }

  List<Anime> get _visibleAnime {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _animeList;
    return _animeList
        .where((anime) => anime.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Anime Terpopuler',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Perbarui data',
                    onPressed: _isLoading ? null : _load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Cari anime',
                  hintText: 'Masukkan judul anime',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_isLoading && _animeList.isNotEmpty)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _ViewStatus.loading:
        return const LoadingView();
      case _ViewStatus.error:
        return ErrorView(message: _errorMessage, onRetry: _load);
      case _ViewStatus.success:
        return RefreshIndicator(onRefresh: _load, child: _buildContent());
    }
  }

  Widget _buildContent() {
    final filtered = _visibleAnime;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.search_off, size: 48, color: scheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Anime tidak ditemukan',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Coba kata kunci lain.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (_searchController.text.trim().isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(
            '${filtered.length} hasil pencarian',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          for (final anime in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimeListTile(
                anime: anime,
                onTap: () => _openDetails(anime),
              ),
            ),
        ],
      );
    }

    final top = filtered.first;
    final others = filtered.skip(1);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      children: [
        AnimeHeroCard(
          anime: top,
          statusLabel: formatAnimeStatus(top.status),
          updatedLabel: _formatTime(_updatedAt ?? DateTime.now()),
          onTap: () => _openDetails(top),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.movie_outlined,
                label: 'Episode',
                value: top.episodes?.toString() ?? '?',
                unit: 'eps',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.groups_outlined,
                label: 'Pengguna',
                value: formatAnimeUserCount(top.userCount),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InfoCard(
          icon: Icons.info_outline,
          message: top.synopsis ?? 'Sinopsis belum tersedia untuk anime ini.',
        ),
        const SizedBox(height: 24),
        Text(
          'Peringkat berikutnya',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final anime in others)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimeListTile(
              anime: anime,
              onTap: () => _openDetails(anime),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'Data bersumber dari Kitsu API.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  void _openDetails(Anime anime) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AnimeDetailScreen(anime: anime)),
    );
  }
}

String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
