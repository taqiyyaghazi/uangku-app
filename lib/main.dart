import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uangku/core/constants/app_constants.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/features/dashboard/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: UangkuApp()));
}

/// Root widget for the Uangku application.
///
/// Wraps the app in [ProviderScope] (done in [main]) so that
/// all Riverpod providers are available throughout the tree.
class UangkuApp extends StatelessWidget {
  const UangkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Google Fonts at the composition root.
    final interTextTheme = GoogleFonts.interTextTheme();
    final interDarkTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );
    final lightTitleStyle = GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: OceanFlowColors.onPrimary,
    );
    final darkTitleStyle = GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(
        textTheme: interTextTheme,
        titleTextStyle: lightTitleStyle,
      ),
      darkTheme: buildDarkTheme(
        textTheme: interDarkTextTheme,
        titleTextStyle: darkTitleStyle,
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
