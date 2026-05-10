import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/controllers/app_providers.dart';

void main() async {
  runApp(
    ProviderScope(
      overrides: [],
      child: _SeedDataInitializer(
        child: KeePriceApp(),
      ),
    ),
  );
}

class _SeedDataInitializer extends ConsumerWidget {
  const _SeedDataInitializer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize seed data on app startup
    ref.watch(seedDataProvider);

    return child;
  }
}

class KeePriceApp extends StatelessWidget {
  const KeePriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: AppConstants.routeLogin,
      onGenerateRoute: AppRouter.onGenerateRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B00)),
        useMaterial3: true,
      ),
    );
  }
}
