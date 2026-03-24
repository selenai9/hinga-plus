import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hinga_plus/database/database.dart';
import 'package:hinga_plus/features/dashboard.dart';
import 'package:hinga_plus/features/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

void main() {
  runApp(
    const ProviderScope(
      child: HingaPlusApp(),
    ),
  );
}

class HingaPlusApp extends ConsumerWidget {
  const HingaPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(sharedPreferencesProvider);

    return MaterialApp(
      title: 'Hinga+',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: prefsAsync.when(
        data: (p) {
          final onboarded = p.getBool('onboarded') ?? false;
          return onboarded ? const DashboardScreen() : const OnboardingScreen();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}

