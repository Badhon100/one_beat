import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LibraryLocalDataSource {
  Future<String?> read();
  Future<void> write(String value);
}

class SharedPreferencesLibraryDataSource implements LibraryLocalDataSource {
  const SharedPreferencesLibraryDataSource();
  static const _key = 'onebeat.music_library.v1';

  @override
  Future<String?> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_key);
  }

  @override
  Future<void> write(String value) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_key, value);
    if (!saved) throw StateError('The music library could not be saved.');
  }
}
