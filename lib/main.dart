import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/theme.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/screens/splash_screen.dart';
import 'package:jetcv__utenti/screens/home_page_public.dart';
import 'package:jetcv__utenti/screens/auth/password_reset_page.dart';
import 'package:jetcv__utenti/screens/privacy_policy_page.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => const AppRouter(),
        // Explicit OAuth callback route like enterprise
        '/auth/callback': (context) => const AppRouter(),
        // Password reset route
        '/password-reset': (context) => const AppRouter(),
        // Privacy policy route
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
      },
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
  bool _handledInitialCallback = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _checkAuthStatus();
    _handlePossibleOAuthCallback();
  }

  void _setupAuthListener() {
    // Ascolta i cambiamenti di stato dell'autenticazione (inclusi i deep link)
    _authSubscription = SupabaseConfig.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;
      debugPrint(
          '🔄 Auth state changed: ${session != null ? 'authenticated' : 'not authenticated'} (event: $event)');

      // Se l'utente si è appena autenticato tramite deep link o altro metodo
      if (session != null && !_isAuthenticated) {
        debugPrint('✅ User authenticated via deep link or OAuth callback');
      }

      // Se l'utente è stato disconnesso o la sessione è diventata null, forza logout
      if (event == AuthChangeEvent.signedOut && session == null) {
        debugPrint('🔓 User signed out - cleaning auth state');
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isAuthenticated = session != null;
        _isLoading = false;
      });
    });
  }

  /// Handle OAuth callback on web: if the URL contains `code` and `state`,
  /// let Supabase complete PKCE and then navigate to the right screen.
  Future<void> _handlePossibleOAuthCallback() async {
    try {
      if (_handledInitialCallback) return;
      final uri = Uri.base;
      final hasAuthParams = uri.queryParameters.containsKey('code') ||
          uri.queryParameters.containsKey('access_token') ||
          uri.fragment.contains('access_token');
      if (!hasAuthParams) return;

      _handledInitialCallback = true;

      // Give Supabase time to complete PKCE exchange
      await Future.delayed(const Duration(milliseconds: 800));

      final session = SupabaseConfig.auth.currentSession;
      if (session != null) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      }
    } catch (_) {}
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

      // Se la sessione esiste ma potrebbe essere corrotta, validala
      if (session != null) {
        debugPrint('🔍 Validating existing session...');
        await _validateSession();
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error checking auth status: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  /// Validate if the current session is still valid
  Future<void> _validateSession() async {
    try {
      // Try to refresh the session to check if it's valid
      final refreshResult = await SupabaseConfig.auth.refreshSession();
      if (refreshResult.session != null) {
        debugPrint('✅ Session is valid');
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      } else {
        debugPrint('❌ Session validation failed - cleaning up');
        await _clearCorruptedSession();
      }
    } catch (e) {
      debugPrint('❌ Session validation error: $e - cleaning up');
      await _clearCorruptedSession();
    }
  }

  /// Clear corrupted session data
  Future<void> _clearCorruptedSession() async {
    try {
      debugPrint('🧹 Clearing corrupted session...');
      await SupabaseConfig.auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      debugPrint('❌ Error clearing session: $e');
    } finally {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if this is a password reset page request
    final uri = Uri.base;
    final isPasswordResetRoute = uri.path == '/password-reset';

    if (isPasswordResetRoute) {
      // Show password reset page regardless of auth status
      return const PasswordResetPage();
    }

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
      return const HomePagePublic();
    }
  }
}
