abstract class UpdateFileHandler {
  Future<SavedUpdateFile> saveApk({
    required String fileName,
    required Stream<List<int>> stream,
    required int? contentLength,
    required void Function(double? progress)? onProgress,
  });

  Future<OpenUpdateFileResult> openFile(String path);

  Future<void> deleteFile(String path);
}

class SavedUpdateFile {
  const SavedUpdateFile({
    required this.path,
    required this.sha256,
    required this.sizeBytes,
  });

  final String path;
  final String sha256;
  final int sizeBytes;
}

class OpenUpdateFileResult {
  const OpenUpdateFileResult({
    required this.opened,
    this.permissionDenied = false,
    this.unsupported = false,
  });

  final bool opened;
  final bool permissionDenied;
  final bool unsupported;
}
