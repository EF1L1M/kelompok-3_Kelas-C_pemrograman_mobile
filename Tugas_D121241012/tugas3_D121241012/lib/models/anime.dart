/// Data anime dari Kitsu API (endpoint /api/edge/anime).
/// Class ini immutable: semua field final dan constructor const.
class Anime {
  const Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.status,
    this.score,
    this.rank,
    this.episodes,
    this.userCount,
    this.type,
    this.year,
    this.synopsis,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String status;

  /// Skor komunitas dalam skala 0 sampai 10.
  final double? score;

  /// Peringkat popularitas di Kitsu (1 = paling populer).
  final int? rank;
  final int? episodes;
  final int? userCount;
  final String? type;
  final int? year;
  final String? synopsis;

  /// [json] adalah satu objek dari array `data` pada respons Kitsu
  /// (berisi `id` dan `attributes`).
  factory Anime.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final poster = attributes['posterImage'] as Map<String, dynamic>?;
    final startDate = attributes['startDate'] as String?;

    // Kitsu mengirim averageRating sebagai string persen, contoh "82.15".
    final rawRating = attributes['averageRating'];
    final ratingPercent =
        rawRating == null ? null : double.tryParse(rawRating.toString());

    return Anime(
      id: json['id'].toString(),
      title: attributes['canonicalTitle'] as String? ?? 'Tanpa judul',
      imageUrl: poster?['large'] as String? ??
          poster?['medium'] as String? ??
          poster?['original'] as String? ??
          '',
      status: attributes['status'] as String? ?? 'unknown',
      score: ratingPercent == null ? null : ratingPercent / 10,
      rank: attributes['popularityRank'] as int?,
      episodes: attributes['episodeCount'] as int?,
      userCount: attributes['userCount'] as int?,
      type: attributes['subtype'] as String?,
      year: (startDate != null && startDate.length >= 4)
          ? int.tryParse(startDate.substring(0, 4))
          : null,
      synopsis: attributes['synopsis'] as String?,
    );
  }
}
