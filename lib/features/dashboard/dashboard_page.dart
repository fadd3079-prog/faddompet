import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/enums/transaction_type.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../data/repositories/app_models.dart';
import '../../shared/components/balance_hero_card.dart';
import '../../shared/components/insight_card.dart';
import '../../shared/components/section_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../transactions/widgets/transaction_tile.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final settings = ref
        .watch(appSettingsProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final hideBalance = settings?.hideBalance ?? false;

    return summary.when(
      data: (data) => SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xl,
                AppSpacing.screen,
                AppSpacing.contentBottomInset,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardHeader(userName: settings?.userName),
                    const SizedBox(height: AppSpacing.xl),
                    BalanceHeroCard(
                      totalBalance: CurrencyFormatter.rupiah(
                        data.totalBalance,
                        hidden: hideBalance,
                      ),
                      walletInfo: '${data.walletCount} dompet',
                      monthlyStatus: data.netCashflow >= 0
                          ? 'Positif'
                          : 'Perlu dicek',
                      hideBalance: hideBalance,
                      onToggleVisibility: () {
                        ref
                            .read(settingsRepositoryProvider)
                            .setHideBalance(!hideBalance);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const SectionHeader(
                      title: 'Ringkasan bulan ini',
                      subtitle: 'Bulan berjalan',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _MonthlySnapshotCard(
                      summary: data,
                      hideBalance: hideBalance,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    InsightCard(
                      title: _insightTitle(data),
                      message: _insightMessage(data),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const SectionHeader(
                      title: 'Riwayat terbaru',
                      subtitle: 'Transaksi terakhir akan muncul di sini',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _RecentTransactionsCard(
                      transactions: data.recentTransactions,
                      hideBalance: hideBalance,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: Text('Memuat ringkasan')),
      error: (_, _) => const Center(child: Text('Ringkasan belum bisa dimuat')),
    );
  }

  String _insightTitle(DashboardSummary summary) {
    if (summary.recentTransactions.isEmpty) {
      return 'Ringkasan belum tersedia';
    }
    if (summary.budgetLimit > 0 && summary.budgetRatio >= 1) {
      return 'Budget terlampaui';
    }
    if (summary.topExpenseCategory != null) {
      return 'Pengeluaran terbesar: ${summary.topExpenseCategory}';
    }
    return 'Keuangan bulan ini tercatat';
  }

  String _insightMessage(DashboardSummary summary) {
    if (summary.recentTransactions.isEmpty) {
      return 'Tambahkan transaksi pertama untuk mulai melihat ringkasan keuanganmu.';
    }
    if (summary.budgetLimit > 0) {
      final percent = (summary.budgetRatio * 100).round();
      return 'Budget bulan ini sudah terpakai $percent%.';
    }
    if (summary.netCashflow >= 0) {
      return 'Pemasukan bulan ini lebih besar atau sama dengan pengeluaran.';
    }
    return 'Pengeluaran bulan ini lebih besar dari pemasukan.';
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final greeting = userName == null || userName!.trim().isEmpty
        ? 'Halo'
        : 'Halo, ${userName!.trim()}';

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
              Text(greeting, style: theme.textTheme.displayMedium),
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
  const _MonthlySnapshotCard({
    required this.summary,
    required this.hideBalance,
  });

  final DashboardSummary summary;
  final bool hideBalance;

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
              Expanded(
                child: _FlowAmount(
                  label: 'Masuk',
                  value: CurrencyFormatter.rupiah(
                    summary.monthlyIncome,
                    hidden: hideBalance,
                  ),
                  caption: summary.monthlyIncome == 0
                      ? 'Belum ada pemasukan'
                      : DateFormatter.monthLabel(DateTime.now()),
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
              Expanded(
                child: _FlowAmount(
                  label: 'Keluar',
                  value: CurrencyFormatter.rupiah(
                    summary.monthlyExpense,
                    hidden: hideBalance,
                  ),
                  caption: summary.monthlyExpense == 0
                      ? 'Belum ada pengeluaran'
                      : DateFormatter.monthLabel(DateTime.now()),
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
                  value: CurrencyFormatter.rupiah(
                    summary.netCashflow,
                    hidden: hideBalance,
                  ),
                  helper: 'Pemasukan dikurangi pengeluaran',
                  accentColor: AppColors.infoBlue,
                ),
                const SizedBox(height: AppSpacing.md),
                _MiniStatusRow(
                  label: 'Anggaran',
                  value: summary.budgetLimit == 0
                      ? 'Belum ada'
                      : '${(summary.budgetRatio * 100).round()}%',
                  helper: 'Terpakai bulan ini',
                  accentColor: AppColors.warningOrange,
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
  });

  final String label;
  final String value;
  final String helper;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
  const _RecentTransactionsCard({
    required this.transactions,
    required this.hideBalance,
  });

  final List<TransactionDetail> transactions;
  final bool hideBalance;

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
      child: transactions.isEmpty
          ? const EmptyState(
              compact: true,
              icon: Icons.receipt_long_rounded,
              title: 'Belum ada transaksi',
              message:
                  'Tambahkan transaksi pertama untuk mulai melihat riwayat keuanganmu.',
            )
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  for (var index = 0; index < transactions.length; index++) ...[
                    _tile(transactions[index], hideBalance),
                    if (index != transactions.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
    );
  }
}

TransactionTile _tile(TransactionDetail detail, bool hideBalance) {
  final transaction = detail.transaction;
  final type = _previewType(detail.type);
  final title = detail.type == TransactionType.transfer
      ? '${detail.wallet.name} ke ${detail.transferWallet?.name ?? 'Dompet'}'
      : detail.category?.name ?? 'Transaksi';
  final subtitle = detail.type == TransactionType.transfer
      ? 'Transfer antar dompet'
      : detail.wallet.name;

  return TransactionTile(
    title: title,
    subtitle: subtitle,
    timeLabel: DateFormatter.dateTimeLabel(transaction.date),
    amount: CurrencyFormatter.rupiah(transaction.amount, hidden: hideBalance),
    type: type,
    icon: _transactionIcon(detail),
  );
}

TransactionPreviewType _previewType(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return TransactionPreviewType.income;
    case TransactionType.expense:
      return TransactionPreviewType.expense;
    case TransactionType.transfer:
      return TransactionPreviewType.transfer;
  }
}

IconData _transactionIcon(TransactionDetail detail) {
  if (detail.type == TransactionType.transfer) {
    return Icons.swap_horiz_rounded;
  }
  final name = detail.category?.name.toLowerCase() ?? '';
  if (name.contains('makan') || name.contains('minuman')) {
    return Icons.restaurant_rounded;
  }
  if (name.contains('transport') || name.contains('bahan bakar')) {
    return Icons.directions_car_rounded;
  }
  if (detail.type == TransactionType.income) {
    return Icons.work_rounded;
  }
  return Icons.category_rounded;
}
