import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/enums/wallet_type.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/app_models.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../shared/widgets/app_form_actions.dart';
import '../../shared/widgets/app_icon_action_button.dart';
import '../../shared/widgets/pressable_surface.dart';
import '../../shared/widgets/top_toast.dart';

class WalletsPage extends ConsumerWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletBalancesProvider);
    final settings = ref
        .watch(appSettingsProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final hideBalance = settings?.hideBalance ?? false;

    return SafeArea(
      bottom: false,
      child: wallets.when(
        data: (items) => ListView(
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
                    'Dompet',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                AppIconActionButton(
                  icon: Icons.add_rounded,
                  label: 'Tambah dompet',
                  onPressed: () => _showWalletForm(context, ref),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kelola tempat penyimpanan uang seperti tunai, e-wallet, rekening, dan tabungan.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            for (final wallet in items) ...[
              _WalletCard(
                wallet: wallet,
                hideBalance: hideBalance,
                onTap: () =>
                    _showWalletDetail(context, ref, wallet, hideBalance),
                onLongPress: () => _deleteWallet(context, ref, wallet.wallet),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
        loading: () => const Center(child: Text('Memuat dompet')),
        error: (_, _) => const Center(child: Text('Dompet belum bisa dimuat')),
      ),
    );
  }

  Future<void> _showWalletForm(
    BuildContext context,
    WidgetRef ref, [
    WalletEntry? wallet,
  ]) async {
    final result = await showDialog<_WalletFormResult>(
      context: context,
      builder: (context) => _WalletFormDialog(wallet: wallet),
    );
    if (result == null) return;

    final repository = ref.read(walletRepositoryProvider);
    try {
      if (wallet == null) {
        await repository.addWallet(
          name: result.name,
          type: result.type.value,
          initialBalance: result.initialBalance,
        );
      } else {
        await repository.updateWallet(
          wallet: wallet,
          name: result.name,
          type: result.type.value,
          initialBalance: result.initialBalance,
        );
      }
      if (!context.mounted) return;
      TopToast.show(
        context,
        wallet == null
            ? 'Dompet berhasil disimpan.'
            : 'Dompet berhasil diperbarui.',
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

  void _showWalletDetail(
    BuildContext context,
    WidgetRef ref,
    WalletBalance wallet,
    bool hideBalance,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final type = WalletType.fromValue(wallet.wallet.type);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            child: FutureBuilder<int>(
              future: ref
                  .read(walletRepositoryProvider)
                  .transactionCount(wallet.wallet.id),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.wallet.name,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      wallet.wallet.isArchived
                          ? '${type.label} tidak aktif'
                          : type.label,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      CurrencyFormatter.rupiah(
                        wallet.balance,
                        hidden: hideBalance,
                      ),
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _WalletInfoRow(
                      label: 'Transaksi',
                      value: '$count transaksi',
                    ),
                    _WalletInfoRow(
                      label: 'Saldo awal',
                      value: CurrencyFormatter.rupiah(
                        wallet.wallet.initialBalance,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormActions(
                      secondaryLabel: 'Edit',
                      primaryLabel: wallet.wallet.isArchived
                          ? 'Aktifkan'
                          : count > 0
                          ? 'Nonaktifkan'
                          : 'Hapus',
                      danger: !wallet.wallet.isArchived,
                      onSecondaryPressed: () {
                        Navigator.pop(sheetContext);
                        _showWalletForm(context, ref, wallet.wallet);
                      },
                      onPrimaryPressed: () {
                        Navigator.pop(sheetContext);
                        if (wallet.wallet.isArchived) {
                          _archiveWallet(context, ref, wallet.wallet, false);
                        } else if (count > 0) {
                          _archiveWallet(context, ref, wallet.wallet, true);
                        } else {
                          _deleteWallet(context, ref, wallet.wallet);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteWallet(
    BuildContext context,
    WidgetRef ref,
    WalletEntry wallet,
  ) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Hapus dompet?',
      message: '${wallet.name} akan dihapus jika belum dipakai transaksi.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!confirmed) return;

    final message = await ref
        .read(walletRepositoryProvider)
        .deleteWallet(wallet.id);
    if (!context.mounted) return;
    TopToast.show(
      context,
      message ?? 'Dompet berhasil dihapus.',
      type: message == null ? TopToastType.success : TopToastType.warning,
    );
  }

  Future<void> _archiveWallet(
    BuildContext context,
    WidgetRef ref,
    WalletEntry wallet,
    bool archived,
  ) async {
    await ref.read(walletRepositoryProvider).setArchived(wallet, archived);
    if (!context.mounted) return;
    TopToast.show(
      context,
      archived ? 'Dompet dinonaktifkan.' : 'Dompet diaktifkan kembali.',
      type: TopToastType.success,
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.wallet,
    required this.hideBalance,
    required this.onTap,
    required this.onLongPress,
  });

  final WalletBalance wallet;
  final bool hideBalance;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;
    final type = WalletType.fromValue(wallet.wallet.type);
    final accentColor = _accent(type);

    return PressableSurface(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
          ),
          boxShadow: AppShadows.subtle(brightness),
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.iconTile + AppSpacing.xxs,
              height: AppSpacing.iconTile + AppSpacing.xxs,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.18 : 0.11),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(_icon(type), color: accentColor),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          wallet.wallet.name,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (wallet.wallet.isArchived)
                        Text(
                          'Nonaktif',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.warningOrange,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(type.label, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.rupiah(wallet.balance, hidden: hideBalance),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletInfoRow extends StatelessWidget {
  const _WalletInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _WalletFormDialog extends StatefulWidget {
  const _WalletFormDialog({this.wallet});

  final WalletEntry? wallet;

  @override
  State<_WalletFormDialog> createState() => _WalletFormDialogState();
}

class _WalletFormDialogState extends State<_WalletFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late WalletType _type;

  @override
  void initState() {
    super.initState();
    final wallet = widget.wallet;
    _nameController = TextEditingController(text: wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: wallet?.initialBalance == null || wallet!.initialBalance == 0
          ? ''
          : CurrencyFormatter.rupiah(wallet.initialBalance),
    );
    _type = WalletType.fromValue(wallet?.type ?? WalletType.cash.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.wallet == null ? 'Tambah dompet' : 'Edit dompet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama dompet',
              hintText: 'Contoh: Tunai',
              helperText: 'Gunakan nama yang mudah kamu kenali.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final type in WalletType.values)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            inputFormatters: const [RupiahInputFormatter()],
            decoration: InputDecoration(
              labelText: 'Saldo awal',
              hintText: 'Rp0',
              helperText: widget.wallet == null
                  ? 'Opsional, boleh dikosongkan.'
                  : 'Mengubah saldo awal akan memengaruhi saldo dompet.',
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
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              _WalletFormResult(
                name: name,
                type: _type,
                initialBalance: CurrencyFormatter.parseRupiah(
                  _balanceController.text,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WalletFormResult {
  const _WalletFormResult({
    required this.name,
    required this.type,
    required this.initialBalance,
  });

  final String name;
  final WalletType type;
  final int initialBalance;
}

Color _accent(WalletType type) {
  switch (type) {
    case WalletType.cash:
      return AppColors.incomeGreen;
    case WalletType.ewallet:
      return AppColors.infoBlue;
    case WalletType.bank:
      return AppColors.primary;
    case WalletType.savings:
      return AppColors.warningOrange;
  }
}

IconData _icon(WalletType type) {
  switch (type) {
    case WalletType.cash:
      return Icons.payments_rounded;
    case WalletType.ewallet:
      return Icons.account_balance_wallet_rounded;
    case WalletType.bank:
      return Icons.account_balance_rounded;
    case WalletType.savings:
      return Icons.savings_rounded;
  }
}
