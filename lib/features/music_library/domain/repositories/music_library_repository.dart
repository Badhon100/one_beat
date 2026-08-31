import '../../../../core/result/result.dart';
import '../entities/music_library.dart';

abstract interface class MusicLibraryRepository {
  Future<Result<MusicLibrary>> load();
  Future<Result<void>> save(MusicLibrary library);
}
