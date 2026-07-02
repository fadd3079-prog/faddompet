import 'update_file_handler_base.dart';

UpdateFileHandler createUpdateFileHandler() => const StubUpdateFileHandler();

class StubUpdateFileHandler implements UpdateFileHandler {
  const StubUpdateFileHandler();

  @override
  Future<SavedUpdateFile> saveApk({
    required String fileName,
    required Stream<List<int>> stream,
    required int? contentLength,
    required void Function(double? progress)? onProgress,
  }) {
    throw UnsupportedError('Pembaruan tersedia di Android.');
  }

  @override
  Future<OpenUpdateFileResult> openFile(String path) async {
    return const OpenUpdateFileResult(opened: false, unsupported: true);
  }

  @override
  Future<void> deleteFile(String path) async {}
}
