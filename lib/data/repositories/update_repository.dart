import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'update_file_handler.dart';

enum AppUpdateStatus { upToDate, updateAvailable, unavailable, error }

class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static AppVersion? parse(String value) {
    final clean = value
        .trim()
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')
        .first;
    final match = RegExp(r'^(\d+)(?:\.(\d+))?(?:\.(\d+))?').firstMatch(clean);
    if (match == null) return null;

    return AppVersion(
      int.parse(match.group(1)!),
      int.tryParse(match.group(2) ?? '') ?? 0,
      int.tryParse(match.group(3) ?? '') ?? 0,
    );
  }

  String get normalized => '$major.$minor.$patch';

  @override
  int compareTo(AppVersion other) {
    final majorCompare = major.compareTo(other.major);
    if (majorCompare != 0) return majorCompare;
    final minorCompare = minor.compareTo(other.minor);
    if (minorCompare != 0) return minorCompare;
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => normalized;
}

class AppUpdateAsset {
  const AppUpdateAsset({
    required this.name,
    required this.downloadUrl,
    required this.sizeBytes,
  });

  final String name;
  final String downloadUrl;
  final int sizeBytes;
}

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.status,
    required this.currentVersion,
    this.latestVersion,
    this.releaseName,
    this.releaseBody,
    this.publishedAt,
    this.asset,
    this.sha256,
    this.message,
  });

  final AppUpdateStatus status;
  final String currentVersion;
  final String? latestVersion;
  final String? releaseName;
  final String? releaseBody;
  final DateTime? publishedAt;
  final AppUpdateAsset? asset;
  final String? sha256;
  final String? message;

  bool get canDownload =>
      status == AppUpdateStatus.updateAvailable && asset != null;
}

class AppDownloadedUpdate {
  const AppDownloadedUpdate({
    required this.path,
    required this.fileName,
    required this.sizeBytes,
    required this.sha256,
    required this.verified,
  });

  final String path;
  final String fileName;
  final int sizeBytes;
  final String sha256;
  final bool verified;
}

class AppUpdateException implements Exception {
  const AppUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UpdateRepository {
  UpdateRepository({
    http.Client? client,
    UpdateFileHandler? fileHandler,
    this.currentVersionLoader,
  }) : _client = client ?? http.Client(),
       _fileHandler = fileHandler ?? createUpdateFileHandler();

  static final Uri latestReleaseUri = Uri.parse(
    'https://api.github.com/repos/fadd3079-prog/faddompet/releases/latest',
  );

  final http.Client _client;
  final UpdateFileHandler _fileHandler;
  final Future<String> Function()? currentVersionLoader;

  static const _timeout = Duration(seconds: 20);

  Future<AppUpdateInfo> checkForUpdate() async {
    final currentVersion = await _loadCurrentVersion();
    try {
      final response = await _client
          .get(
            latestReleaseUri,
            headers: const {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'FadDompet',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return AppUpdateInfo(
          status: AppUpdateStatus.error,
          currentVersion: currentVersion,
          message: 'Pembaruan belum bisa diperiksa.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return AppUpdateInfo(
          status: AppUpdateStatus.error,
          currentVersion: currentVersion,
          message: 'Pembaruan belum bisa diperiksa.',
        );
      }

      return parseRelease(decoded, currentVersion);
    } catch (_) {
      return AppUpdateInfo(
        status: AppUpdateStatus.error,
        currentVersion: currentVersion,
        message: 'Pembaruan belum bisa diperiksa.',
      );
    }
  }

  Future<AppDownloadedUpdate> downloadUpdate(
    AppUpdateInfo info, {
    void Function(double? progress)? onProgress,
  }) async {
    final asset = info.asset;
    final latestVersion = info.latestVersion;
    if (asset == null || latestVersion == null) {
      throw const AppUpdateException('File pembaruan belum tersedia.');
    }

    try {
      final request = http.Request('GET', Uri.parse(asset.downloadUrl))
        ..headers['User-Agent'] = 'FadDompet';
      final response = await _client.send(request).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const AppUpdateException(
          'Pembaruan belum bisa diunduh. Periksa koneksi internet kamu.',
        );
      }

      final fileName = 'FadDompet-v$latestVersion-arm64.apk';
      final savedFile = await _fileHandler.saveApk(
        fileName: fileName,
        stream: response.stream,
        contentLength:
            response.contentLength != null && response.contentLength! > 0
            ? response.contentLength
            : asset.sizeBytes,
        onProgress: onProgress,
      );

      final expectedSha = info.sha256;
      if (expectedSha != null &&
          savedFile.sha256.toLowerCase() != expectedSha.toLowerCase()) {
        await _fileHandler.deleteFile(savedFile.path);
        throw const AppUpdateException(
          'File pembaruan tidak valid. Unduh ulang dari halaman rilis resmi.',
        );
      }

      return AppDownloadedUpdate(
        path: savedFile.path,
        fileName: fileName,
        sizeBytes: savedFile.sizeBytes,
        sha256: savedFile.sha256,
        verified: expectedSha != null,
      );
    } on AppUpdateException {
      rethrow;
    } catch (_) {
      throw const AppUpdateException(
        'Pembaruan belum bisa diunduh. Periksa koneksi internet kamu.',
      );
    }
  }

  Future<OpenUpdateFileResult> openDownloadedUpdate(
    AppDownloadedUpdate update,
  ) {
    return _fileHandler.openFile(update.path);
  }

  void close() => _client.close();

  static AppUpdateInfo parseRelease(
    Map<String, Object?> release,
    String currentVersion,
  ) {
    final rawLatestVersion =
        release['tag_name'] as String? ?? release['name'] as String?;
    final current = AppVersion.parse(currentVersion);
    final latest = rawLatestVersion == null
        ? null
        : AppVersion.parse(rawLatestVersion);

    if (current == null || latest == null) {
      return AppUpdateInfo(
        status: AppUpdateStatus.error,
        currentVersion: currentVersion,
        message: 'Pembaruan belum bisa diperiksa.',
      );
    }

    final releaseBody = release['body'] as String?;
    final common = _ReleaseCommon(
      currentVersion: current.normalized,
      latestVersion: latest.normalized,
      releaseName: release['name'] as String?,
      releaseBody: releaseBody,
      publishedAt: DateTime.tryParse(release['published_at'] as String? ?? ''),
      sha256: extractSha256(releaseBody),
    );

    if (latest.compareTo(current) <= 0) {
      return common.info(AppUpdateStatus.upToDate);
    }

    final asset = pickArm64ApkAsset(release['assets']);
    if (asset == null) {
      return common.info(
        AppUpdateStatus.unavailable,
        message: 'File pembaruan belum tersedia.',
      );
    }

    return common.info(AppUpdateStatus.updateAvailable, asset: asset);
  }

  static AppUpdateAsset? pickArm64ApkAsset(Object? assets) {
    if (assets is! List) return null;

    for (final item in assets) {
      if (item is! Map) continue;
      final name = item['name'];
      final downloadUrl = item['browser_download_url'];
      final size = item['size'];
      if (name is! String || downloadUrl is! String) continue;
      final lowerName = name.toLowerCase();
      if (!lowerName.endsWith('.apk') || !lowerName.contains('arm64')) {
        continue;
      }
      return AppUpdateAsset(
        name: name,
        downloadUrl: downloadUrl,
        sizeBytes: size is int ? size : 0,
      );
    }

    return null;
  }

  static String? extractSha256(String? body) {
    if (body == null || body.isEmpty) return null;
    final match = RegExp(
      r'\b[A-Fa-f0-9]{64}\b',
      multiLine: true,
    ).firstMatch(body);
    return match?.group(0)?.toLowerCase();
  }

  Future<String> _loadCurrentVersion() async {
    final loader = currentVersionLoader;
    if (loader != null) {
      return loader();
    }
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}

class _ReleaseCommon {
  const _ReleaseCommon({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseName,
    required this.releaseBody,
    required this.publishedAt,
    required this.sha256,
  });

  final String currentVersion;
  final String latestVersion;
  final String? releaseName;
  final String? releaseBody;
  final DateTime? publishedAt;
  final String? sha256;

  AppUpdateInfo info(
    AppUpdateStatus status, {
    AppUpdateAsset? asset,
    String? message,
  }) {
    return AppUpdateInfo(
      status: status,
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      releaseName: releaseName,
      releaseBody: releaseBody,
      publishedAt: publishedAt,
      asset: asset,
      sha256: sha256,
      message: message,
    );
  }
}
