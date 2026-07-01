import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/components/section_header.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xl,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          Text('Analitik', style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Grafik dan ringkasan keuangan akan muncul setelah data transaksi tersedia.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(
            title: 'Rangkuman visual',
            subtitle: 'Belum ada data untuk dihitung',
          ),
          const SizedBox(height: AppSpacing.lg),
          const _ChartPlaceholder(
            title: 'Pengeluaran per Kategori',
            icon: Icons.donut_large_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          const _ChartPlaceholder(
            title: 'Cashflow Harian',
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          const _ChartPlaceholder(
            title: 'Pengeluaran Mingguan',
            icon: Icons.bar_chart_rounded,
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      height: 168,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.softMint.withValues(alpha: 0.14)
                  : AppColors.surfaceMint,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              icon,
              size: 23,
              color: isDark ? AppColors.softMint : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
        ],
      ),
    );
  }
}
