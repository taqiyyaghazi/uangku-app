import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uangku/core/config/app_config.dart';
import 'package:uangku/core/constants/app_constants.dart';
import 'package:uangku/core/di/app_provider_observer.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/features/auth/widgets/auth_wrapper.dart';

void mainRunner(Environment env, FirebaseOptions? firebaseOptions) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.environment = env;

  // Initialize Firebase with flavor-specific options.
  await Firebase.initializeApp(options: firebaseOptions);

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all asynchronous errors that aren't caught by the Flutter framework to Crashlytics.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    ProviderScope(observers: [AppProviderObserver()], child: const UangkuApp()),
  );
}

/// Root widget for the Uangku application.
///
/// Wraps the app in [ProviderScope] (done in [main]) so that
/// all Riverpod providers are available throughout the tree.
class UangkuApp extends ConsumerWidget {
  const UangkuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      home: const AuthWrapper(),
      navigatorObservers: [ref.watch(monitoringServiceProvider).observer],
    );
  }
}
