import 'package:file_picker/file_picker.dart';

class PickedAudioFile {
  const PickedAudioFile({required this.name, required this.path});
  final String name;
  final String path;
}

abstract interface class LocalAudioPickerDataSource {
  Future<List<PickedAudioFile>> pickAudioFiles();
}

class FilePickerAudioDataSource implements LocalAudioPickerDataSource {
  const FilePickerAudioDataSource();

  @override
  Future<List<PickedAudioFile>> pickAudioFiles() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    return result
        .where((file) => file.path != null)
        .map((file) => PickedAudioFile(name: file.name, path: file.path!))
        .toList(growable: false);
  }
}
