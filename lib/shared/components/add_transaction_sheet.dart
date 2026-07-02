import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/enums/transaction_type.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/app_models.dart';
import 'amount_display.dart';
import 'amount_keypad.dart';
import 'category_choice_chip.dart';
import 'category_group_section.dart';
import 'date_choice_chip.dart';
import 'transaction_type_segmented_control.dart';
import 'wallet_choice_chip.dart';

enum _NoticeTone { info, warning }

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key, this.transaction});

  final TransactionDetail? transaction;

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final TextEditingController _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _amountDigits = '';
  int? _selectedCategoryId;
  int? _selectedWalletId;
  int? _fromWalletId;
  int? _toWalletId;
  DateTime _selectedDate = DateTime.now();
  String _dateLabel = 'Hari ini';
  String? _noticeMessage;
  _NoticeTone _noticeTone = _NoticeTone.info;
  bool _saving = false;

  int get _amount => int.tryParse(_amountDigits) ?? 0;

  Color get _accentColor {
    switch (_type) {
      case TransactionType.expense:
        return AppColors.expenseRed;
      case TransactionType.income:
        return AppColors.incomeGreen;
      case TransactionType.transfer:
        return AppColors.infoBlue;
    }
  }

  String get _amountHelper {
    switch (_type) {
      case TransactionType.expense:
        return 'Uang keluar dari dompet pilihan.';
      case TransactionType.income:
        return 'Uang masuk ke dompet pilihan.';
      case TransactionType.transfer:
        return 'Pindahkan saldo tanpa dihitung sebagai pemasukan.';
    }
  }

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _type = transaction.type;
      _amountDigits = transaction.transaction.amount.toString();
      _selectedCategoryId = transaction.transaction.categoryId;
      _selectedWalletId = transaction.transaction.walletId;
      _fromWalletId = transaction.transaction.walletId;
      _toWalletId = transaction.transaction.transferWalletId;
      _selectedDate = transaction.transaction.date;
      _dateLabel = 'Pilih tanggal';
      _noteController.text = transaction.transaction.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectType(int index, List<CategoryEntry> categories) {
    setState(() {
      _type = TransactionType.values[index];
      _noticeMessage = null;
      if (_type != TransactionType.transfer) {
        _selectedCategoryId = _firstCategory(categories)?.id;
      }
    });
  }

  void _appendDigit(String value) {
    setState(() {
      final next = (_amountDigits + value).replaceFirst(RegExp(r'^0+'), '');
      _amountDigits = next.length > 12 ? next.substring(0, 12) : next;
      _noticeMessage = null;
    });
  }

  void _backspace() {
    if (_amountDigits.isEmpty) return;

    setState(() {
      _amountDigits = _amountDigits.substring(0, _amountDigits.length - 1);
      _noticeMessage = null;
    });
  }

  Future<void> _selectDate(String label) async {
    if (label == 'Pilih tanggal') {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked == null) return;
      setState(() {
        _selectedDate = picked;
        _dateLabel = label;
        _noticeMessage = null;
      });
      return;
    }

    final now = DateTime.now();
    setState(() {
      _selectedDate = label == 'Kemarin'
          ? now.subtract(const Duration(days: 1))
          : now;
      _dateLabel = label;
      _noticeMessage = null;
    });
  }

  Future<void> _submit(List<WalletBalance> wallets) async {
    if (_amount <= 0) {
      _showNotice('Masukkan nominal terlebih dahulu.', _NoticeTone.warning);
      return;
    }

    final walletId = _type == TransactionType.transfer
        ? _fromWalletId
        : _selectedWalletId;
    if (walletId == null) {
      _showNotice('Pilih dompet terlebih dahulu.', _NoticeTone.warning);
      return;
    }

    if (_type != TransactionType.transfer && _selectedCategoryId == null) {
      _showNotice('Pilih kategori terlebih dahulu.', _NoticeTone.warning);
      return;
    }

    if (_type == TransactionType.transfer) {
      if (_toWalletId == null) {
        _showNotice(
          'Pilih dompet tujuan terlebih dahulu.',
          _NoticeTone.warning,
        );
        return;
      }
      if (_toWalletId == walletId) {
        _showNotice('Pilih dompet tujuan yang berbeda.', _NoticeTone.warning);
        return;
      }
    }

    setState(() => _saving = true);

    try {
      await ref
          .read(transactionRepositoryProvider)
          .save(
            id: widget.transaction?.transaction.id,
            type: _type,
            amount: _amount,
            categoryId: _selectedCategoryId,
            walletId: walletId,
            transferWalletId: _toWalletId,
            date: _selectedDate,
            note: _noteController.text,
          );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan.')),
      );
    } on ArgumentError catch (error) {
      _showNotice(error.message.toString(), _NoticeTone.warning);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showNotice(String message, _NoticeTone tone) {
    setState(() {
      _noticeMessage = message;
      _noticeTone = tone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletBalancesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return walletsAsync.when(
      data: (wallets) => categoriesAsync.when(
        data: (categories) => _buildSheet(context, wallets, categories),
        loading: () => const _SheetLoading(),
        error: (_, _) =>
            const _SheetLoading(message: 'Kategori belum bisa dimuat'),
      ),
      loading: () => const _SheetLoading(),
      error: (_, _) => const _SheetLoading(message: 'Dompet belum bisa dimuat'),
    );
  }

  Widget _buildSheet(
    BuildContext context,
    List<WalletBalance> wallets,
    List<CategoryEntry> categories,
  ) {
    _ensureDefaults(wallets, categories);

    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final visibleCategories = _visibleCategories(categories);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.94,
        alignment: Alignment.bottomCenter,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: kIsWeb ? AppSpacing.webMaxWidth : double.infinity,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: AppRadius.sheet,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.borderSubtle,
                ),
                boxShadow: AppShadows.nav(brightness),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _SheetHeader(onClose: () => Navigator.pop(context)),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.md,
                          AppSpacing.screen,
                          AppSpacing.xl,
                        ),
                        children: [
                          TransactionTypeSegmentedControl(
                            labels: TransactionType.values
                                .map((type) => type.label)
                                .toList(),
                            selectedIndex: _type.index,
                            accentColor: _accentColor,
                            onChanged: (index) =>
                                _selectType(index, categories),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AmountDisplay(
                            label: 'Nominal',
                            amount: CurrencyFormatter.rupiah(_amount),
                            helper: _amountHelper,
                            accentColor: _accentColor,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AmountKeypad(
                            accentColor: _accentColor,
                            onDigitPressed: _appendDigit,
                            onBackspacePressed: _backspace,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          if (_type == TransactionType.transfer)
                            _TransferFields(
                              wallets: wallets,
                              fromWalletId: _fromWalletId,
                              toWalletId: _toWalletId,
                              onFromSelected: (id) {
                                setState(() {
                                  _fromWalletId = id;
                                  if (_toWalletId == id) {
                                    _toWalletId = wallets
                                        .map((item) => item.wallet.id)
                                        .firstWhere((item) => item != id);
                                  }
                                  _noticeMessage = null;
                                });
                              },
                              onToSelected: (id) {
                                setState(() {
                                  _toWalletId = id;
                                  if (_fromWalletId == id) {
                                    _fromWalletId = wallets
                                        .map((item) => item.wallet.id)
                                        .firstWhere((item) => item != id);
                                  }
                                  _noticeMessage = null;
                                });
                              },
                            )
                          else
                            _CategoryPicker(
                              categories: visibleCategories,
                              selectedCategoryId: _selectedCategoryId,
                              fallbackAccent: _accentColor,
                              onSelected: (category) {
                                setState(() {
                                  _selectedCategoryId = category.id;
                                  _noticeMessage = null;
                                });
                              },
                            ),
                          if (_type != TransactionType.transfer) ...[
                            const SizedBox(height: AppSpacing.xxxl),
                            _WalletPicker(
                              wallets: wallets,
                              selectedWalletId: _selectedWalletId,
                              onSelected: (id) {
                                setState(() {
                                  _selectedWalletId = id;
                                  _noticeMessage = null;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxxl),
                          _DatePicker(
                            selectedDate: _dateLabel,
                            onSelected: _selectDate,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          _NoteField(controller: _noteController),
                        ],
                      ),
                    ),
                    _SheetFooter(
                      noticeMessage: _noticeMessage,
                      noticeTone: _noticeTone,
                      saving: _saving,
                      onSubmit: () => _submit(wallets),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _ensureDefaults(
    List<WalletBalance> wallets,
    List<CategoryEntry> categories,
  ) {
    if (wallets.isNotEmpty) {
      _selectedWalletId ??= wallets.first.wallet.id;
      _fromWalletId ??= wallets.first.wallet.id;
      if (wallets.length > 1) {
        _toWalletId ??= wallets[1].wallet.id;
      } else {
        _toWalletId ??= wallets.first.wallet.id;
      }
    }

    if (_type != TransactionType.transfer) {
      _selectedCategoryId ??= _firstCategory(categories)?.id;
    }
  }

  List<CategoryEntry> _visibleCategories(List<CategoryEntry> categories) {
    return categories
        .where(
          (category) => category.type == _type.value || category.type == 'both',
        )
        .toList();
  }

  CategoryEntry? _firstCategory(List<CategoryEntry> categories) {
    final visible = _visibleCategories(categories);
    if (visible.isEmpty) return null;
    final frequent = _frequentLabels(_type);
    return visible.firstWhere(
      (category) => frequent.contains(category.name),
      orElse: () => visible.first,
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Container(
            width: AppSpacing.huge,
            height: AppSpacing.xs,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Transaksi',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Catat uang masuk, keluar, atau transfer dengan cepat.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: AppSpacing.iconTileSmall,
                  height: AppSpacing.iconTileSmall,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceSoft
                        : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: AppSpacing.xl,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selectedCategoryId,
    required this.fallbackAccent,
    required this.onSelected,
  });

  final List<CategoryEntry> categories;
  final int? selectedCategoryId;
  final Color fallbackAccent;
  final ValueChanged<CategoryEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    final frequent = [
      for (final name in _frequentLabels(
        categories.isNotEmpty &&
                categories.first.type == TransactionType.income.value
            ? TransactionType.income
            : TransactionType.expense,
      ))
        if (categories.any((category) => category.name == name))
          categories.firstWhere((category) => category.name == name),
    ];
    final grouped = <String, List<CategoryEntry>>{};
    for (final category in categories) {
      grouped.putIfAbsent(category.groupName, () => []).add(category);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetSectionTitle(
          title: 'Pilih kategori',
          subtitle: 'Mulai dari yang sering dipakai.',
        ),
        const SizedBox(height: AppSpacing.lg),
        if (frequent.isNotEmpty)
          CategoryGroupSection(
            title: 'Sering dipakai',
            children: [
              for (final item in frequent)
                CategoryChoiceChip(
                  label: item.name,
                  icon: _categoryIcon(item.iconKey),
                  selected: selectedCategoryId == item.id,
                  accentColor: fallbackAccent,
                  onSelected: () => onSelected(item),
                ),
            ],
          ),
        for (final entry in grouped.entries) ...[
          const SizedBox(height: AppSpacing.xl),
          CategoryGroupSection(
            title: entry.key,
            children: [
              for (final item in entry.value)
                CategoryChoiceChip(
                  label: item.name,
                  icon: _categoryIcon(item.iconKey),
                  selected: selectedCategoryId == item.id,
                  accentColor: Color(item.colorValue),
                  onSelected: () => onSelected(item),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _WalletPicker extends StatelessWidget {
  const _WalletPicker({
    required this.wallets,
    required this.selectedWalletId,
    required this.onSelected,
  });

  final List<WalletBalance> wallets;
  final int? selectedWalletId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetSectionTitle(
          title: 'Pilih dompet',
          subtitle: 'Saldo akan masuk atau keluar dari dompet ini.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _WalletChipRow(
          wallets: wallets,
          selectedWalletId: selectedWalletId,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _TransferFields extends StatelessWidget {
  const _TransferFields({
    required this.wallets,
    required this.fromWalletId,
    required this.toWalletId,
    required this.onFromSelected,
    required this.onToSelected,
  });

  final List<WalletBalance> wallets;
  final int? fromWalletId;
  final int? toWalletId;
  final ValueChanged<int> onFromSelected;
  final ValueChanged<int> onToSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetSectionTitle(
          title: 'Transfer dompet',
          subtitle: 'Pilih sumber dan tujuan saldo.',
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Dari', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.md),
        _WalletChipRow(
          wallets: wallets,
          selectedWalletId: fromWalletId,
          onSelected: onFromSelected,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Ke', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.md),
        _WalletChipRow(
          wallets: wallets,
          selectedWalletId: toWalletId,
          onSelected: onToSelected,
        ),
      ],
    );
  }
}

class _WalletChipRow extends StatelessWidget {
  const _WalletChipRow({
    required this.wallets,
    required this.selectedWalletId,
    required this.onSelected,
  });

  final List<WalletBalance> wallets;
  final int? selectedWalletId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          for (var index = 0; index < wallets.length; index++) ...[
            WalletChoiceChip(
              label: wallets[index].wallet.name,
              icon: _walletIcon(wallets[index].wallet.type),
              selected: selectedWalletId == wallets[index].wallet.id,
              onSelected: () => onSelected(wallets[index].wallet.id),
            ),
            if (index != wallets.length - 1)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.selectedDate, required this.onSelected});

  final String selectedDate;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const dateOptions = ['Hari ini', 'Kemarin', 'Pilih tanggal'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetSectionTitle(
          title: 'Tanggal',
          subtitle: 'Pilih waktu transaksi.',
        ),
        const SizedBox(height: AppSpacing.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.hardEdge,
          child: Row(
            children: [
              for (var index = 0; index < dateOptions.length; index++) ...[
                DateChoiceChip(
                  label: dateOptions[index],
                  selected: selectedDate == dateOptions[index],
                  onSelected: () => onSelected(dateOptions[index]),
                ),
                if (index != dateOptions.length - 1)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetSectionTitle(
          title: 'Catatan opsional',
          subtitle: 'Lewati jika belum perlu.',
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 3,
          maxLength: 120,
          cursorColor: theme.colorScheme.primary,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Tambahkan keterangan singkat jika perlu.',
            hintStyle: theme.textTheme.bodyMedium,
            filled: true,
            fillColor: isDark
                ? AppColors.darkSurfaceSoft
                : AppColors.surfaceSoft,
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkBorderSubtle
                    : AppColors.borderSubtle,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.46),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetFooter extends StatelessWidget {
  const _SheetFooter({
    required this.noticeMessage,
    required this.noticeTone,
    required this.saving,
    required this.onSubmit,
  });

  final String? noticeMessage;
  final _NoticeTone noticeTone;
  final bool saving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (noticeMessage != null) ...[
            _InlineNotice(message: noticeMessage!, tone: noticeTone),
            const SizedBox(height: AppSpacing.md),
          ],
          GestureDetector(
            onTap: saving ? null : onSubmit,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: AppDurations.normal,
              curve: AppDurations.easeOut,
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: AppSpacing.huge + AppSpacing.lg,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? AppColors.softMint : AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.softMint : AppColors.primary)
                        .withValues(alpha: isDark ? 0.18 : 0.14),
                    blurRadius: AppSpacing.xxl,
                    offset: const Offset(0, AppSpacing.md),
                  ),
                ],
              ),
              child: Text(
                saving ? 'Menyimpan...' : 'Simpan Transaksi',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isDark ? AppColors.darkBackground : AppColors.onDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, required this.tone});

  final String message;
  final _NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final color = tone == _NoticeTone.warning
        ? AppColors.warningOrange
        : AppColors.infoBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}

class _SheetSectionTitle extends StatelessWidget {
  const _SheetSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _SheetLoading extends StatelessWidget {
  const _SheetLoading({this.message = 'Menyiapkan data lokal'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.sheet,
      ),
      child: Text(message),
    );
  }
}

List<String> _frequentLabels(TransactionType type) {
  switch (type) {
    case TransactionType.expense:
      return [
        'Makanan',
        'Transportasi',
        'Belanja Harian',
        'Tagihan',
        'Langganan Aplikasi',
        'Lainnya',
      ];
    case TransactionType.income:
      return ['Gaji', 'Jasa', 'Project', 'Uang Saku', 'Cashback', 'Lainnya'];
    case TransactionType.transfer:
      return const [];
  }
}

IconData _categoryIcon(String key) {
  switch (key) {
    case 'food':
      return Icons.restaurant_rounded;
    case 'transport':
      return Icons.directions_car_rounded;
    case 'income':
      return Icons.work_rounded;
    case 'bill':
      return Icons.receipt_long_rounded;
    case 'savings':
      return Icons.savings_rounded;
    default:
      return Icons.category_rounded;
  }
}

IconData _walletIcon(String type) {
  switch (type) {
    case 'ewallet':
      return Icons.account_balance_wallet_rounded;
    case 'bank':
      return Icons.account_balance_rounded;
    case 'savings':
      return Icons.savings_rounded;
    default:
      return Icons.payments_rounded;
  }
}
