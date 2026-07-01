import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/components/balance_hero_card.dart';
import '../../shared/components/insight_card.dart';
import '../../shared/components/section_header.dart';
import '../../shared/widgets/empty_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.xl,
              AppSpacing.screen,
              AppSpacing.contentBottomInset,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(),
                  SizedBox(height: AppSpacing.xl),
                  BalanceHeroCard(
                    totalBalance: 'Rp0',
                    walletInfo: '0 dompet',
                    monthlyStatus: 'Siap mulai',
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: 'Ringkasan bulan ini',
                    subtitle: 'Bulan berjalan',
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _MonthlySnapshotCard(),
                  SizedBox(height: AppSpacing.xxl),
                  InsightCard(
                    title: 'Ringkasan belum tersedia',
                    message:
                        'Tambahkan transaksi pertama untuk mulai melihat ringkasan keuanganmu.',
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: 'Riwayat terbaru',
                    subtitle: 'Transaksi terakhir akan muncul di sini',
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _RecentTransactionsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.softMint.withValues(alpha: 0.12)
                      : AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Faddompet',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? AppColors.softMint : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Halo', style: theme.textTheme.displayMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Catat pemasukan dan pengeluaran harian dengan mudah.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Container(
          width: AppSpacing.iconTile + AppSpacing.sm,
          height: AppSpacing.iconTile + AppSpacing.sm,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.borderSubtle,
            ),
            boxShadow: AppShadows.soft(theme.colorScheme.brightness),
          ),
          child: Center(
            child: Text(
              'IDR',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark ? AppColors.softMint : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlySnapshotCard extends StatelessWidget {
  const _MonthlySnapshotCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _FlowAmount(
                  label: 'Masuk',
                  value: 'Rp0',
                  caption: 'Belum ada pemasukan',
                  accentColor: AppColors.incomeGreen,
                ),
              ),
              Container(
                width: AppSpacing.xxs,
                height: AppSpacing.huge + AppSpacing.xl,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const Expanded(
                child: _FlowAmount(
                  label: 'Keluar',
                  value: 'Rp0',
                  caption: 'Belum ada pengeluaran',
                  accentColor: AppColors.expenseRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceSoft.withValues(alpha: 0.54)
                  : AppColors.backgroundSoft,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              children: [
                _MiniStatusRow(
                  label: 'Selisih',
                  value: 'Rp0',
                  helper: 'Pemasukan dikurangi pengeluaran',
                  accentColor: AppColors.infoBlue,
                  theme: theme,
                ),
                const SizedBox(height: AppSpacing.md),
                _MiniStatusRow(
                  label: 'Anggaran',
                  value: '0%',
                  helper: 'Terpakai bulan ini',
                  accentColor: AppColors.warningOrange,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowAmount extends StatelessWidget {
  const _FlowAmount({
    required this.label,
    required this.value,
    required this.caption,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String caption;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: AppSpacing.metricDot,
              height: AppSpacing.metricDot,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _MiniStatusRow extends StatelessWidget {
  const _MiniStatusRow({
    required this.label,
    required this.value,
    required this.helper,
    required this.accentColor,
    required this.theme,
  });

  final String label;
  final String value;
  final String helper;
  final Color accentColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSpacing.xs,
          height: AppSpacing.xxl,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                helper,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: const EmptyState(
        compact: true,
        icon: Icons.receipt_long_rounded,
        title: 'Belum ada transaksi',
        message:
            'Tambahkan transaksi pertama untuk mulai melihat riwayat keuanganmu.',
      ),
    );
  }
}
