import '../../../../core/result/result.dart';
import '../entities/youtube_search_result.dart';
import '../repositories/youtube_search_repository.dart';

class SearchYoutube {
  const SearchYoutube(this._repository);
  final YoutubeSearchRepository _repository;

  bool get isConfigured => _repository.isConfigured;

  Future<Result<List<YoutubeSearchResult>>> call(String query) {
    return _repository.search(query);
  }
}
