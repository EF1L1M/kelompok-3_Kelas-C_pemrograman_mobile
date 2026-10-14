import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitsu_app/models/anime.dart';
import 'package:kitsu_app/services/kitsu_service.dart';
import 'package:kitsu_app/ui/screens/anime_detail_screen.dart';
import 'package:kitsu_app/ui/screens/anime_screen.dart';
import 'package:kitsu_app/ui/widgets/anime_hero_card.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('Anime.fromJson membaca field dari respons Kitsu', () {
    final json = <String, dynamic>{
      'id': '1',
      'type': 'anime',
      'attributes': {
        'canonicalTitle': 'Cowboy Bebop',
        'synopsis':
            'Di tahun 2071, para pemburu hadiah berkelana di antariksa.',
        'averageRating': '82.15',
        'userCount': 120000,
        'popularityRank': 7,
        'subtype': 'TV',
        'status': 'finished',
        'episodeCount': 26,
        'startDate': '1998-04-03',
        'posterImage': {'large': 'https://example.com/poster.jpg'},
      },
    };

    final anime = Anime.fromJson(json);

    expect(anime.id, '1');
    expect(anime.title, 'Cowboy Bebop');
    expect(anime.imageUrl, 'https://example.com/poster.jpg');
    expect(anime.score, closeTo(8.215, 0.0001));
    expect(anime.rank, 7);
    expect(anime.episodes, 26);
    expect(anime.year, 1998);
    expect(anime.status, 'finished');
  });

  test('Anime.fromJson aman saat data opsional kosong', () {
    final anime = Anime.fromJson(<String, dynamic>{
      'id': '2',
      'attributes': {'canonicalTitle': 'Judul Saja'},
    });

    expect(anime.score, isNull);
    expect(anime.rank, isNull);
    expect(anime.imageUrl, '');
    expect(anime.synopsis, isNull);
  });

  testWidgets('pencarian memfilter anime dan menampilkan hasil kosong', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appWithService(
        _FakeKitsuService([
          _anime('1', 'Cowboy Bebop'),
          _anime('2', 'Samurai Champloo'),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'samurai');
    await tester.pump();
    expect(find.text('1 hasil pencarian'), findsOneWidget);
    expect(find.text('Samurai Champloo'), findsOneWidget);
    expect(find.text('Cowboy Bebop'), findsNothing);

    await tester.enterText(find.byType(TextField), 'tidak ada');
    await tester.pumpAndSettle();
    expect(find.text('Anime tidak ditemukan'), findsOneWidget);
  });

  testWidgets('kartu anime membuka halaman detail', (tester) async {
    await tester.pumpWidget(
      _appWithService(_FakeKitsuService([_anime('1', 'Cowboy Bebop')])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AnimeHeroCard));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.byType(AnimeDetailScreen), findsOneWidget);
    expect(find.text('Sinopsis lengkap Cowboy Bebop'), findsOneWidget);
    expect(find.text('Skor Kitsu'), findsOneWidget);
  });

  testWidgets('refresh gagal tetapi tetap mempertahankan data lama', (
    tester,
  ) async {
    final service = _FakeKitsuService([_anime('1', 'Cowboy Bebop')]);

    await tester.pumpWidget(_appWithService(service));
    await tester.pumpAndSettle();

    final refresh = Completer<List<Anime>>();
    service.nextRequest = refresh;
    await tester.tap(find.byTooltip('Perbarui data'));
    await tester.pump();
    expect(find.text('Cowboy Bebop'), findsOneWidget);

    refresh.completeError(const KitsuException('Jaringan terputus.'));
    await tester.pumpAndSettle();

    expect(find.text('Cowboy Bebop'), findsOneWidget);
    expect(find.textContaining('Data lama tetap ditampilkan.'), findsOneWidget);
  });
}

Widget _appWithService(KitsuService service) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5B8DEF),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF2B4A78),
        secondaryContainer: Color(0xFF16233B),
        surface: Color(0xFF0B1220),
        surfaceContainer: Color(0xFF141C2F),
        surfaceContainerHighest: Color(0xFF1E2942),
        onSurfaceVariant: Color(0xFFA9B4CC),
        outlineVariant: Color(0xFF232E47),
      ),
    ),
    home: AnimeScreen(service: service),
  );
}

Anime _anime(String id, String title) {
  return Anime(
    id: id,
    title: title,
    imageUrl: '',
    status: 'finished',
    score: 8.5,
    rank: int.parse(id),
    episodes: 12,
    userCount: 1000,
    type: 'TV',
    year: 2000,
    synopsis: 'Sinopsis lengkap $title',
  );
}

class _FakeKitsuService extends KitsuService {
  _FakeKitsuService(this.results)
    : super(client: MockClient((_) async => http.Response('{"data":[]}', 200)));

  final List<Anime> results;
  Completer<List<Anime>>? nextRequest;

  @override
  Future<List<Anime>> fetchTopAnime({int limit = 10}) {
    final request = nextRequest;
    if (request != null) {
      nextRequest = null;
      return request.future;
    }
    return Future.value(results);
  }
}
