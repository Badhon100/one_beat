import '../../../../core/result/result.dart';
import '../entities/music_library.dart';
import '../repositories/music_library_repository.dart';

class LoadMusicLibrary {
  const LoadMusicLibrary(this._repository);
  final MusicLibraryRepository _repository;

  Future<Result<MusicLibrary>> call() => _repository.load();
}
