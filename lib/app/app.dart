import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/onboarding/onboarding_page.dart';
import '../features/security/app_lock_gate.dart';
import '../shared/layouts/main_shell.dart';
import '../shared/widgets/loading_state.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';

class FadDompetApp extends ConsumerWidget {
  const FadDompetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref
        .watch(appSettingsProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);

    return MaterialApp(
      title: 'FadDompet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode(settings?.themeMode),
      builder: (context, child) {
        final brightness = Theme.of(context).colorScheme.brightness;
        final isDark = brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppLockGate(child: _AppGate()),
    );
  }

  ThemeMode _themeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);

    return bootstrap.when(
      data: (_) {
        final settings = ref.watch(appSettingsProvider);
        return settings.when(
          data: (value) {
            if (value?.onboardingCompleted ?? false) {
              return const MainShell();
            }
            return const OnboardingPage();
          },
          loading: () => const LoadingState(message: 'Menyiapkan data lokal'),
          error: (_, _) => const OnboardingPage(),
        );
      },
      loading: () => const LoadingState(message: 'Menyiapkan FadDompet'),
      error: (_, _) => const LoadingState(message: 'Data belum bisa dimuat'),
    );
  }
}
