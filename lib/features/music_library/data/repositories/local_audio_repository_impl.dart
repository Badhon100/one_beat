import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/media_track.dart';
import '../../domain/repositories/local_audio_repository.dart';
import '../datasources/local_audio_picker_data_source.dart';

class LocalAudioRepositoryImpl implements LocalAudioRepository {
  const LocalAudioRepositoryImpl(this._dataSource);
  final LocalAudioPickerDataSource _dataSource;

  @override
  Future<Result<List<MediaTrack>>> pickTracks() async {
    try {
      final files = await _dataSource.pickAudioFiles();
      final stamp = DateTime.now();
      return Success(
        files.indexed
            .map((entry) {
              final (index, file) = entry;
              final title = file.name.replaceFirst(RegExp(r'\.[^.]+$'), '');
              return MediaTrack(
                id: 'local_${stamp.microsecondsSinceEpoch}_$index',
                title: title,
                artist: 'Local audio',
                location: file.path,
                sourceType: MediaSourceType.local,
                addedAt: stamp,
              );
            })
            .toList(growable: false),
      );
    } on Object catch (error) {
      return Failure(
        AppFailure('Could not import the selected audio.', cause: error),
      );
    }
  }
}
