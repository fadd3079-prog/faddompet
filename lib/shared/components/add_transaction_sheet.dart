import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import 'amount_display.dart';
import 'amount_keypad.dart';
import 'category_choice_chip.dart';
import 'category_group_section.dart';
import 'date_choice_chip.dart';
import 'transaction_type_segmented_control.dart';
import 'wallet_choice_chip.dart';

enum _AddTransactionType { expense, income, transfer }

enum _NoticeTone { info, warning }

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final TextEditingController _noteController = TextEditingController();

  _AddTransactionType _type = _AddTransactionType.expense;
  String _amountDigits = '';
  String _expenseCategory = 'Makanan';
  String _incomeCategory = 'Gaji';
  String _selectedWallet = 'Tunai';
  String _fromWallet = 'Tunai';
  String _toWallet = 'E-Wallet';
  String _selectedDate = 'Hari ini';
  String? _noticeMessage;
  _NoticeTone _noticeTone = _NoticeTone.info;

  int get _amount => int.tryParse(_amountDigits) ?? 0;

  Color get _accentColor {
    switch (_type) {
      case _AddTransactionType.expense:
        return AppColors.expenseRed;
      case _AddTransactionType.income:
        return AppColors.incomeGreen;
      case _AddTransactionType.transfer:
        return AppColors.infoBlue;
    }
  }

  String get _amountHelper {
    switch (_type) {
      case _AddTransactionType.expense:
        return 'Uang keluar dari dompet pilihan.';
      case _AddTransactionType.income:
        return 'Uang masuk ke dompet pilihan.';
      case _AddTransactionType.transfer:
        return 'Pindahkan saldo tanpa dihitung sebagai pemasukan.';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectType(int index) {
    setState(() {
      _type = _AddTransactionType.values[index];
      _noticeMessage = null;
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
    if (_amountDigits.isEmpty) {
      return;
    }

    setState(() {
      _amountDigits = _amountDigits.substring(0, _amountDigits.length - 1);
      _noticeMessage = null;
    });
  }

  void _selectCategory(String label) {
    setState(() {
      if (_type == _AddTransactionType.income) {
        _incomeCategory = label;
      } else {
        _expenseCategory = label;
      }
      _noticeMessage = null;
    });
  }

  void _selectFromWallet(String label) {
    setState(() {
      _fromWallet = label;
      if (_toWallet == label) {
        _toWallet = _walletOptions
            .firstWhere((wallet) => wallet.label != label)
            .label;
      }
    });
  }

  void _selectToWallet(String label) {
    setState(() {
      _toWallet = label;
      if (_fromWallet == label) {
        _fromWallet = _walletOptions
            .firstWhere((wallet) => wallet.label != label)
            .label;
      }
    });
  }

  void _submit() {
    setState(() {
      if (_amount <= 0) {
        _noticeTone = _NoticeTone.warning;
        _noticeMessage = 'Masukkan nominal terlebih dahulu.';
      } else {
        _noticeTone = _NoticeTone.info;
        _noticeMessage = 'Transaksi siap disimpan setelah data lokal aktif.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.94,
        alignment: Alignment.bottomCenter,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.webMaxWidth),
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
                            labels: const [
                              'Pengeluaran',
                              'Pemasukan',
                              'Transfer',
                            ],
                            selectedIndex: _type.index,
                            accentColor: _accentColor,
                            onChanged: _selectType,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AmountDisplay(
                            label: 'Nominal',
                            amount: _formatRupiah(_amount),
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
                          if (_type == _AddTransactionType.transfer)
                            _TransferFields(
                              fromWallet: _fromWallet,
                              toWallet: _toWallet,
                              onFromSelected: _selectFromWallet,
                              onToSelected: _selectToWallet,
                            )
                          else
                            _CategoryPicker(
                              groups: _type == _AddTransactionType.expense
                                  ? _expenseGroups
                                  : _incomeGroups,
                              frequent: _type == _AddTransactionType.expense
                                  ? _expenseFrequent
                                  : _incomeFrequent,
                              selectedCategory:
                                  _type == _AddTransactionType.expense
                                  ? _expenseCategory
                                  : _incomeCategory,
                              fallbackAccent: _accentColor,
                              onSelected: _selectCategory,
                            ),
                          if (_type != _AddTransactionType.transfer) ...[
                            const SizedBox(height: AppSpacing.xxxl),
                            _WalletPicker(
                              selectedWallet: _selectedWallet,
                              onSelected: (label) {
                                setState(() {
                                  _selectedWallet = label;
                                  _noticeMessage = null;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxxl),
                          _DatePicker(
                            selectedDate: _selectedDate,
                            onSelected: (label) {
                              setState(() {
                                _selectedDate = label;
                                _noticeMessage = null;
                              });
                            },
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          _NoteField(controller: _noteController),
                        ],
                      ),
                    ),
                    _SheetFooter(
                      noticeMessage: _noticeMessage,
                      noticeTone: _noticeTone,
                      onSubmit: _submit,
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
              Semantics(
                button: true,
                label: 'Tutup',
                child: GestureDetector(
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
    required this.groups,
    required this.frequent,
    required this.selectedCategory,
    required this.fallbackAccent,
    required this.onSelected,
  });

  final List<_CategoryGroup> groups;
  final List<_CategoryOption> frequent;
  final String selectedCategory;
  final Color fallbackAccent;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetSectionTitle(
          title: 'Pilih kategori',
          subtitle: 'Mulai dari yang sering dipakai.',
        ),
        const SizedBox(height: AppSpacing.lg),
        CategoryGroupSection(
          title: 'Sering dipakai',
          children: [
            for (final item in frequent)
              CategoryChoiceChip(
                label: item.label,
                icon: item.icon,
                selected: selectedCategory == item.label,
                accentColor: fallbackAccent,
                onSelected: () => onSelected(item.label),
              ),
          ],
        ),
        for (final group in groups) ...[
          const SizedBox(height: AppSpacing.xl),
          CategoryGroupSection(
            title: group.title,
            children: [
              for (final item in group.items)
                CategoryChoiceChip(
                  label: item.label,
                  icon: item.icon,
                  selected: selectedCategory == item.label,
                  accentColor: group.accentColor,
                  onSelected: () => onSelected(item.label),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _WalletPicker extends StatelessWidget {
  const _WalletPicker({required this.selectedWallet, required this.onSelected});

  final String selectedWallet;
  final ValueChanged<String> onSelected;

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
        _WalletChipRow(selectedWallet: selectedWallet, onSelected: onSelected),
      ],
    );
  }
}

class _TransferFields extends StatelessWidget {
  const _TransferFields({
    required this.fromWallet,
    required this.toWallet,
    required this.onFromSelected,
    required this.onToSelected,
  });

  final String fromWallet;
  final String toWallet;
  final ValueChanged<String> onFromSelected;
  final ValueChanged<String> onToSelected;

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
        _WalletChipRow(selectedWallet: fromWallet, onSelected: onFromSelected),
        const SizedBox(height: AppSpacing.xl),
        Text('Ke', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.md),
        _WalletChipRow(selectedWallet: toWallet, onSelected: onToSelected),
      ],
    );
  }
}

class _WalletChipRow extends StatelessWidget {
  const _WalletChipRow({
    required this.selectedWallet,
    required this.onSelected,
  });

  final String selectedWallet;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var index = 0; index < _walletOptions.length; index++) ...[
            WalletChoiceChip(
              label: _walletOptions[index].label,
              icon: _walletOptions[index].icon,
              selected: selectedWallet == _walletOptions[index].label,
              onSelected: () => onSelected(_walletOptions[index].label),
            ),
            if (index != _walletOptions.length - 1)
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
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (var index = 0; index < _dateOptions.length; index++) ...[
                DateChoiceChip(
                  label: _dateOptions[index],
                  selected: selectedDate == _dateOptions[index],
                  onSelected: () => onSelected(_dateOptions[index]),
                ),
                if (index != _dateOptions.length - 1)
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
    required this.onSubmit,
  });

  final String? noticeMessage;
  final _NoticeTone noticeTone;
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
          Semantics(
            button: true,
            label: 'Simpan Transaksi',
            child: GestureDetector(
              onTap: onSubmit,
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
                  'Simpan Transaksi',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? AppColors.darkBackground : AppColors.onDark,
                  ),
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

class _CategoryOption {
  const _CategoryOption(this.label, {this.icon});

  final String label;
  final IconData? icon;
}

class _CategoryGroup {
  const _CategoryGroup({
    required this.title,
    required this.accentColor,
    required this.items,
  });

  final String title;
  final Color accentColor;
  final List<_CategoryOption> items;
}

class _WalletOption {
  const _WalletOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

String _formatRupiah(int amount) {
  if (amount <= 0) {
    return 'Rp0';
  }

  final raw = amount.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < raw.length; index++) {
    if (index != 0 && (raw.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(raw[index]);
  }

  return 'Rp$buffer';
}

const _walletOptions = [
  _WalletOption('Tunai', Icons.payments_rounded),
  _WalletOption('E-Wallet', Icons.account_balance_wallet_rounded),
  _WalletOption('Rekening', Icons.account_balance_rounded),
  _WalletOption('Tabungan', Icons.savings_rounded),
];

const _dateOptions = ['Hari ini', 'Kemarin', 'Pilih tanggal'];

const _expenseFrequent = [
  _CategoryOption('Makanan', icon: Icons.restaurant_rounded),
  _CategoryOption('Transportasi', icon: Icons.directions_car_rounded),
  _CategoryOption('Belanja Harian', icon: Icons.shopping_bag_rounded),
  _CategoryOption('Tagihan', icon: Icons.receipt_long_rounded),
  _CategoryOption('Langganan Aplikasi', icon: Icons.apps_rounded),
  _CategoryOption('Lainnya', icon: Icons.more_horiz_rounded),
];

const _incomeFrequent = [
  _CategoryOption('Gaji', icon: Icons.work_rounded),
  _CategoryOption('Jasa', icon: Icons.handyman_rounded),
  _CategoryOption('Project', icon: Icons.assignment_rounded),
  _CategoryOption('Uang Saku', icon: Icons.wallet_rounded),
  _CategoryOption('Cashback', icon: Icons.redeem_rounded),
  _CategoryOption('Lainnya', icon: Icons.more_horiz_rounded),
];

const _expenseGroups = [
  _CategoryGroup(
    title: 'Kebutuhan Harian',
    accentColor: AppColors.expenseRed,
    items: [
      _CategoryOption('Makanan'),
      _CategoryOption('Minuman'),
      _CategoryOption('Belanja Harian'),
      _CategoryOption('Transportasi'),
      _CategoryOption('Bahan Bakar'),
      _CategoryOption('Parkir'),
      _CategoryOption('Pulsa & Internet'),
      _CategoryOption('Laundry'),
      _CategoryOption('Kebutuhan Rumah'),
    ],
  ),
  _CategoryGroup(
    title: 'Tagihan & Langganan',
    accentColor: AppColors.warningOrange,
    items: [
      _CategoryOption('Listrik'),
      _CategoryOption('Air'),
      _CategoryOption('WiFi'),
      _CategoryOption('Sewa/Kos/Kontrakan'),
      _CategoryOption('Cicilan'),
      _CategoryOption('Asuransi'),
      _CategoryOption('Pajak'),
      _CategoryOption('Langganan Aplikasi'),
      _CategoryOption('Software Kerja'),
      _CategoryOption('Cloud Storage'),
      _CategoryOption('Streaming'),
      _CategoryOption('Adobe/Design Tools'),
      _CategoryOption('Domain & Hosting'),
    ],
  ),
  _CategoryGroup(
    title: 'Kesehatan',
    accentColor: AppColors.primary,
    items: [
      _CategoryOption('Obat'),
      _CategoryOption('Dokter'),
      _CategoryOption('Rumah Sakit'),
      _CategoryOption('Vitamin'),
      _CategoryOption('Skincare'),
      _CategoryOption('Perawatan Diri'),
      _CategoryOption('Olahraga'),
    ],
  ),
  _CategoryGroup(
    title: 'Pendidikan & Produktivitas',
    accentColor: AppColors.infoBlue,
    items: [
      _CategoryOption('Buku'),
      _CategoryOption('Kursus'),
      _CategoryOption('Sertifikasi'),
      _CategoryOption('Alat Tulis'),
      _CategoryOption('Print/Tugas'),
      _CategoryOption('Peralatan Kerja'),
      _CategoryOption('Aplikasi Produktivitas'),
    ],
  ),
  _CategoryGroup(
    title: 'Hiburan & Gaya Hidup',
    accentColor: AppColors.warningOrange,
    items: [
      _CategoryOption('Hiburan'),
      _CategoryOption('Nongkrong'),
      _CategoryOption('Bioskop'),
      _CategoryOption('Game'),
      _CategoryOption('Liburan'),
      _CategoryOption('Hobi'),
      _CategoryOption('Fashion'),
      _CategoryOption('Hadiah'),
    ],
  ),
  _CategoryGroup(
    title: 'Keuangan',
    accentColor: AppColors.infoBlue,
    items: [
      _CategoryOption('Tabungan'),
      _CategoryOption('Investasi'),
      _CategoryOption('Dana Darurat'),
      _CategoryOption('Transfer Keluar'),
      _CategoryOption('Biaya Admin'),
      _CategoryOption('Donasi'),
      _CategoryOption('Hutang Dibayar'),
    ],
  ),
  _CategoryGroup(
    title: 'Lainnya',
    accentColor: AppColors.textSecondary,
    items: [_CategoryOption('Lainnya')],
  ),
];

const _incomeGroups = [
  _CategoryGroup(
    title: 'Penghasilan',
    accentColor: AppColors.incomeGreen,
    items: [
      _CategoryOption('Gaji'),
      _CategoryOption('Upah'),
      _CategoryOption('Bonus'),
      _CategoryOption('Komisi'),
      _CategoryOption('Tunjangan'),
      _CategoryOption('Lembur'),
    ],
  ),
  _CategoryGroup(
    title: 'Usaha & Jasa',
    accentColor: AppColors.primary,
    items: [
      _CategoryOption('Penjualan'),
      _CategoryOption('Jasa'),
      _CategoryOption('Project'),
      _CategoryOption('Freelance'),
      _CategoryOption('Konsultasi'),
      _CategoryOption('Royalti'),
      _CategoryOption('Affiliate'),
    ],
  ),
  _CategoryGroup(
    title: 'Keuangan',
    accentColor: AppColors.infoBlue,
    items: [
      _CategoryOption('Cashback'),
      _CategoryOption('Refund'),
      _CategoryOption('Bunga'),
      _CategoryOption('Dividen'),
      _CategoryOption('Investasi Cair'),
      _CategoryOption('Tabungan Dicairkan'),
    ],
  ),
  _CategoryGroup(
    title: 'Dukungan & Lainnya',
    accentColor: AppColors.incomeGreen,
    items: [
      _CategoryOption('Uang Saku'),
      _CategoryOption('Hadiah'),
      _CategoryOption('Bantuan'),
      _CategoryOption('Pinjaman Masuk'),
      _CategoryOption('Lainnya'),
    ],
  ),
];
