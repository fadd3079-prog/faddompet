import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/period_selector.dart';
import 'widgets/transaction_filter_chips.dart';
import 'widgets/transaction_list_section.dart';
import 'widgets/transaction_search_bar.dart';
import 'widgets/transaction_tile.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  static const _filterLabels = [
    'Semua',
    'Pemasukan',
    'Pengeluaran',
    'Transfer',
  ];
  static const _periodLabels = ['Bulan ini', 'Minggu ini', 'Hari ini'];

  int _selectedFilterIndex = 0;
  int _selectedPeriodIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sections = _previewSections();

    if (sections.isEmpty) {
      return const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.contentBottomInset),
          child: EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'Belum ada transaksi',
            message:
                'Tambahkan transaksi pertama untuk mulai melihat riwayat keuanganmu.',
          ),
        ),
      );
    }

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
                  for (var index = 0; index < sections.length; index++) ...[
                    TransactionListSection(
                      title: sections[index].title,
                      transactions: sections[index].transactions,
                    ),
                    if (index != sections.length - 1)
                      const SizedBox(height: AppSpacing.xxxl),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_TransactionPreviewSection> _previewSections() {
    return const [
      _TransactionPreviewSection(
        title: 'Hari ini',
        transactions: [
          TransactionTile(
            title: 'Makanan',
            subtitle: 'Tunai',
            timeLabel: 'Hari ini, 09.15',
            amount: 'Rp25.000',
            type: TransactionPreviewType.expense,
            icon: Icons.restaurant_rounded,
          ),
          TransactionTile(
            title: 'Transportasi',
            subtitle: 'E-Wallet',
            timeLabel: 'Hari ini, 08.05',
            amount: 'Rp12.000',
            type: TransactionPreviewType.expense,
            icon: Icons.directions_car_rounded,
          ),
        ],
      ),
      _TransactionPreviewSection(
        title: 'Kemarin',
        transactions: [
          TransactionTile(
            title: 'Gaji',
            subtitle: 'Rekening',
            timeLabel: 'Kemarin, 17.30',
            amount: 'Rp2.500.000',
            type: TransactionPreviewType.income,
            icon: Icons.work_rounded,
          ),
          TransactionTile(
            title: 'E-Wallet ke Rekening',
            subtitle: 'Transfer antar dompet',
            timeLabel: 'Kemarin, 14.10',
            amount: 'Rp100.000',
            type: TransactionPreviewType.transfer,
            icon: Icons.swap_horiz_rounded,
          ),
        ],
      ),
      _TransactionPreviewSection(
        title: 'Minggu ini',
        transactions: [
          TransactionTile(
            title: 'Langganan Aplikasi',
            subtitle: 'Rekening',
            timeLabel: 'Senin, 19.40',
            amount: 'Rp89.000',
            type: TransactionPreviewType.expense,
            icon: Icons.apps_rounded,
          ),
        ],
      ),
    ];
  }
}

class _TransactionPreviewSection {
  const _TransactionPreviewSection({
    required this.title,
    required this.transactions,
  });

  final String title;
  final List<TransactionTile> transactions;
}

class _SearchFilterSurface extends StatelessWidget {
  const _SearchFilterSurface({
    required this.selectedFilterIndex,
    required this.filterLabels,
    required this.onFilterChanged,
  });

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
          const TransactionSearchBar(),
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
