import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/enums/budget_status.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/app_models.dart';
import '../../shared/widgets/empty_state.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsSummaryProvider);
    final budgets = ref.watch(budgetProgressProvider);
    final categories = ref
        .watch(categoriesProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <CategoryEntry>[],
        );

    return SafeArea(
      bottom: false,
      child: analytics.when(
        data: (summary) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xl,
            AppSpacing.screen,
            AppSpacing.contentBottomInset,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Analitik',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                IconButton.filled(
                  onPressed: () => _showBudgetDialog(context, ref, categories),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Lihat pola pemasukan, pengeluaran, dan budget bulan ini.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (summary.isEmpty)
              const EmptyState(
                icon: Icons.insights_rounded,
                title: 'Belum ada analitik',
                message:
                    'Tambahkan beberapa transaksi untuk melihat ringkasan pemasukan, pengeluaran, dan kategori.',
              )
            else ...[
              _ChartCard(
                title: 'Pengeluaran per kategori',
                child: _DonutChart(items: summary.expenseByCategory),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Arus kas harian',
                child: _LineChart(items: summary.dailyCashflow),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Pengeluaran mingguan',
                child: _BarChart(items: summary.weeklyExpense),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TopCategoryList(items: summary.topExpenses),
              const SizedBox(height: AppSpacing.xxl),
            ],
            budgets.when(
              data: (items) => _BudgetSection(items: items),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        loading: () => const Center(child: Text('Memuat analitik')),
        error: (_, _) =>
            const Center(child: Text('Analitik belum bisa dimuat')),
      ),
    );
  }

  Future<void> _showBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryEntry> categories,
  ) async {
    final result = await showDialog<_BudgetFormResult>(
      context: context,
      builder: (context) => _BudgetDialog(categories: categories),
    );
    if (result == null) return;

    await ref
        .read(budgetRepositoryProvider)
        .save(
          categoryId: result.categoryId,
          month: DateFormatter.monthKey(DateTime.now()),
          limitAmount: result.limitAmount,
        );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(height: 190, child: child),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.items});

  final List<CategoryAmount> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Belum ada pengeluaran'));
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 44,
              sectionsSpace: 2,
              sections: [
                for (final item in items.take(6))
                  PieChartSectionData(
                    value: item.amount.toDouble(),
                    title: '',
                    color: Color(item.colorValue),
                    radius: 42,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items.take(4)) ...[
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.items});

  final List<DailyCashflow> items;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var index = 0; index < items.length; index++)
        FlSpot(
          index.toDouble(),
          (items[index].income - items[index].expense).toDouble() / 1000,
        ),
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: const FlDotData(show: false),
            color: AppColors.primary,
            barWidth: 4,
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.items});

  final List<CategoryAmount> items;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var index = 0; index < items.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: items[index].amount.toDouble() / 1000,
                  width: 22,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  color: AppColors.expenseRed.withValues(alpha: 0.82),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TopCategoryList extends StatelessWidget {
  const _TopCategoryList({required this.items});

  final List<CategoryAmount> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top 5 pengeluaran', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            Text(
              'Belum ada pengeluaran bulan ini.',
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final item in items.take(5)) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(item.label, style: theme.textTheme.titleMedium),
                  ),
                  Text(
                    CurrencyFormatter.rupiah(item.amount),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}

class _BudgetSection extends StatelessWidget {
  const _BudgetSection({required this.items});

  final List<BudgetProgress> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        if (items.isEmpty)
          const EmptyState(
            compact: true,
            icon: Icons.savings_rounded,
            title: 'Belum ada budget',
            message:
                'Tambahkan budget untuk memantau batas pengeluaran bulan ini.',
          )
        else
          for (final item in items) ...[
            _BudgetCard(item: item),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.item});

  final BudgetProgress item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (item.status) {
      BudgetStatus.safe => AppColors.incomeGreen,
      BudgetStatus.nearLimit => AppColors.warningOrange,
      BudgetStatus.exceeded => AppColors.expenseRed,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.label, style: theme.textTheme.titleMedium),
              ),
              Text(
                item.status.label,
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: item.ratio,
              minHeight: AppSpacing.sm,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${CurrencyFormatter.rupiah(item.spent)} dari ${CurrencyFormatter.rupiah(item.budget.limitAmount)}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({required this.categories});

  final List<CategoryEntry> categories;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final TextEditingController _amountController = TextEditingController();
  int? _categoryId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = widget.categories
        .where(
          (category) => category.type == 'expense' || category.type == 'both',
        )
        .toList();

    return AlertDialog(
      title: const Text('Tambah budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int?>(
            initialValue: _categoryId,
            decoration: const InputDecoration(labelText: 'Cakupan'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Budget bulanan'),
              ),
              for (final category in expenseCategories)
                DropdownMenuItem<int?>(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Batas budget'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final amount = int.tryParse(_amountController.text) ?? 0;
            if (amount <= 0) return;
            Navigator.pop(
              context,
              _BudgetFormResult(categoryId: _categoryId, limitAmount: amount),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _BudgetFormResult {
  const _BudgetFormResult({
    required this.categoryId,
    required this.limitAmount,
  });

  final int? categoryId;
  final int limitAmount;
}
