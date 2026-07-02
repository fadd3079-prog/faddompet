import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'update_file_handler_base.dart';

UpdateFileHandler createUpdateFileHandler() => const IoUpdateFileHandler();

class IoUpdateFileHandler implements UpdateFileHandler {
  const IoUpdateFileHandler();

  static const _channel = MethodChannel('com.faddgraphics.faddompet/update');

  @override
  Future<SavedUpdateFile> saveApk({
    required String fileName,
    required Stream<List<int>> stream,
    required int? contentLength,
    required void Function(double? progress)? onProgress,
  }) async {
    final baseDirectory = await getTemporaryDirectory();
    final updatesDirectory = Directory(
      '${baseDirectory.path}${Platform.pathSeparator}updates',
    );
    await updatesDirectory.create(recursive: true);

    final file = File(
      '${updatesDirectory.path}${Platform.pathSeparator}${_safeFileName(fileName)}',
    );
    final sink = file.openWrite();
    var downloaded = 0;

    try {
      await for (final chunk in stream) {
        downloaded += chunk.length;
        sink.add(chunk);
        if (contentLength != null && contentLength > 0) {
          onProgress?.call((downloaded / contentLength).clamp(0, 1));
        } else {
          onProgress?.call(null);
        }
      }
      await sink.flush();
      await sink.close();
      final digest = sha256.convert(await file.readAsBytes()).toString();
      onProgress?.call(1);
      return SavedUpdateFile(
        path: file.path,
        sha256: digest,
        sizeBytes: downloaded,
      );
    } catch (_) {
      await sink.close();
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }

  @override
  Future<OpenUpdateFileResult> openFile(String path) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'openApk',
        {'path': path},
      );
      return OpenUpdateFileResult(
        opened: result?['opened'] == true,
        permissionDenied: result?['permissionDenied'] == true,
      );
    } on PlatformException catch (error) {
      return OpenUpdateFileResult(
        opened: false,
        permissionDenied: error.code == 'permission_denied',
      );
    } catch (_) {
      return const OpenUpdateFileResult(opened: false);
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _safeFileName(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }
}
