import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/repositories/security_repository.dart';
import '../../shared/widgets/app_brand_mark.dart';
import '../../shared/widgets/pressable_surface.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _locked = false;
  bool _initialLockChecked = false;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt ??= DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _checkAutoLock();
    }
  }

  Future<void> _checkAutoLock() async {
    if (kIsWeb) return;

    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null) return;

    final settings = await ref.read(securityRepositoryProvider).loadSettings();
    if (!settings.pinEnabled) return;

    final elapsed = DateTime.now().difference(backgroundedAt);
    final shouldLock =
        settings.autoLockMinutes == 0 ||
        elapsed >= Duration(minutes: settings.autoLockMinutes);
    if (shouldLock && mounted) {
      setState(() => _locked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return widget.child;

    final security = ref.watch(securitySettingsProvider);

    return security.when(
      data: (settings) {
        if (!settings.pinEnabled) {
          _initialLockChecked = false;
          return widget.child;
        }

        final showLock = _locked || !_initialLockChecked;
        if (!_initialLockChecked) {
          _initialLockChecked = true;
          _locked = true;
        }

        return Stack(
          children: [
            widget.child,
            if (showLock)
              Positioned.fill(
                child: _AppLockScreen(
                  settings: settings,
                  onUnlocked: () => setState(() => _locked = false),
                ),
              ),
          ],
        );
      },
      loading: () =>
          const _SecurityStatusScreen(message: 'Memeriksa keamanan...'),
      error: (_, _) => _SecurityStatusScreen(
        message: 'Keamanan belum bisa diperiksa.',
        actionLabel: 'Coba lagi',
        onAction: () => ref.invalidate(securitySettingsProvider),
      ),
    );
  }
}

class _AppLockScreen extends ConsumerStatefulWidget {
  const _AppLockScreen({required this.settings, required this.onUnlocked});

  final SecuritySettings settings;
  final VoidCallback onUnlocked;

  @override
  ConsumerState<_AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<_AppLockScreen> {
  String _pin = '';
  String? _message;
  bool _checking = false;
  DateTime? _cooldownUntil;
  Timer? _cooldownTimer;

  bool get _isCoolingDown {
    final until = _cooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  @override
  void initState() {
    super.initState();
    _loadAttemptState();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAttemptState() async {
    final state = await ref
        .read(securityRepositoryProvider)
        .loadPinAttemptState();
    if (!mounted || !state.isCoolingDown) return;
    _activateCooldown(state.cooldownUntil!);
  }

  Future<void> _append(String value) async {
    if (_checking ||
        _isCoolingDown ||
        _pin.length >= widget.settings.pinLength) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _pin += value;
      _message = null;
    });
    if (_pin.length == widget.settings.pinLength) {
      await _verify();
    }
  }

  void _backspace() {
    if (_checking || _isCoolingDown || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _message = null;
    });
  }

  Future<void> _verify() async {
    setState(() => _checking = true);
    final repository = ref.read(securityRepositoryProvider);
    final attemptState = await repository.loadPinAttemptState();
    if (!mounted) return;
    if (attemptState.isCoolingDown) {
      _activateCooldown(attemptState.cooldownUntil!);
      return;
    }

    final ok = await repository.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      await repository.clearPinAttemptState();
      if (!mounted) return;
      widget.onUnlocked();
      return;
    }

    final failedState = await repository.registerFailedPinAttempt();
    if (!mounted) return;
    if (failedState.isCoolingDown) {
      _activateCooldown(failedState.cooldownUntil!);
    } else {
      setState(() {
        _pin = '';
        _message = 'PIN tidak sesuai.';
        _checking = false;
      });
    }
  }

  Future<void> _biometric() async {
    if (_checking || _isCoolingDown) return;
    try {
      final ok = await ref
          .read(securityRepositoryProvider)
          .unlockWithBiometric();
      if (!mounted) return;
      if (ok) {
        await ref.read(securityRepositoryProvider).clearPinAttemptState();
        if (!mounted) return;
        widget.onUnlocked();
      }
    } on ArgumentError catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message.toString());
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Gunakan PIN untuk membuka FadDompet.');
    }
  }

  void _activateCooldown(DateTime until) {
    _cooldownTimer?.cancel();
    setState(() {
      _cooldownUntil = until;
      _pin = '';
      _checking = false;
      _message = 'Terlalu banyak percobaan. Coba lagi sebentar.';
    });
    final remaining = until.difference(DateTime.now());
    _cooldownTimer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        if (!mounted) return;
        setState(() {
          _cooldownUntil = null;
          _message = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.webMaxWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Column(
                children: [
                  const Spacer(),
                  const AppBrandMark(size: 60, radius: AppRadius.lg),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Buka FadDompet',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Masukkan PIN untuk membuka FadDompet',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (
                        var index = 0;
                        index < widget.settings.pinLength;
                        index++
                      ) ...[
                        Container(
                          width: AppSpacing.md,
                          height: AppSpacing.md,
                          decoration: BoxDecoration(
                            color: index < _pin.length
                                ? (isDark
                                      ? AppColors.softMint
                                      : AppColors.primary)
                                : theme.colorScheme.outline,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        if (index != widget.settings.pinLength - 1)
                          const SizedBox(width: AppSpacing.md),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: AppSpacing.xxl,
                    child: Text(
                      _message ?? '',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.expenseRed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (widget.settings.biometricEnabled) ...[
                    TextButton.icon(
                      onPressed: _isCoolingDown ? null : _biometric,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Buka dengan biometrik'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _PinKeypad(
                    enabled: !_isCoolingDown,
                    onDigit: _append,
                    onBackspace: _backspace,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'backspace'],
        ]) ...[
          Row(
            children: [
              for (final value in row) ...[
                Expanded(
                  child: value.isEmpty
                      ? const SizedBox(height: AppSpacing.huge + AppSpacing.md)
                      : _PinKey(
                          enabled: enabled,
                          value: value,
                          onDigit: onDigit,
                          onBackspace: onBackspace,
                        ),
                ),
                if (value != row.last) const SizedBox(width: AppSpacing.md),
              ],
            ],
          ),
          if (row != const ['', '0', 'backspace'])
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({
    required this.enabled,
    required this.value,
    required this.onDigit,
    required this.onBackspace,
  });

  final bool enabled;
  final String value;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  bool get _isBackspace => value == 'backspace';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return PressableSurface(
      enabled: enabled,
      onTap: _isBackspace ? onBackspace : () => onDigit(value),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.huge + AppSpacing.md,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: _isBackspace
            ? Icon(Icons.backspace_outlined, color: theme.colorScheme.primary)
            : Text(value, style: theme.textTheme.titleLarge),
      ),
    );
  }
}

class _SecurityStatusScreen extends StatelessWidget {
  const _SecurityStatusScreen({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppBrandMark(size: 56, radius: AppRadius.lg),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  message,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(onPressed: onAction, child: Text(actionLabel!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
