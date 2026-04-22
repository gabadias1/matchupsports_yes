import 'package:flutter/material.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:match_up_sports/theme/app_theme.dart';

void main() {
  runApp(const MatchUpApp());
}

class MatchUpApp extends StatelessWidget {
  const MatchUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Match Up Sports YES',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
