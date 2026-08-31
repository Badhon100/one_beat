import '../../../../core/result/result.dart';
import '../entities/music_library.dart';
import '../repositories/music_library_repository.dart';

class SaveMusicLibrary {
  const SaveMusicLibrary(this._repository);
  final MusicLibraryRepository _repository;

  Future<Result<void>> call(MusicLibrary library) => _repository.save(library);
}
