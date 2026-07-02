import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/enums/category_type.dart';
import '../../data/local/database/app_database.dart';
import '../../shared/helpers/category_icon_mapper.dart';
import '../../shared/widgets/app_brand_mark.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../shared/widgets/app_form_actions.dart';
import '../../shared/widgets/app_icon_action_button.dart';
import '../../shared/widgets/pressable_surface.dart';
import '../../shared/widgets/top_toast.dart';
import '../analytics/analytics_page.dart';
import 'widgets/app_update_sheet.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref
        .watch(appSettingsProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final security = ref
        .watch(securitySettingsProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final packageInfo = ref.watch(packageInfoProvider);
    final versionLabel = packageInfo.when(
      data: (info) => 'Versi ${info.version}',
      loading: () => 'Memuat versi...',
      error: (_, _) => 'Versi aplikasi belum bisa dimuat',
    );
    final aboutSubtitle = packageInfo.when(
      data: (info) => 'Versi ${info.version}, offline tanpa akun',
      loading: () => 'Memuat versi...',
      error: (_, _) => 'Versi aplikasi belum bisa dimuat',
    );
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xl,
          AppSpacing.screen,
          AppSpacing.contentBottomInset,
        ),
        children: [
          Text('Pengaturan', style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xxl),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Tampilan',
            subtitle: _themeLabel(settings?.themeMode ?? 'system'),
            onTap: () =>
                _showThemeSheet(context, ref, settings?.themeMode ?? 'system'),
          ),
          _SettingsTile(
            icon: Icons.visibility_off_rounded,
            title: 'Sembunyikan saldo',
            subtitle: settings?.hideBalance ?? false
                ? 'Nominal disamarkan'
                : 'Nominal terlihat',
            trailing: Switch(
              value: settings?.hideBalance ?? false,
              onChanged: (value) =>
                  ref.read(settingsRepositoryProvider).setHideBalance(value),
            ),
          ),
          _SettingsTile(
            icon: Icons.insights_rounded,
            title: 'Analitik & Budget',
            subtitle: 'Lihat grafik dan atur budget bulanan',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const Scaffold(body: AnalyticsPage()),
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.lock_rounded,
            title: 'Keamanan',
            subtitle: kIsWeb
                ? 'Kunci aplikasi tersedia di Android'
                : security?.pinEnabled ?? false
                ? 'PIN aktif, ${_autoLockLabel(security!.autoLockMinutes)}'
                : 'Buat PIN untuk mengunci aplikasi',
            onTap: kIsWeb
                ? () => TopToast.show(
                    context,
                    'Kunci aplikasi tersedia di Android.',
                    type: TopToastType.warning,
                  )
                : () => _showSecuritySheet(context),
          ),
          _SettingsTile(
            icon: Icons.backup_rounded,
            title: 'Data & Cadangan',
            subtitle: 'Pindahkan data ke HP baru atau simpan laporan',
            onTap: () => _showBackupSheet(context, ref),
          ),
          _SettingsTile(
            icon: Icons.category_rounded,
            title: 'Kategori',
            subtitle: 'Tambah, edit, atau nonaktifkan kategori',
            onTap: () => _showCategoriesSheet(context),
          ),
          const _SettingsTile(
            icon: Icons.payments_rounded,
            title: 'Mata uang',
            subtitle:
                'IDR - Rupiah. Pilihan mata uang lain akan tersedia nanti.',
          ),
          _SettingsTile(
            icon: Icons.warning_rounded,
            title: 'Zona Bahaya',
            subtitle: 'Reset semua data dengan konfirmasi',
            danger: true,
            onTap: () => _confirmReset(context, ref),
          ),
          _SettingsTile(
            icon: Icons.volunteer_activism_rounded,
            title: 'Dukung Pengembangan',
            subtitle: 'Dukungan opsional untuk pengembangan FadDompet.',
            onTap: () => _confirmExternalLink(
              context,
              url: 'https://tako.id/fadhol_pemula',
              actionLabel: 'Lanjutkan',
              note: 'Dukungan bersifat opsional.',
            ),
          ),
          _SettingsTile(
            icon: Icons.integration_instructions_rounded,
            title: 'Repositori GitHub',
            subtitle: 'Lihat kode sumber dan perkembangan proyek.',
            onTap: () => _confirmExternalLink(
              context,
              url: 'https://github.com/fadd3079-prog/faddompet',
              actionLabel: 'Buka GitHub',
            ),
          ),
          _SettingsTile(
            icon: Icons.system_update_alt_rounded,
            title: 'Pembaruan Aplikasi',
            subtitle: 'Periksa dan unduh versi terbaru FadDompet.',
            onTap: () => _showUpdateSheet(context),
          ),
          _SettingsTile(
            icon: Icons.info_rounded,
            title: 'Tentang FadDompet',
            subtitle: aboutSubtitle,
            onTap: () => _showAboutSheet(context, versionLabel),
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref, String selected) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetOption(
                title: 'Ikuti perangkat',
                selected: selected == 'system',
                onTap: () => _setTheme(context, ref, 'system'),
              ),
              _SheetOption(
                title: 'Terang',
                selected: selected == 'light',
                onTap: () => _setTheme(context, ref, 'light'),
              ),
              _SheetOption(
                title: 'Gelap',
                selected: selected == 'dark',
                onTap: () => _setTheme(context, ref, 'dark'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setTheme(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    await ref.read(settingsRepositoryProvider).setThemeMode(value);
    if (context.mounted) Navigator.pop(context);
  }

  void _showSecuritySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final security = ref.watch(securitySettingsProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: security.when(
                data: (settings) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SheetHeader(
                      title: 'Keamanan',
                      subtitle:
                          'Kunci FadDompet dengan PIN. Biometrik tetap punya PIN cadangan.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (settings.pinEnabled) ...[
                      _SheetOption(
                        title: 'Ubah PIN',
                        onTap: () => _createOrChangePin(
                          context,
                          ref,
                          requireCurrent: true,
                        ),
                      ),
                      _SheetOption(
                        title: 'Nonaktifkan PIN',
                        destructive: true,
                        onTap: () => _disablePin(context, ref),
                      ),
                    ] else
                      _SheetOption(
                        title: 'Buat PIN',
                        onTap: () => _createOrChangePin(context, ref),
                      ),
                    SwitchListTile.adaptive(
                      value: settings.biometricEnabled,
                      onChanged: settings.pinEnabled
                          ? (value) => _toggleBiometric(context, ref, value)
                          : null,
                      title: const Text('Buka dengan biometrik'),
                      subtitle: const Text('Opsional, PIN tetap bisa dipakai.'),
                    ),
                    ListTile(
                      onTap: settings.pinEnabled
                          ? () => _showAutoLockSheet(context, ref, settings)
                          : null,
                      title: const Text('Kunci otomatis'),
                      subtitle: Text(_autoLockLabel(settings.autoLockMinutes)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                loading: () => const Center(child: Text('Memuat keamanan')),
                error: (_, _) =>
                    const Center(child: Text('Keamanan belum bisa dimuat')),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createOrChangePin(
    BuildContext context,
    WidgetRef ref, {
    bool requireCurrent = false,
  }) async {
    final result = await showDialog<_PinSetupResult>(
      context: context,
      builder: (context) => _PinSetupDialog(requireCurrent: requireCurrent),
    );
    if (result == null) return;

    final repository = ref.read(securityRepositoryProvider);
    if (requireCurrent) {
      final ok = await repository.verifyPin(result.currentPin ?? '');
      if (!context.mounted) return;
      if (!ok) {
        TopToast.show(context, 'PIN tidak sesuai.', type: TopToastType.warning);
        return;
      }
    }

    try {
      await repository.savePin(result.newPin);
      if (!context.mounted) return;
      ref.invalidate(securitySettingsProvider);
      Navigator.pop(context);
      TopToast.show(
        context,
        requireCurrent ? 'PIN berhasil diperbarui.' : 'PIN berhasil dibuat.',
        type: TopToastType.success,
      );
    } on ArgumentError catch (error) {
      if (!context.mounted) return;
      TopToast.show(
        context,
        error.message.toString(),
        type: TopToastType.warning,
      );
    }
  }

  Future<void> _disablePin(BuildContext context, WidgetRef ref) async {
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => const _PinVerifyDialog(),
    );
    if (pin == null) return;
    final repository = ref.read(securityRepositoryProvider);
    final ok = await repository.verifyPin(pin);
    if (!context.mounted) return;
    if (!ok) {
      TopToast.show(context, 'PIN tidak sesuai.', type: TopToastType.warning);
      return;
    }
    await repository.disablePin();
    if (!context.mounted) return;
    ref.invalidate(securitySettingsProvider);
    Navigator.pop(context);
    TopToast.show(context, 'PIN dinonaktifkan.', type: TopToastType.success);
  }

  Future<void> _toggleBiometric(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final repository = ref.read(securityRepositoryProvider);
    try {
      await repository.setBiometricEnabled(value);
      if (!context.mounted) return;
      ref.invalidate(securitySettingsProvider);
      TopToast.show(
        context,
        value ? 'Biometrik diaktifkan.' : 'Biometrik dinonaktifkan.',
        type: TopToastType.success,
      );
    } on ArgumentError catch (error) {
      if (!context.mounted) return;
      TopToast.show(
        context,
        error.message.toString(),
        type: TopToastType.warning,
      );
    }
  }

  void _showAutoLockSheet(BuildContext context, WidgetRef ref, settings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final value in const [0, 1, 5, 15])
                _SheetOption(
                  title: _autoLockLabel(value),
                  selected: settings.autoLockMinutes == value,
                  onTap: () async {
                    final repository = ref.read(securityRepositoryProvider);
                    await repository.setAutoLockMinutes(value);
                    if (!context.mounted) return;
                    ref.invalidate(securitySettingsProvider);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHeader(
                title: 'Data & Cadangan',
                subtitle:
                    'Simpan salinan data agar mudah dipulihkan saat ganti HP.',
              ),
              const SizedBox(height: AppSpacing.lg),
              const _BackupSecurityNotice(),
              const SizedBox(height: AppSpacing.lg),
              _SheetOption(
                icon: Icons.ios_share_rounded,
                title: 'Cadangkan Data',
                subtitle:
                    'Simpan salinan data agar bisa dipulihkan saat ganti HP.',
                onTap: () => _runBackupAction(
                  context,
                  () => ref.read(backupRepositoryProvider).exportJson(),
                  'Data berhasil dicadangkan.',
                ),
              ),
              _SheetOption(
                icon: Icons.restore_rounded,
                title: 'Pulihkan dari Cadangan',
                subtitle: 'Impor file cadangan FadDompet dari perangkat lama.',
                onTap: () => _startImport(context, ref),
              ),
              _SheetOption(
                icon: Icons.table_chart_rounded,
                title: 'Ekspor Laporan CSV',
                subtitle:
                    'Simpan daftar transaksi untuk dibuka di spreadsheet.',
                onTap: () => _runBackupAction(
                  context,
                  () => ref.read(backupRepositoryProvider).exportCsv(),
                  'Laporan berhasil diekspor.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runBackupAction(
    BuildContext context,
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      Navigator.pop(context);
      TopToast.show(context, successMessage, type: TopToastType.success);
    } catch (_) {
      if (!context.mounted) return;
      TopToast.show(
        context,
        'File cadangan tidak valid.',
        type: TopToastType.warning,
      );
    }
  }

  Future<void> _startImport(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(backupRepositoryProvider);
      final preview = await repository.pickImportPreview();
      if (preview == null) return;
      if (!context.mounted) return;
      final confirmed = await showAppConfirmDialog(
        context: context,
        title: 'Pulihkan cadangan?',
        message:
            'Memulihkan cadangan akan mengganti data yang ada di perangkat ini. Pastikan kamu sudah mencadangkan data terbaru.\n\nIsi cadangan: ${preview.transactions} transaksi, ${preview.wallets} dompet, ${preview.categories} kategori, dan ${preview.budgets} budget.',
        confirmLabel: 'Pulihkan',
        danger: true,
      );
      if (!confirmed) return;
      await repository.restoreImport(preview);
      if (!context.mounted) return;
      Navigator.pop(context);
      TopToast.show(
        context,
        'Data berhasil dipulihkan.',
        type: TopToastType.success,
      );
    } catch (_) {
      if (!context.mounted) return;
      TopToast.show(
        context,
        'File cadangan tidak valid.',
        type: TopToastType.warning,
      );
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _ResetDialog(),
    );
    if (confirmed != true) return;
    final backupRepository = ref.read(backupRepositoryProvider);
    final securityRepository = ref.read(securityRepositoryProvider);
    await backupRepository.resetData();
    await securityRepository.disablePin();
    if (!context.mounted) return;
    ref.invalidate(securitySettingsProvider);
    TopToast.show(
      context,
      'Data berhasil direset.',
      type: TopToastType.success,
    );
  }

  void _showCategoriesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _CategoryManagerSheet(),
    );
  }

  void _showUpdateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const AppUpdateSheet(),
    );
  }

  void _confirmExternalLink(
    BuildContext context, {
    required String url,
    required String actionLabel,
    String? note,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHeader(
                title: 'Lanjutkan ke browser?',
                subtitle: 'Tautan ini akan dibuka di browser.',
              ),
              if (note != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(note, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppFormActions(
                secondaryLabel: 'Batal',
                primaryLabel: actionLabel,
                onSecondaryPressed: () => Navigator.pop(sheetContext),
                onPrimaryPressed: () async {
                  Navigator.pop(sheetContext);
                  await _openExternalLink(context, url);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openExternalLink(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      TopToast.show(
        context,
        'Tautan belum bisa dibuka.',
        type: TopToastType.warning,
      );
    }
  }

  void _showAboutSheet(BuildContext context, String versionLabel) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const AppBrandMark(size: 64, radius: AppRadius.lg),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FadDompet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Aplikasi pencatat keuangan pribadi offline.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Text(
                  '$versionLabel\nData tersimpan lokal di perangkat. Tidak perlu akun atau koneksi cloud.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final accent = danger ? AppColors.expenseRed : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PressableSurface(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: danger
                  ? AppColors.expenseRed.withValues(alpha: 0.28)
                  : isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.borderSubtle,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: AppSpacing.iconTileSmall + AppSpacing.xxs,
              height: AppSpacing.iconTileSmall + AppSpacing.xxs,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            title: Text(title, style: theme.textTheme.titleMedium),
            subtitle: Text(subtitle),
            trailing:
                trailing ??
                (onTap == null
                    ? null
                    : const Icon(Icons.chevron_right_rounded)),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: theme.textTheme.headlineSmall),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _BackupSecurityNotice extends StatelessWidget {
  const _BackupSecurityNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withValues(alpha: isDark ? 0.14 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.warningOrange.withValues(
            alpha: isDark ? 0.32 : 0.22,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.warningOrange, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'File cadangan berisi data keuangan. Simpan di tempat yang aman.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.title,
    this.subtitle,
    this.icon,
    this.selected = false,
    this.destructive = false,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final accent = destructive
        ? AppColors.expenseRed
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PressableSurface(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: isDark ? 0.36 : 0.24)
                  : isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: AppSpacing.iconTileSmall,
                  height: AppSpacing.iconTileSmall,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: accent, size: AppSpacing.xl),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: destructive ? AppColors.expenseRed : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle!, style: theme.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, color: accent)
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog({required this.requireCurrent});

  final bool requireCurrent;

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.requireCurrent ? 'Ubah PIN' : 'Buat PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.requireCurrent) ...[
            _PinTextField(
              controller: _currentController,
              label: 'PIN lama',
              hint: 'Masukkan PIN lama',
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _PinTextField(
            controller: _newController,
            label: 'PIN baru',
            hint: '4 sampai 6 angka',
          ),
          const SizedBox(height: AppSpacing.lg),
          _PinTextField(
            controller: _confirmController,
            label: 'Konfirmasi PIN',
            hint: 'Ulangi PIN baru',
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.expenseRed),
            ),
          ],
        ],
      ),
      actions: [
        AppFormActions(
          secondaryLabel: 'Batal',
          primaryLabel: 'Simpan',
          onSecondaryPressed: () => Navigator.pop(context),
          onPrimaryPressed: _submit,
        ),
      ],
    );
  }

  void _submit() {
    final pin = _newController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pin != confirm) {
      setState(() => _error = 'PIN tidak sama.');
      return;
    }
    Navigator.pop(
      context,
      _PinSetupResult(
        currentPin: widget.requireCurrent
            ? _currentController.text.trim()
            : null,
        newPin: pin,
      ),
    );
  }
}

class _PinVerifyDialog extends StatefulWidget {
  const _PinVerifyDialog();

  @override
  State<_PinVerifyDialog> createState() => _PinVerifyDialogState();
}

class _PinVerifyDialogState extends State<_PinVerifyDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nonaktifkan PIN'),
      content: _PinTextField(
        controller: _controller,
        label: 'PIN',
        hint: 'Masukkan PIN saat ini',
      ),
      actions: [
        AppFormActions(
          secondaryLabel: 'Batal',
          primaryLabel: 'Lanjut',
          onSecondaryPressed: () => Navigator.pop(context),
          onPrimaryPressed: () =>
              Navigator.pop(context, _controller.text.trim()),
        ),
      ],
    );
  }
}

class _PinTextField extends StatelessWidget {
  const _PinTextField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        helperText: 'PIN hanya tersimpan aman di perangkat ini.',
      ),
    );
  }
}

class _PinSetupResult {
  const _PinSetupResult({required this.currentPin, required this.newPin});

  final String? currentPin;
  final String newPin;
}

class _ResetDialog extends StatefulWidget {
  const _ResetDialog();

  @override
  State<_ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<_ResetDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _controller.text.trim().toUpperCase() == 'RESET';

    return AlertDialog(
      title: const Text('Reset semua data?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Semua transaksi, dompet, kategori, budget, dan pengaturan akan dihapus dari perangkat ini. Data tidak bisa dikembalikan kecuali kamu punya cadangan.',
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Ketik RESET',
              hintText: 'RESET',
              helperText: 'Cadangkan data terlebih dahulu jika perlu.',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        AppFormActions(
          secondaryLabel: 'Batal',
          primaryLabel: 'Reset Data',
          danger: true,
          onSecondaryPressed: () => Navigator.pop(context, false),
          onPrimaryPressed: valid ? () => Navigator.pop(context, true) : null,
        ),
      ],
    );
  }
}

class _CategoryManagerSheet extends ConsumerWidget {
  const _CategoryManagerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: categories.when(
          data: (items) => ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  AppIconActionButton(
                    icon: Icons.add_rounded,
                    label: 'Tambah kategori',
                    onPressed: () => _showCategoryDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kategori nonaktif tidak muncul saat menambah transaksi baru.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final group in _groupCategories(items).entries) ...[
                Text(group.key, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                for (final category in group.value)
                  _CategoryTile(
                    category: category,
                    onTap: () => _showCategoryActions(context, ref, category),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
          loading: () => const Center(child: Text('Memuat kategori')),
          error: (_, _) =>
              const Center(child: Text('Kategori belum bisa dimuat')),
        ),
      ),
    );
  }

  Map<String, List<CategoryEntry>> _groupCategories(List<CategoryEntry> items) {
    final groups = <String, List<CategoryEntry>>{};
    for (final item in items) {
      groups.putIfAbsent(item.groupName, () => []).add(item);
    }
    return groups;
  }

  void _showCategoryActions(
    BuildContext context,
    WidgetRef ref,
    CategoryEntry category,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                title: category.name,
                subtitle: category.isArchived
                    ? 'Kategori ini sedang nonaktif.'
                    : 'Pilih tindakan untuk kategori ini.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _SheetOption(
                title: 'Edit',
                onTap: () {
                  Navigator.pop(context);
                  _showCategoryDialog(context, ref, category);
                },
              ),
              _SheetOption(
                title: category.isArchived ? 'Aktifkan' : 'Nonaktifkan',
                onTap: () {
                  Navigator.pop(context);
                  _setCategoryArchived(
                    context,
                    ref,
                    category,
                    !category.isArchived,
                  );
                },
              ),
              _SheetOption(
                title: 'Hapus',
                destructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _deleteCategory(context, ref, category);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, [
    CategoryEntry? category,
  ]) async {
    final result = await showDialog<_CategoryFormResult>(
      context: context,
      builder: (context) => _CategoryDialog(category: category),
    );
    if (result == null) return;

    final repository = ref.read(categoryRepositoryProvider);
    try {
      if (category == null) {
        await repository.addCategory(
          name: result.name,
          type: result.type,
          groupName: result.groupName,
          colorValue: result.colorValue,
        );
      } else {
        await repository.updateCategory(
          category: category,
          name: result.name,
          type: result.type,
          groupName: result.groupName,
          colorValue: result.colorValue,
        );
      }
      if (!context.mounted) return;
      TopToast.show(
        context,
        category == null
            ? 'Kategori berhasil disimpan.'
            : 'Kategori berhasil diperbarui.',
        type: TopToastType.success,
      );
    } on ArgumentError catch (error) {
      if (!context.mounted) return;
      TopToast.show(
        context,
        error.message.toString(),
        type: TopToastType.warning,
      );
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryEntry category,
  ) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Hapus kategori?',
      message: 'Kategori yang sudah dihapus tidak bisa dipakai lagi.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!confirmed) return;
    final message = await ref
        .read(categoryRepositoryProvider)
        .deleteCategory(category);
    if (!context.mounted) return;
    TopToast.show(
      context,
      message ?? 'Kategori berhasil dihapus.',
      type: message == null ? TopToastType.success : TopToastType.warning,
    );
  }

  Future<void> _setCategoryArchived(
    BuildContext context,
    WidgetRef ref,
    CategoryEntry category,
    bool value,
  ) async {
    await ref.read(categoryRepositoryProvider).setArchived(category, value);
    if (!context.mounted) return;
    TopToast.show(
      context,
      value ? 'Kategori dinonaktifkan.' : 'Kategori diaktifkan kembali.',
      type: TopToastType.success,
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final CategoryEntry category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PressableSurface(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.iconTileSmall,
                height: AppSpacing.iconTileSmall,
                decoration: BoxDecoration(
                  color: Color(category.colorValue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  categoryIconForEntry(category),
                  color: Color(category.colorValue),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      category.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (category.isArchived)
                Text(
                  'Nonaktif',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.warningOrange,
                  ),
                )
              else if (category.isDefault)
                Text('Bawaan', style: theme.textTheme.labelSmall),
              const Icon(Icons.more_horiz_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.category});

  final CategoryEntry? category;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;
  late CategoryType _type;
  late int _colorValue;

  static const _colors = [
    AppColors.expenseRed,
    AppColors.incomeGreen,
    AppColors.primary,
    AppColors.infoBlue,
    AppColors.warningOrange,
    AppColors.textSecondary,
  ];

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _groupController = TextEditingController(
      text: category?.groupName ?? 'Lainnya',
    );
    _type = category?.type == 'income'
        ? CategoryType.income
        : CategoryType.expense;
    _colorValue = category?.colorValue ?? AppColors.primary.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.category != null;

    return AlertDialog(
      title: Text(editing ? 'Edit kategori' : 'Tambah kategori'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama kategori',
                hintText: 'Contoh: Makanan',
                helperText: 'Pakai nama yang singkat dan mudah dikenali.',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _groupController,
              decoration: const InputDecoration(
                labelText: 'Grup',
                hintText: 'Contoh: Kebutuhan Harian',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment(
                  value: CategoryType.expense,
                  label: Text('Pengeluaran'),
                ),
                ButtonSegment(
                  value: CategoryType.income,
                  label: Text('Pemasukan'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in _colors)
                  ChoiceChip(
                    label: const SizedBox(width: AppSpacing.md),
                    selected: _colorValue == color.toARGB32(),
                    avatar: CircleAvatar(backgroundColor: color),
                    onSelected: (_) =>
                        setState(() => _colorValue = color.toARGB32()),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        AppFormActions(
          secondaryLabel: 'Batal',
          primaryLabel: 'Simpan',
          onSecondaryPressed: () => Navigator.pop(context),
          onPrimaryPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              _CategoryFormResult(
                name: name,
                groupName: _groupController.text.trim(),
                type: _type,
                colorValue: _colorValue,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryFormResult {
  const _CategoryFormResult({
    required this.name,
    required this.groupName,
    required this.type,
    required this.colorValue,
  });

  final String name;
  final String groupName;
  final CategoryType type;
  final int colorValue;
}

String _themeLabel(String value) {
  switch (value) {
    case 'light':
      return 'Terang';
    case 'dark':
      return 'Gelap';
    default:
      return 'Ikuti perangkat';
  }
}

String _autoLockLabel(int value) {
  switch (value) {
    case 0:
      return 'Langsung';
    case 1:
      return '1 menit';
    case 5:
      return '5 menit';
    case 15:
      return '15 menit';
    default:
      return '$value menit';
  }
}
