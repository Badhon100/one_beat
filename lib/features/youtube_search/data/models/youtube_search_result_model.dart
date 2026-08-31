import '../../domain/entities/youtube_search_result.dart';

class YoutubeSearchResultModel {
  const YoutubeSearchResultModel({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  });

  factory YoutubeSearchResultModel.fromJson(Map<String, Object?> json) {
    final id = json['id']! as Map<String, Object?>;
    final snippet = json['snippet']! as Map<String, Object?>;
    final thumbnails = snippet['thumbnails']! as Map<String, Object?>;
    final thumbnail = (thumbnails['high'] ?? thumbnails['medium'] ?? thumbnails['default'])!
        as Map<String, Object?>;
    return YoutubeSearchResultModel(
      videoId: id['videoId']! as String,
      title: snippet['title']! as String,
      channelTitle: snippet['channelTitle']! as String,
      thumbnailUrl: thumbnail['url']! as String,
    );
  }

  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;

  YoutubeSearchResult toEntity() => YoutubeSearchResult(
    videoId: videoId,
    title: title,
    channelTitle: channelTitle,
    thumbnailUrl: thumbnailUrl,
  );
}
