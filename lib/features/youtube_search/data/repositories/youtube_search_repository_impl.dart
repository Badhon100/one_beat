import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;

import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/youtube_search_result.dart';
import '../../domain/repositories/youtube_search_repository.dart';
import '../datasources/youtube_remote_data_source.dart';

class YoutubeSearchRepositoryImpl implements YoutubeSearchRepository {
  YoutubeSearchRepositoryImpl({
    required String apiKey,
    YoutubeRemoteDataSource? dataSource,
  });

  @override
  bool get isConfigured => true;

  @override
  Future<Result<List<YoutubeSearchResult>>> search(String query) async {
    try {
      final yt = yt_exp.YoutubeExplode();
      final list = await yt.search.search(query);
      final results = list.map((video) {
        return YoutubeSearchResult(
          videoId: video.id.value,
          title: video.title,
          channelTitle: video.author,
          thumbnailUrl: video.thumbnails.mediumResUrl,
        );
      }).toList();
      yt.close();
      return Success(results);
    } on Object catch (error) {
      return Failure(AppFailure('Could not search YouTube. Please try again.', cause: error));
    }
  }
}
