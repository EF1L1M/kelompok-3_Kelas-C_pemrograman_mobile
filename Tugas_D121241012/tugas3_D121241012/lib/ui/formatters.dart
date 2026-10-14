String formatAnimeStatus(String status) {
  switch (status) {
    case 'finished':
      return 'Selesai tayang';
    case 'current':
      return 'Sedang tayang';
    case 'upcoming':
    case 'unreleased':
    case 'tba':
      return 'Belum tayang';
    default:
      return status;
  }
}

String formatAnimeUserCount(int? count) {
  if (count == null) return '-';
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)} jt';
  }
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(0)} rb';
  }
  return '$count';
}
