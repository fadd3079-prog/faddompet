import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/components/balance_hero_card.dart';
import '../../shared/components/insight_card.dart';
import '../../shared/components/money_metric_card.dart';
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
              AppSpacing.xxl,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(),
                  SizedBox(height: AppSpacing.xl),
                  BalanceHeroCard(
                    totalBalance: 'Rp0',
                    walletInfo: '0 aktif',
                    monthlyStatus: 'Siap mulai',
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: 'Ringkasan bulan ini',
                    subtitle: 'Bulan berjalan',
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _MonthlySummaryGrid(),
                  SizedBox(height: AppSpacing.xxl),
                  InsightCard(
                    title: 'Belum ada pola keuangan',
                    message:
                        'Tambahkan beberapa transaksi pertama agar Faddompet bisa membaca pemasukan, pengeluaran, dan budget bulananmu.',
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: 'Transaksi terbaru',
                    subtitle: 'Aktivitas harian akan muncul di sini',
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
              Text('Halo, Fadd', style: theme.textTheme.displayMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pantau saldo, uang kos, dan proyek freelance dalam satu tempat.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Container(
          width: 54,
          height: 54,
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

class _MonthlySummaryGrid extends StatelessWidget {
  const _MonthlySummaryGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: constraints.maxWidth < 360 ? 1.05 : 1.16,
          children: const [
            MoneyMetricCard(
              label: 'Pemasukan',
              value: 'Rp0',
              caption: 'Masuk bulan ini',
              accentColor: AppColors.incomeGreen,
            ),
            MoneyMetricCard(
              label: 'Pengeluaran',
              value: 'Rp0',
              caption: 'Keluar bulan ini',
              accentColor: AppColors.expenseRed,
            ),
            MoneyMetricCard(
              label: 'Cashflow',
              value: 'Rp0',
              caption: 'Masuk dikurangi keluar',
              accentColor: AppColors.infoBlue,
            ),
            MoneyMetricCard(
              label: 'Budget',
              value: '0%',
              caption: 'Terpakai bulan ini',
              accentColor: AppColors.warningOrange,
            ),
          ],
        );
      },
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
            'Tambahkan transaksi pertama agar riwayat harianmu mulai tersusun rapi.',
      ),
    );
  }
}
