class ParseYoutubeUrl {
  const ParseYoutubeUrl();

  String? call(String input) {
    final value = input.trim();
    if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(value)) return value;

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return null;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');

    String? candidate;
    if (host == 'youtu.be') {
      candidate = uri.pathSegments.firstOrNull;
    } else if (host == 'youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'music.youtube.com') {
      if (uri.pathSegments.firstOrNull == 'watch') {
        candidate = uri.queryParameters['v'];
      } else if ({'shorts', 'embed'}.contains(uri.pathSegments.firstOrNull) &&
          uri.pathSegments.length > 1) {
        candidate = uri.pathSegments[1];
      }
    }

    return candidate != null &&
            RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(candidate)
        ? candidate
        : null;
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
