import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class PremiumBottomNavItem {
  const PremiumBottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onChanged,
    required this.onAddPressed,
  });

  final int currentIndex;
  final List<PremiumBottomNavItem> items;
  final ValueChanged<int> onChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.webMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              height: 78,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.96)
                    : AppColors.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.borderSubtle,
                ),
                boxShadow: AppShadows.nav(brightness),
              ),
              child: Row(
                children: [
                  _NavItem(
                    item: items[0],
                    selected: currentIndex == 0,
                    onTap: () => onChanged(0),
                  ),
                  _NavItem(
                    item: items[1],
                    selected: currentIndex == 1,
                    onTap: () => onChanged(1),
                  ),
                  _QuickAddButton(onPressed: onAddPressed),
                  _NavItem(
                    item: items[2],
                    selected: currentIndex == 2,
                    onTap: () => onChanged(2),
                  ),
                  _NavItem(
                    item: items[3],
                    selected: currentIndex == 3,
                    onTap: () => onChanged(3),
                  ),
                  _NavItem(
                    item: items[4],
                    selected: currentIndex == 4,
                    onTap: () => onChanged(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PremiumBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.softMint : AppColors.primary;
    final inactiveColor = isDark
        ? AppColors.darkTextTertiary
        : AppColors.textTertiary;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: AppDurations.normal,
                  curve: AppDurations.easeOut,
                  width: 42,
                  height: 30,
                  decoration: BoxDecoration(
                    color: selected
                        ? activeColor.withValues(alpha: isDark ? 0.16 : 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: selected ? activeColor : inactiveColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? activeColor : inactiveColor,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Tambah transaksi',
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Tooltip(
          message: 'Tambah transaksi',
          child: Container(
            width: 54,
            height: 54,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              color: isDark ? AppColors.softMint : AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.primary).withValues(
                    alpha: isDark ? 0.36 : 0.22,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              color: isDark ? AppColors.darkBackground : Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
