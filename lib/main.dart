import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dog_search/presentation/screens/breed_search_screen.dart';

void main() {
  runApp(const TheDogApiApp());
}

class TheDogApiApp extends StatelessWidget {
  const TheDogApiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheDogAPI Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BreedSearchScreen(),
    );
  }
}
