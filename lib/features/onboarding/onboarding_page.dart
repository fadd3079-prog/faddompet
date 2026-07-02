import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../data/repositories/app_models.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _nameController = TextEditingController();
  final _balanceControllers = <int, TextEditingController>{};
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _balanceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _finish(List<WalletBalance> wallets) async {
    setState(() => _saving = true);
    final balances = <int, int>{};
    for (final wallet in wallets) {
      final raw = _balanceControllers[wallet.wallet.id]?.text ?? '';
      final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
      balances[wallet.wallet.id] = int.tryParse(digits) ?? 0;
    }

    await ref
        .read(settingsRepositoryProvider)
        .completeOnboarding(
          userName: _nameController.text,
          initialBalances: balances,
        );

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletBalancesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.webMaxWidth),
            child: wallets.when(
              data: (items) => ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.xl,
                  AppSpacing.screen,
                  AppSpacing.xxl,
                ),
                children: [
                  Container(
                    width: AppSpacing.huge,
                    height: AppSpacing.huge,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.onDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Selamat datang di Faddompet',
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Mulai catat pemasukan, pengeluaran, dan transfer secara offline.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _NameField(controller: _nameController),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Saldo awal opsional',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Isi jika kamu ingin saldo dompet langsung sesuai kondisi sekarang.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final item in items) ...[
                    _InitialBalanceField(
                      wallet: item,
                      controller: _controllerFor(item.wallet.id),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _saving ? null : () => _finish(items),
                    child: Text(
                      _saving ? 'Menyiapkan...' : 'Mulai Pakai Faddompet',
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: Text('Menyiapkan dompet')),
              error: (_, _) =>
                  const Center(child: Text('Data awal belum bisa dimuat')),
            ),
          ),
        ),
      ),
    );
  }

  TextEditingController _controllerFor(int walletId) {
    return _balanceControllers.putIfAbsent(walletId, TextEditingController.new);
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Nama opsional',
        hintText: 'Boleh dikosongkan',
      ),
    );
  }
}

class _InitialBalanceField extends StatelessWidget {
  const _InitialBalanceField({required this.wallet, required this.controller});

  final WalletBalance wallet;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wallet.wallet.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  CurrencyFormatter.rupiah(wallet.balance),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 132,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: 'Rp0', isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}
