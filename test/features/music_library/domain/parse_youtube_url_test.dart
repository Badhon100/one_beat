import 'package:flutter_test/flutter_test.dart';
import 'package:onebeat/features/music_library/domain/usecases/parse_youtube_url.dart';

void main() {
  const parse = ParseYoutubeUrl();

  test('extracts ids from supported YouTube URL formats', () {
    expect(parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
    expect(parse('https://youtu.be/dQw4w9WgXcQ?t=10'), 'dQw4w9WgXcQ');
    expect(parse('https://youtube.com/shorts/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
    expect(
      parse('https://music.youtube.com/watch?v=dQw4w9WgXcQ'),
      'dQw4w9WgXcQ',
    );
  });

  test('accepts a raw video id and rejects unrelated links', () {
    expect(parse('dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
    expect(parse('https://example.com/watch?v=dQw4w9WgXcQ'), isNull);
    expect(parse('not a link'), isNull);
  });
}
