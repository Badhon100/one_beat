import '../../../../core/result/result.dart';
import '../entities/youtube_search_result.dart';

abstract interface class YoutubeSearchRepository {
  bool get isConfigured;
  Future<Result<List<YoutubeSearchResult>>> search(String query);
}
