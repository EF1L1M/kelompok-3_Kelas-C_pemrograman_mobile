import 'package:flutter/material.dart';

/// Gambar poster dengan indikator loading dan placeholder saat gagal dimuat.
/// Penyebab gagal dimuat dicetak ke konsol (debugPrint) untuk membantu debug.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.semanticLabel,
  });

  final String url;
  final double width;
  final double height;
  final double borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final placeholder = Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: scheme.onSurfaceVariant,
      ),
    );

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url.isEmpty
          ? placeholder
          : Image.network(
              url,
              excludeFromSemantics: true,
              width: width,
              height: height,
              fit: BoxFit.cover,
              // Di Flutter web, memakai elemen <img> agar tidak terblokir CORS.
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                final total = progress.expectedTotalBytes;
                return Container(
                  width: width,
                  height: height,
                  color: scheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: total == null
                          ? null
                          : progress.cumulativeBytesLoaded / total,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Gagal memuat gambar $url: $error');
                return placeholder;
              },
            ),
    );
    if (semanticLabel == null) return image;
    return Semantics(label: semanticLabel, image: true, child: image);
  }
}
