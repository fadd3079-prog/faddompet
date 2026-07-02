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
import '../../shared/components/add_transaction_sheet.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../shared/widgets/app_form_actions.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/top_toast.dart';
import 'widgets/period_selector.dart';
import 'widgets/transaction_filter_chips.dart';
import 'widgets/transaction_list_section.dart';
import 'widgets/transaction_search_bar.dart';
import 'widgets/transaction_tile.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  static const _filterLabels = [
    'Semua',
    'Pemasukan',
    'Pengeluaran',
    'Transfer',
  ];
  static const _periodLabels = ['Bulan ini', 'Minggu ini', 'Hari ini'];

  final TextEditingController _searchController = TextEditingController();

  int _selectedFilterIndex = 0;
  int _selectedPeriodIndex = 0;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionDetailsProvider);
    final settings = ref
        .watch(appSettingsProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final hideBalance = settings?.hideBalance ?? false;

    return transactions.when(
      data: (items) {
        final filtered = _filtered(items);
        final groups = _grouped(filtered);

        return SafeArea(
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
                      Text(
                        'Transaksi',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Lihat pemasukan, pengeluaran, dan transfer yang sudah kamu catat.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _SearchFilterSurface(
                        searchController: _searchController,
                        onSearchChanged: (value) {
                          setState(() => _query = value);
                        },
                        selectedFilterIndex: _selectedFilterIndex,
                        filterLabels: _filterLabels,
                        onFilterChanged: (index) {
                          setState(() => _selectedFilterIndex = index);
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PeriodSelector(
                        labels: _periodLabels,
                        selectedIndex: _selectedPeriodIndex,
                        onChanged: (index) {
                          setState(() => _selectedPeriodIndex = index);
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      if (groups.isEmpty)
                        const EmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'Belum ada transaksi',
                          message:
                              'Tambahkan transaksi pertama untuk mulai melihat riwayat keuanganmu.',
                        )
                      else
                        for (var index = 0; index < groups.length; index++) ...[
                          TransactionListSection(
                            title: groups.keys.elementAt(index),
                            transactions: [
                              for (final item in groups.values.elementAt(index))
                                _tile(item, hideBalance),
                            ],
                          ),
                          if (index != groups.length - 1)
                            const SizedBox(height: AppSpacing.xxxl),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: Text('Memuat transaksi')),
      error: (_, _) => const Center(child: Text('Transaksi belum bisa dimuat')),
    );
  }

  List<TransactionDetail> _filtered(List<TransactionDetail> items) {
    final start = _periodStart();
    final type = switch (_selectedFilterIndex) {
      1 => TransactionType.income,
      2 => TransactionType.expense,
      3 => TransactionType.transfer,
      _ => null,
    };
    final query = _query.trim().toLowerCase();

    return items.where((item) {
      if (item.transaction.date.isBefore(start)) return false;
      if (type != null && item.type != type) return false;
      if (query.isEmpty) return true;

      final haystack = [
        item.category?.name,
        item.wallet.name,
        item.transferWallet?.name,
        item.transaction.note,
      ].whereType<String>().join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }

  DateTime _periodStart() {
    final now = DateTime.now();
    switch (_selectedPeriodIndex) {
      case 1:
        return DateFormatter.startOfWeek(now);
      case 2:
        return DateFormatter.startOfDay(now);
      default:
        return DateFormatter.startOfMonth(now);
    }
  }

  Map<String, List<TransactionDetail>> _grouped(List<TransactionDetail> items) {
    final groups = <String, List<TransactionDetail>>{};
    for (final item in items) {
      groups
          .putIfAbsent(DateFormatter.dayLabel(item.transaction.date), () => [])
          .add(item);
    }
    return groups;
  }

  TransactionTile _tile(TransactionDetail detail, bool hideBalance) {
    final title = detail.type == TransactionType.transfer
        ? '${detail.wallet.name} ke ${detail.transferWallet?.name ?? 'Dompet'}'
        : detail.category?.name ?? 'Transaksi';
    final subtitle = detail.type == TransactionType.transfer
        ? 'Transfer antar dompet'
        : detail.wallet.name;

    return TransactionTile(
      title: title,
      subtitle: subtitle,
      timeLabel: DateFormatter.dateTimeLabel(detail.transaction.date),
      amount: CurrencyFormatter.rupiah(
        detail.transaction.amount,
        hidden: hideBalance,
      ),
      type: _previewType(detail.type),
      icon: _transactionIcon(detail),
      onTap: () => _showDetail(detail, hideBalance),
      onLongPress: () => _confirmDelete(detail),
    );
  }

  void _showDetail(TransactionDetail detail, bool hideBalance) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final title = detail.type == TransactionType.transfer
            ? '${detail.wallet.name} ke ${detail.transferWallet?.name ?? 'Dompet'}'
            : detail.category?.name ?? 'Transaksi';
        final walletLabel = detail.type == TransactionType.transfer
            ? 'Dari ${detail.wallet.name} ke ${detail.transferWallet?.name ?? 'Dompet'}'
            : detail.wallet.name;
        final typeLabel = switch (detail.type) {
          TransactionType.income => 'Pemasukan',
          TransactionType.expense => 'Pengeluaran',
          TransactionType.transfer => 'Transfer',
        };

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(typeLabel, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  CurrencyFormatter.rupiah(
                    detail.transaction.amount,
                    hidden: hideBalance,
                  ),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: _amountColor(detail.type),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _DetailRow(
                  label: 'Tanggal',
                  value: DateFormatter.dateTimeLabel(detail.transaction.date),
                ),
                _DetailRow(label: 'Dompet', value: walletLabel),
                if (detail.category != null)
                  _DetailRow(label: 'Kategori', value: detail.category!.name),
                _DetailRow(
                  label: 'Catatan',
                  value: detail.transaction.note?.trim().isNotEmpty ?? false
                      ? detail.transaction.note!
                      : 'Tidak ada catatan',
                ),
                const SizedBox(height: AppSpacing.xl),
                AppFormActions(
                  secondaryLabel: 'Edit',
                  primaryLabel: 'Hapus',
                  danger: true,
                  onSecondaryPressed: () {
                    Navigator.pop(sheetContext);
                    _edit(detail);
                  },
                  onPrimaryPressed: () {
                    Navigator.pop(sheetContext);
                    _confirmDelete(detail);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _edit(TransactionDetail detail) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (context) => AddTransactionSheet(transaction: detail),
    );
  }

  Future<void> _confirmDelete(TransactionDetail detail) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Hapus transaksi?',
      message: 'Transaksi yang dihapus tidak bisa dikembalikan.',
      confirmLabel: 'Hapus',
      danger: true,
    );

    if (!confirmed) return;

    await ref.read(transactionRepositoryProvider).delete(detail.transaction.id);
    if (!mounted) return;
    TopToast.show(
      context,
      'Transaksi berhasil dihapus.',
      type: TopToastType.success,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

Color _amountColor(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return AppColors.incomeGreen;
    case TransactionType.expense:
      return AppColors.expenseRed;
    case TransactionType.transfer:
      return AppColors.infoBlue;
  }
}

class _SearchFilterSurface extends StatelessWidget {
  const _SearchFilterSurface({
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedFilterIndex,
    required this.filterLabels,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final int selectedFilterIndex;
  final List<String> filterLabels;
  final ValueChanged<int> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransactionSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          TransactionFilterChips(
            labels: filterLabels,
            selectedIndex: selectedFilterIndex,
            onChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
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
