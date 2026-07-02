import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/enums/budget_status.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/app_models.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../shared/widgets/app_form_actions.dart';
import '../../shared/widgets/app_icon_action_button.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/pressable_surface.dart';
import '../../shared/widgets/top_toast.dart';

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
                AppIconActionButton(
                  icon: Icons.add_rounded,
                  label: 'Tambah budget',
                  onPressed: () => _showBudgetDialog(context, ref, categories),
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
              data: (items) => _BudgetSection(
                items: items,
                onEdit: (item) =>
                    _showBudgetDialog(context, ref, categories, item),
                onDelete: (item) => _confirmDeleteBudget(context, ref, item),
                onReset: () => _confirmResetBudget(context, ref),
              ),
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
    List<CategoryEntry> categories, [
    BudgetProgress? existing,
  ]) async {
    final result = await showDialog<_BudgetFormResult>(
      context: context,
      builder: (context) =>
          _BudgetDialog(categories: categories, existing: existing),
    );
    if (result == null) return;

    try {
      await ref
          .read(budgetRepositoryProvider)
          .save(
            id: existing?.budget.id,
            categoryId: result.categoryId,
            month: DateFormatter.monthKey(DateTime.now()),
            limitAmount: result.limitAmount,
          );
      if (!context.mounted) return;
      TopToast.show(
        context,
        existing == null
            ? 'Budget berhasil disimpan.'
            : 'Budget berhasil diperbarui.',
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

  Future<void> _confirmDeleteBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetProgress item,
  ) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Hapus budget?',
      message: 'Budget yang dihapus tidak bisa dikembalikan.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!confirmed) return;
    await ref.read(budgetRepositoryProvider).delete(item.budget.id);
    if (!context.mounted) return;
    TopToast.show(
      context,
      'Budget berhasil dihapus.',
      type: TopToastType.success,
    );
  }

  Future<void> _confirmResetBudget(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Reset budget bulan ini?',
      message:
          'Semua budget untuk bulan ini akan dihapus. Transaksi tetap aman.',
      confirmLabel: 'Reset',
      danger: true,
    );
    if (!confirmed) return;
    await ref
        .read(budgetRepositoryProvider)
        .resetMonth(DateFormatter.monthKey(DateTime.now()));
    if (!context.mounted) return;
    TopToast.show(
      context,
      'Budget bulan ini direset.',
      type: TopToastType.success,
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
          SizedBox(height: 220, child: child),
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
      return const _ChartEmptyState('Belum ada pengeluaran bulan ini.');
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
    if (items.every((item) => item.income == 0 && item.expense == 0)) {
      return const _ChartEmptyState('Belum ada arus kas minggu ini.');
    }

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
        minY: _lineMinY(spots),
        maxY: _lineMaxY(spots),
        lineTouchData: const LineTouchData(enabled: false),
        clipData: const FlClipData.none(),
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

  double _lineMinY(List<FlSpot> spots) {
    final value = spots.fold<double>(0, (minY, spot) {
      return spot.y < minY ? spot.y : minY;
    });
    return value == 0 ? -1 : value * 1.18;
  }

  double _lineMaxY(List<FlSpot> spots) {
    final value = spots.fold<double>(0, (maxY, spot) {
      return spot.y > maxY ? spot.y : maxY;
    });
    return value == 0 ? 1 : value * 1.18;
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.items});

  final List<CategoryAmount> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final maxAmount = items.fold<int>(0, (current, item) {
      return item.amount > current ? item.amount : current;
    });

    if (maxAmount == 0) {
      return const _ChartEmptyState('Belum ada pengeluaran mingguan.');
    }

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: (maxAmount / 1000) * 1.24,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.6),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= items.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    items[index].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(AppRadius.md),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            getTooltipColor: (_) =>
                isDark ? AppColors.darkSurfaceElevated : AppColors.textPrimary,
            tooltipBorder: BorderSide(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.textPrimary.withValues(alpha: 0.08),
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = items[groupIndex];
              return BarTooltipItem(
                '${item.label}\n${CurrencyFormatter.rupiah(item.amount)}',
                theme.textTheme.labelLarge!.copyWith(
                  color: AppColors.onDark,
                  height: 1.35,
                ),
              );
            },
          ),
        ),
        barGroups: [
          for (var index = 0; index < items.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: items[index].amount.toDouble() / 1000,
                  width: 24,
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
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    CurrencyFormatter.rupiah(item.amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
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
  const _BudgetSection({
    required this.items,
    required this.onEdit,
    required this.onDelete,
    required this.onReset,
  });

  final List<BudgetProgress> items;
  final ValueChanged<BudgetProgress> onEdit;
  final ValueChanged<BudgetProgress> onDelete;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BudgetHeader(
          showReset: items.isNotEmpty,
          onReset: onReset,
          titleStyle: theme.textTheme.titleLarge,
        ),
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
            _BudgetCard(
              item: item,
              onTap: () => onEdit(item),
              onLongPress: () => onDelete(item),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final BudgetProgress item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (item.status) {
      BudgetStatus.safe => AppColors.incomeGreen,
      BudgetStatus.nearLimit => AppColors.warningOrange,
      BudgetStatus.exceeded => AppColors.expenseRed,
    };

    return PressableSurface(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
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
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item.status.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(color: color),
                    ),
                  ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({required this.categories, this.existing});

  final List<CategoryEntry> categories;
  final BudgetProgress? existing;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final TextEditingController _amountController;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.existing?.budget.categoryId;
    _amountController = TextEditingController(
      text: widget.existing == null
          ? ''
          : CurrencyFormatter.rupiah(widget.existing!.budget.limitAmount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = widget.categories
        .where(
          (category) =>
              !category.isArchived &&
              (category.type == 'expense' || category.type == 'both'),
        )
        .toList();
    final editing = widget.existing != null;

    return AlertDialog(
      title: Text(editing ? 'Edit budget' : 'Tambah budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: _categoryId,
            decoration: const InputDecoration(labelText: 'Cakupan'),
            onChanged: editing
                ? null
                : (value) => setState(() => _categoryId = value),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text(
                  'Budget bulanan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              for (final category in expenseCategories)
                DropdownMenuItem<int?>(
                  value: category.id,
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: const [RupiahInputFormatter()],
            decoration: const InputDecoration(
              labelText: 'Batas budget',
              hintText: 'Rp500.000',
              helperText: 'Masukkan batas pengeluaran bulan ini.',
            ),
          ),
        ],
      ),
      actions: [
        AppFormActions(
          secondaryLabel: 'Batal',
          primaryLabel: 'Simpan',
          onSecondaryPressed: () => Navigator.pop(context),
          onPrimaryPressed: () {
            final amount = CurrencyFormatter.parseRupiah(
              _amountController.text,
            );
            if (amount <= 0) return;
            Navigator.pop(
              context,
              _BudgetFormResult(categoryId: _categoryId, limitAmount: amount),
            );
          },
        ),
      ],
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({
    required this.showReset,
    required this.onReset,
    required this.titleStyle,
  });

  final bool showReset;
  final VoidCallback onReset;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      'Budget',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: titleStyle,
    );

    if (!showReset) {
      return SizedBox(width: double.infinity, child: title);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final resetButton = ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 96),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.expenseRed,
              side: const BorderSide(color: AppColors.expenseRed),
            ),
            onPressed: onReset,
            child: const Text(
              'Reset',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );

        if (constraints.maxWidth < 280) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: AppSpacing.md),
              Align(alignment: Alignment.centerRight, child: resetButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: AppSpacing.md),
            resetButton,
          ],
        );
      },
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
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
