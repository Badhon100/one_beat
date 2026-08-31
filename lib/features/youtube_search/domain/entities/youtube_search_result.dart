class YoutubeSearchResult {
  const YoutubeSearchResult({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  });

  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;

  String get watchUrl => 'https://www.youtube.com/watch?v=$videoId';
}
