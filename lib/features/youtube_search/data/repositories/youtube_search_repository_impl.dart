import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/youtube_search_result.dart';
import '../../domain/repositories/youtube_search_repository.dart';
import '../datasources/youtube_remote_data_source.dart';

class YoutubeSearchRepositoryImpl implements YoutubeSearchRepository {
  YoutubeSearchRepositoryImpl({
    required String apiKey,
    YoutubeRemoteDataSource? dataSource,
  }) : _apiKey = apiKey,
       _dataSource = dataSource;

  final String _apiKey;
  final YoutubeRemoteDataSource? _dataSource;

  @override
  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  Future<Result<List<YoutubeSearchResult>>> search(String query) async {
    if (!isConfigured) {
      return const Failure(
        AppFailure(
          'YouTube search needs a YOUTUBE_API_KEY build setting. See the project README for setup.',
        ),
      );
    }
    try {
      final dataSource =
          _dataSource ?? YoutubeDataApiDataSource(apiKey: _apiKey);
      final results = await dataSource.search(query);
      return Success(
        results.map((result) => result.toEntity()).toList(growable: false),
      );
    } on Object catch (error) {
      return Failure(
        AppFailure('Could not search YouTube. Please try again.', cause: error),
      );
    }
  }
}
