import 'package:flutter/foundation.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/youtube_search_result.dart';
import '../../domain/usecases/search_youtube.dart';

class YoutubeSearchController extends ChangeNotifier {
  YoutubeSearchController(this._searchYoutube);
  final SearchYoutube _searchYoutube;

  List<YoutubeSearchResult> results = const [];
  bool isSearching = false;
  String? message;

  bool get isConfigured => _searchYoutube.isConfigured;

  Future<void> search(String query) async {
    final value = query.trim();
    if (value.isEmpty) return;
    isSearching = true;
    message = null;
    notifyListeners();
    final result = await _searchYoutube(value);
    switch (result) {
      case Success(value: final value):
        results = value;
        message = value.isEmpty
            ? 'No embeddable videos found for this search.'
            : null;
      case Failure(failure: final failure):
        results = const [];
        message = failure.message;
    }
    isSearching = false;
    notifyListeners();
  }
}
