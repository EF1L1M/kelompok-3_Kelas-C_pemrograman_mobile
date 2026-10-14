import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/anime.dart';

/// Error dengan pesan yang sudah siap ditampilkan ke pengguna.
/// [retryable] menandai error sementara yang layak dicoba ulang otomatis.
class KitsuException implements Exception {
  const KitsuException(this.message, {this.retryable = false});

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}

/// Satu-satunya file yang memanggil package http.
class KitsuService {
  KitsuService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _host = 'kitsu.io';
  static const Duration _timeout = Duration(seconds: 25);
  static const int _maxAttempts = 2;

  /// Mengambil anime terpopuler. Error sementara (timeout, koneksi, 429, 5xx)
  /// dicoba ulang otomatis sebelum error dilempar ke UI.
  Future<List<Anime>> fetchTopAnime({int limit = 10}) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        return await _fetchOnce(limit);
      } on KitsuException catch (e) {
        final isLastAttempt = attempt == _maxAttempts;
        if (!e.retryable || isLastAttempt) rethrow;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
    throw const KitsuException('Gagal memuat data. Coba lagi nanti.');
  }

  Future<List<Anime>> _fetchOnce(int limit) async {
    final uri = Uri.https(_host, '/api/edge/anime', {
      'sort': 'popularityRank',
      'page[limit]': '$limit',
      'filter[ageRating]': 'G,PG,R',
    });

    try {
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/vnd.api+json'},
      ).timeout(_timeout);

      if (response.statusCode == 429) {
        throw const KitsuException(
          'Terlalu banyak permintaan ke Kitsu API. '
          'Tunggu beberapa detik, lalu coba lagi.',
          retryable: true,
        );
      }
      if (response.statusCode >= 500) {
        throw KitsuException(
          'Server Kitsu sedang bermasalah (kode ${response.statusCode}). '
          'Coba lagi beberapa saat lagi.',
          retryable: true,
        );
      }
      if (response.statusCode != 200) {
        throw KitsuException(
          'Permintaan ditolak server (kode ${response.statusCode}).',
        );
      }

      // Kitsu memakai content-type application/vnd.api+json tanpa charset,
      // jadi body didecode manual sebagai UTF-8 agar karakter khusus aman.
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      return data
          .map((item) => Anime.fromJson(item as Map<String, dynamic>))
          .toList();
    } on KitsuException {
      rethrow;
    } on TimeoutException {
      throw const KitsuException(
        'Server Kitsu terlalu lama merespons. Server sedang lambat atau '
        'koneksi internet kamu bermasalah. Coba lagi sebentar lagi.',
        retryable: true,
      );
    } on FormatException {
      throw const KitsuException(
        'Data dari server tidak bisa dibaca. Coba lagi nanti.',
      );
    } on Exception {
      throw const KitsuException(
        'Tidak bisa terhubung ke server. '
        'Periksa koneksi internet kamu, lalu coba lagi.',
        retryable: true,
      );
    } catch (_) {
      throw const KitsuException(
        'Format data dari server tidak sesuai. Coba lagi nanti.',
      );
    }
  }
}
