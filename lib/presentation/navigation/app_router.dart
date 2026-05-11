import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../pages/coleta_catalog_page.dart';
import '../pages/coleta_edit_page.dart';
import '../pages/coleta_summary_page.dart';
import '../pages/login_page.dart';
import '../pages/price_input_page.dart';
import '../pages/scanner_page.dart';
import '../pages/signup_page.dart';
import '../pages/store_selection_page.dart';
import 'route_args.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeColetaCatalog:
        final args = settings.arguments as ColetaCatalogArgs;
        return MaterialPageRoute(
          builder: (_) => ColetaCatalogPage(args: args),
        );
      case AppConstants.routeScanner:
        final args = settings.arguments as ScannerArgs;
        return MaterialPageRoute(builder: (_) => ScannerPage(args: args));
      case AppConstants.routePriceInput:
        final args = settings.arguments as PriceInputArgs;
        return MaterialPageRoute(builder: (_) => PriceInputPage(args: args));
      case AppConstants.routeEditItem:
        final args = settings.arguments as EditItemArgs;
        return MaterialPageRoute(builder: (_) => ColetaEditPage(args: args));
      case AppConstants.routeSummary:
        final args = settings.arguments as ColetaSummaryArgs;
        return MaterialPageRoute(builder: (_) => ColetaSummaryPage(args: args));
      case AppConstants.routeStoreSelection:
        return MaterialPageRoute(builder: (_) => const StoreSelectionPage());
      case AppConstants.routeSignup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case AppConstants.routeLogin:
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
