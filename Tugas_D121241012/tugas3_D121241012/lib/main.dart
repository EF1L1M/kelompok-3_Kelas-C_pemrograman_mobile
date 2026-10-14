import 'package:flutter/material.dart';

import 'services/kitsu_service.dart';
import 'ui/screens/anime_screen.dart';

void main() {
  runApp(const KitsuApp());
}

class KitsuApp extends StatelessWidget {
  const KitsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    const scheme = ColorScheme.dark(
      primary: Color(0xFF5B8DEF),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF2B4A78),
      secondaryContainer: Color(0xFF16233B),
      surface: Color(0xFF0B1220),
      surfaceContainer: Color(0xFF141C2F),
      surfaceContainerHighest: Color(0xFF1E2942),
      onSurfaceVariant: Color(0xFFA9B4CC),
      outlineVariant: Color(0xFF232E47),
    );

    return MaterialApp(
      title: 'Anime Terpopuler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
      ),
      home: AnimeScreen(service: KitsuService()),
    );
  }
}
