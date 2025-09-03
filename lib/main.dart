import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/theme.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/screens/splash_screen.dart';
import 'package:jetcv__utenti/screens/home_page.dart';
import 'package:jetcv__utenti/services/locale_service.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await LocaleService.instance.loadSavedLocale();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    LocaleService.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JetCV',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      locale: LocaleService.instance.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleService.supportedLocales,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _checkAuthStatus();
  }

  void _setupAuthListener() {
    // Ascolta i cambiamenti di stato dell'autenticazione (inclusi i deep link)
    _authSubscription = SupabaseConfig.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      debugPrint(
          '🔄 Auth state changed: ${session != null ? 'authenticated' : 'not authenticated'}');

      // Se l'utente si è appena autenticato tramite deep link o altro metodo
      if (session != null && !_isAuthenticated) {
        debugPrint('✅ User authenticated via deep link or OAuth callback');
      }

      setState(() {
        _isAuthenticated = session != null;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Controlla se c'è già una sessione attiva
      final session = SupabaseConfig.client.auth.currentSession;
      debugPrint('🔍 Current session exists: ${session != null}');

      setState(() {
        _isAuthenticated = session != null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error checking auth status: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      // Utente autenticato → mostra splash screen e poi home utente autenticato
      return const SplashScreen();
    } else {
      // Utente non autenticato → mostra home page pubblica
      return const HomePage();
    }
  }
}
