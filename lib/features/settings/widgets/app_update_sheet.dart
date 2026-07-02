import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/repositories/update_repository.dart';
import '../../../shared/widgets/app_form_actions.dart';
import '../../../shared/widgets/top_toast.dart';

class AppUpdateSheet extends ConsumerStatefulWidget {
  const AppUpdateSheet({super.key});

  @override
  ConsumerState<AppUpdateSheet> createState() => _AppUpdateSheetState();
}

class _AppUpdateSheetState extends ConsumerState<AppUpdateSheet> {
  AppUpdateInfo? _info;
  AppDownloadedUpdate? _downloaded;
  bool _checking = false;
  bool _downloading = false;
  double? _progress;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _checkUpdate();
    }
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _checking = true;
      _errorMessage = null;
      _downloaded = null;
      _progress = null;
    });

    final info = await ref.read(updateRepositoryProvider).checkForUpdate();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _info = info;
      if (info.status == AppUpdateStatus.error) {
        _errorMessage = info.message ?? 'Pembaruan belum bisa diperiksa.';
      }
    });
  }

  Future<void> _downloadUpdate() async {
    final info = _info;
    if (info == null || !info.canDownload) return;

    setState(() {
      _downloading = true;
      _errorMessage = null;
      _progress = 0;
    });

    try {
      final downloaded = await ref
          .read(updateRepositoryProvider)
          .downloadUpdate(info, onProgress: _updateProgress);
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _downloaded = downloaded;
        _progress = 1;
      });
    } on AppUpdateException catch (error) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _errorMessage = error.message;
      });
    }
  }

  Future<void> _openFile() async {
    final downloaded = _downloaded;
    if (downloaded == null) return;

    final result = await ref
        .read(updateRepositoryProvider)
        .openDownloadedUpdate(downloaded);
    if (!mounted) return;

    if (result.opened) {
      Navigator.pop(context);
      return;
    }

    final message = result.permissionDenied
        ? 'Izinkan pemasangan dari sumber ini di pengaturan Android, lalu coba lagi.'
        : result.unsupported
        ? 'Pembaruan aplikasi tersedia di Android.'
        : 'File pembaruan belum bisa dibuka.';
    TopToast.show(context, message, type: TopToastType.warning);
  }

  void _updateProgress(double? value) {
    if (!mounted) return;
    final previous = _progress;
    if (value != null &&
        previous != null &&
        (value - previous).abs() < 0.01 &&
        value < 1) {
      return;
    }
    setState(() => _progress = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.screen,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusIcon(status: _statusForIcon),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(_body, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            if (_sizeLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _InfoPill(label: 'Ukuran file: $_sizeLabel'),
            ],
            if (_downloaded != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _InfoPill(
                label: _downloaded!.verified
                    ? 'File pembaruan sudah diperiksa.'
                    : 'File berhasil diunduh. Pastikan pembaruan berasal dari rilis resmi FadDompet.',
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.warningOrange,
                ),
              ),
            ],
            if (_checking || _downloading) ...[
              const SizedBox(height: AppSpacing.xl),
              LinearProgressIndicator(value: _downloading ? _progress : null),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _downloading && _progress != null
                    ? '${(_progress! * 100).clamp(0, 100).round()}%'
                    : _checking
                    ? 'Memeriksa pembaruan...'
                    : 'Mengunduh pembaruan...',
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (kIsWeb) {
      return FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Tutup'),
      );
    }

    if (_checking || _downloading) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: null,
              child: Text(_downloading ? 'Nanti saja' : 'Tutup'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton(
              onPressed: null,
              child: Text(
                _downloading ? 'Mengunduh...' : 'Cek Pembaruan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    if (_downloaded != null) {
      return AppFormActions(
        secondaryLabel: 'Nanti',
        primaryLabel: 'Buka File',
        onSecondaryPressed: () => Navigator.pop(context),
        onPrimaryPressed: _openFile,
      );
    }

    final info = _info;
    if (info?.canDownload ?? false) {
      return AppFormActions(
        secondaryLabel: 'Nanti saja',
        primaryLabel: 'Download Pembaruan',
        onSecondaryPressed: () => Navigator.pop(context),
        onPrimaryPressed: _downloadUpdate,
      );
    }

    if (info?.status == AppUpdateStatus.error || _errorMessage != null) {
      return AppFormActions(
        secondaryLabel: 'Tutup',
        primaryLabel: 'Coba Lagi',
        onSecondaryPressed: () => Navigator.pop(context),
        onPrimaryPressed: _checkUpdate,
      );
    }

    return FilledButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Tutup'),
    );
  }

  AppUpdateStatus get _statusForIcon {
    if (kIsWeb) return AppUpdateStatus.unavailable;
    if (_downloaded != null) return AppUpdateStatus.updateAvailable;
    if (_errorMessage != null) return AppUpdateStatus.error;
    return _info?.status ?? AppUpdateStatus.upToDate;
  }

  String get _title {
    if (kIsWeb) return 'Pembaruan tersedia di Android';
    if (_checking) return 'Memeriksa pembaruan...';
    if (_downloading) return 'Mengunduh pembaruan...';
    if (_downloaded != null) return 'Pembaruan berhasil diunduh';

    switch (_info?.status) {
      case AppUpdateStatus.updateAvailable:
        return 'Pembaruan tersedia';
      case AppUpdateStatus.unavailable:
        return 'File pembaruan belum tersedia';
      case AppUpdateStatus.error:
        return 'Pembaruan belum bisa diperiksa';
      case AppUpdateStatus.upToDate:
      case null:
        return 'FadDompet sudah versi terbaru';
    }
  }

  String get _body {
    if (kIsWeb) {
      return 'Cek dan download pembaruan bisa digunakan di aplikasi Android.';
    }
    if (_checking) {
      return 'Tunggu sebentar, FadDompet sedang memeriksa versi terbaru.';
    }
    if (_downloading) {
      return 'Pembaruan sedang diunduh. Pastikan koneksi tetap stabil.';
    }
    if (_downloaded != null) {
      return 'Buka file pembaruan untuk melanjutkan proses install. Android akan meminta konfirmasi sebelum aplikasi diperbarui.';
    }

    final info = _info;
    switch (info?.status) {
      case AppUpdateStatus.updateAvailable:
        return 'FadDompet v${info!.latestVersion} sudah tersedia. Unduh pembaruan untuk mendapatkan perbaikan dan peningkatan terbaru.';
      case AppUpdateStatus.unavailable:
        return 'Versi terbaru sudah ditemukan, tetapi file Android arm64 belum tersedia.';
      case AppUpdateStatus.error:
        return 'Coba lagi nanti saat koneksi internet tersedia.';
      case AppUpdateStatus.upToDate:
      case null:
        return 'Versi ${info?.currentVersion ?? ''} sudah terpasang di perangkat ini.';
    }
  }

  String? get _sizeLabel {
    final size = _info?.asset?.sizeBytes;
    if (size == null || size <= 0 || _downloaded != null) return null;
    return _formatBytes(size);
  }

  String _formatBytes(int bytes) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    final mb = bytes / (1024 * 1024);
    return '${formatter.format(double.parse(mb.toStringAsFixed(1)))} MB';
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final AppUpdateStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AppUpdateStatus.updateAvailable => AppColors.primary,
      AppUpdateStatus.upToDate => AppColors.incomeGreen,
      AppUpdateStatus.unavailable => AppColors.infoBlue,
      AppUpdateStatus.error => AppColors.warningOrange,
    };
    final icon = switch (status) {
      AppUpdateStatus.updateAvailable => Icons.download_rounded,
      AppUpdateStatus.upToDate => Icons.check_rounded,
      AppUpdateStatus.unavailable => Icons.info_rounded,
      AppUpdateStatus.error => Icons.wifi_off_rounded,
    };

    return Container(
      width: AppSpacing.iconTile,
      height: AppSpacing.iconTile,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(label, style: theme.textTheme.bodyMedium),
    );
  }
}
