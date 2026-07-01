import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.dark_mode_rounded,
        'Tampilan',
        'Ikuti perangkat, terang, atau gelap',
      ),
      (
        Icons.backup_rounded,
        'Data & Backup',
        'Simpan atau pulihkan data cadangan',
      ),
      (Icons.lock_rounded, 'Keamanan', 'PIN dan biometrik'),
      (Icons.info_rounded, 'Tentang Faddompet', 'Informasi aplikasi dan versi'),
    ];
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

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
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorderSubtle
                        : AppColors.borderSubtle,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: AppSpacing.iconTileSmall + AppSpacing.xxs,
                    height: AppSpacing.iconTileSmall + AppSpacing.xxs,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.softMint.withValues(alpha: 0.12)
                          : AppColors.surfaceMint,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      item.$1,
                      color: isDark ? AppColors.softMint : AppColors.primary,
                      size: 21,
                    ),
                  ),
                  title: Text(item.$2, style: theme.textTheme.titleMedium),
                  subtitle: Text(item.$3),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
