import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/youtube_search_result_model.dart';

abstract interface class YoutubeRemoteDataSource {
  Future<List<YoutubeSearchResultModel>> search(String query);
}

class YoutubeDataApiDataSource implements YoutubeRemoteDataSource {
  YoutubeDataApiDataSource({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  @override
  Future<List<YoutubeSearchResultModel>> search(String query) async {
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'type': 'video',
      'videoEmbeddable': 'true',
      'maxResults': '20',
      'q': query,
      'key': _apiKey,
    });
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw StateError(
        _apiError(response.body) ??
            'YouTube search is temporarily unavailable.',
      );
    }
    final json = jsonDecode(response.body) as Map<String, Object?>;
    return (json['items'] as List<Object?>? ?? const [])
        .map(
          (item) =>
              YoutubeSearchResultModel.fromJson(item! as Map<String, Object?>),
        )
        .toList(growable: false);
  }

  String? _apiError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, Object?>;
      final error = json['error'] as Map<String, Object?>?;
      return error?['message'] as String?;
    } on Object {
      return null;
    }
  }
}
