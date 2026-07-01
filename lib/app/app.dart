import 'package:flutter/material.dart';

import '../shared/layouts/main_shell.dart';
import 'theme/app_theme.dart';

class FaddompetApp extends StatelessWidget {
  const FaddompetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faddompet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}
