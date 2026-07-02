import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/enums/category_type.dart';
import '../../data/local/database/app_database.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref
        .watch(appSettingsProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xl,
          AppSpacing.screen,
          AppSpacing.contentBottomInset,
        ),
        children: [
          Text('Pengaturan', style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xxl),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Tampilan',
            subtitle: _themeLabel(settings?.themeMode ?? 'system'),
            onTap: () =>
                _showThemeSheet(context, ref, settings?.themeMode ?? 'system'),
          ),
          _SettingsTile(
            icon: Icons.visibility_off_rounded,
            title: 'Sembunyikan saldo',
            subtitle: settings?.hideBalance ?? false
                ? 'Nominal disamarkan'
                : 'Nominal terlihat',
            trailing: Switch(
              value: settings?.hideBalance ?? false,
              onChanged: (value) {
                ref.read(settingsRepositoryProvider).setHideBalance(value);
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.category_rounded,
            title: 'Kategori',
            subtitle: 'Tambah atau ubah kategori transaksi',
            onTap: () => _showCategoriesSheet(context, ref),
          ),
          _SettingsTile(
            icon: Icons.backup_rounded,
            title: 'Data & Backup',
            subtitle: 'Ekspor, impor, atau reset data lokal',
            onTap: () => _showBackupSheet(context, ref),
          ),
          const _SettingsTile(
            icon: Icons.lock_rounded,
            title: 'Keamanan',
            subtitle: 'Biometrik disiapkan untuk versi berikutnya',
          ),
          _SettingsTile(
            icon: Icons.info_rounded,
            title: 'Tentang Faddompet',
            subtitle: 'Versi 1.0.0, offline tanpa akun',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Faddompet',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Aplikasi keuangan pribadi offline.',
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref, String selected) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetOption(
                title: 'System',
                selected: selected == 'system',
                onTap: () => _setTheme(context, ref, 'system'),
              ),
              _SheetOption(
                title: 'Terang',
                selected: selected == 'light',
                onTap: () => _setTheme(context, ref, 'light'),
              ),
              _SheetOption(
                title: 'Gelap',
                selected: selected == 'dark',
                onTap: () => _setTheme(context, ref, 'dark'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setTheme(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    await ref.read(settingsRepositoryProvider).setThemeMode(value);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _showBackupSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetOption(
                title: 'Ekspor backup JSON',
                onTap: () => _runBackupAction(
                  context,
                  () => ref.read(backupRepositoryProvider).exportJson(),
                  'Data berhasil diekspor.',
                ),
              ),
              _SheetOption(
                title: 'Ekspor transaksi CSV',
                onTap: () => _runBackupAction(
                  context,
                  () => ref.read(backupRepositoryProvider).exportCsv(),
                  'CSV berhasil diekspor.',
                ),
              ),
              _SheetOption(
                title: 'Impor backup JSON',
                onTap: () => _runBackupAction(
                  context,
                  () => ref.read(backupRepositoryProvider).importJson(),
                  'Data berhasil diimpor.',
                ),
              ),
              _SheetOption(
                title: 'Reset data',
                destructive: true,
                onTap: () => _confirmReset(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runBackupAction(
    BuildContext context,
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File backup tidak valid.')));
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'Semua transaksi, dompet, kategori, dan budget akan dibuat ulang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(backupRepositoryProvider).resetData();
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data berhasil direset.')));
  }

  void _showCategoriesSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _CategoryManagerSheet(),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: onTap,
            leading: Container(
              width: AppSpacing.iconTileSmall + AppSpacing.xxs,
              height: AppSpacing.iconTileSmall + AppSpacing.xxs,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.softMint.withValues(alpha: 0.12)
                    : AppColors.surfaceMint,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.softMint : AppColors.primary,
                size: 21,
              ),
            ),
            title: Text(title, style: theme.textTheme.titleMedium),
            subtitle: Text(subtitle),
            trailing:
                trailing ??
                (onTap == null
                    ? null
                    : const Icon(Icons.chevron_right_rounded)),
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.title,
    this.selected = false,
    this.destructive = false,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(color: destructive ? AppColors.expenseRed : null),
      ),
      trailing: selected ? const Icon(Icons.check_rounded) : null,
    );
  }
}

class _CategoryManagerSheet extends ConsumerWidget {
  const _CategoryManagerSheet();

  @override
  Widget build(BuildContext context, WidgetRef sheetRef) {
    final categories = sheetRef.watch(categoriesProvider);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: categories.when(
          data: (items) => ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => _showCategoryDialog(context, sheetRef),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final group in _groupCategories(items).entries) ...[
                Text(group.key, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                for (final category in group.value)
                  ListTile(
                    title: Text(category.name),
                    subtitle: Text(
                      category.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
                    ),
                    trailing: category.isDefault
                        ? const Text('Bawaan')
                        : const Icon(Icons.edit_rounded),
                    onTap: () =>
                        _showCategoryDialog(context, sheetRef, category),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
          loading: () => const Center(child: Text('Memuat kategori')),
          error: (_, _) =>
              const Center(child: Text('Kategori belum bisa dimuat')),
        ),
      ),
    );
  }

  Map<String, List<CategoryEntry>> _groupCategories(List<CategoryEntry> items) {
    final groups = <String, List<CategoryEntry>>{};
    for (final item in items) {
      groups.putIfAbsent(item.groupName, () => []).add(item);
    }
    return groups;
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, [
    CategoryEntry? category,
  ]) async {
    final result = await showDialog<_CategoryFormResult>(
      context: context,
      builder: (context) => _CategoryDialog(category: category),
    );
    if (result == null) return;

    final repository = ref.read(categoryRepositoryProvider);
    if (category == null) {
      await repository.addCategory(
        name: result.name,
        type: result.type,
        groupName: result.groupName,
        colorValue: result.type == CategoryType.income
            ? AppColors.incomeGreen.toARGB32()
            : AppColors.expenseRed.toARGB32(),
      );
    } else {
      await repository.updateCategory(category, result.name);
    }
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.category});

  final CategoryEntry? category;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;
  late CategoryType _type;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _groupController = TextEditingController(
      text: category?.groupName ?? 'Lainnya',
    );
    _type = category?.type == 'income'
        ? CategoryType.income
        : CategoryType.expense;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.category != null;

    return AlertDialog(
      title: Text(editing ? 'Edit kategori' : 'Tambah kategori'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama kategori'),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _groupController,
            enabled: !editing,
            decoration: const InputDecoration(labelText: 'Grup'),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!editing)
            SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment(
                  value: CategoryType.expense,
                  label: Text('Pengeluaran'),
                ),
                ButtonSegment(
                  value: CategoryType.income,
                  label: Text('Pemasukan'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
              },
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
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              _CategoryFormResult(
                name: name,
                groupName: _groupController.text.trim(),
                type: _type,
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _CategoryFormResult {
  const _CategoryFormResult({
    required this.name,
    required this.groupName,
    required this.type,
  });

  final String name;
  final String groupName;
  final CategoryType type;
}

String _themeLabel(String value) {
  switch (value) {
    case 'light':
      return 'Terang';
    case 'dark':
      return 'Gelap';
    default:
      return 'Ikuti perangkat';
  }
}
