import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Supabase configuration and client code
class SupabaseConfig {
  static const String supabaseUrl = 'https://skqsuxmdfqxbkhmselaz.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrcXN1eG1kZnF4YmtobXNlbGF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNjQxMDMsImV4cCI6MjA3MTY0MDEwM30.NkwMkK6wZVPv2G_U39Q-rOMT5yUKLvPePnfXHKMR6JU';

  static Future<void> initialize() async {
    try {
      debugPrint('🔧 Initializing Supabase...');
      debugPrint('🌐 URL: $supabaseUrl');
      debugPrint('🔑 Using anon key: ${anonKey.substring(0, 20)}...');
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: anonKey,
        debug: kDebugMode,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('❌ Supabase initialization timeout');
          throw Exception('Timeout durante l\'inizializzazione di Supabase');
        },
      );
      
      debugPrint('✅ Supabase initialized successfully!');
    } catch (e) {
      debugPrint('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  
}

/// Authentication service - Remove this class if your project doesn't need auth
class SupabaseAuth {
  /// Get the app redirect URL based on platform
  static String _getRedirectUrl() {
    if (kIsWeb) {
      // Per web, usa la URL corrente
      return '${Uri.base.origin}/';
    } else {
      // Per mobile, usa deep link scheme
      return 'jetcv://auth/callback';
    }
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      debugPrint('🚀 Starting signup process for: $email');
      debugPrint('⏳ Calling Supabase auth.signUp...');
      
      final redirectUrl = _getRedirectUrl();
      debugPrint('📍 Using redirect URL: $redirectUrl');
      
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: userData,
        emailRedirectTo: redirectUrl,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('❌ Signup timeout after 15 seconds');
          throw Exception('La registrazione sta impiegando troppo tempo. Verifica le impostazioni del progetto Supabase o riprova più tardi.');
        },
      );

      debugPrint('✅ Signup response received!');
      debugPrint('👤 User ID: ${response.user?.id}');
      debugPrint('🔐 Session exists: ${response.session != null}');
      debugPrint('📧 Email confirmed: ${response.user?.emailConfirmedAt != null}');

      // If user exists but no session, email confirmation is likely required
      if (response.user != null && response.session == null) {
        debugPrint('📧 Email confirmation required');
      } else if (response.user != null && response.session != null) {
        debugPrint('✅ User logged in immediately');
      }

      return response;
    } catch (e) {
      debugPrint('💥 Signup error: $e');
      debugPrint('🔍 Error type: ${e.runtimeType}');
      
      if (e.toString().contains('TimeoutException') || e.toString().contains('Timeout')) {
        throw Exception('La registrazione sta impiegando troppo tempo. Verifica che il progetto Supabase sia configurato correttamente o riprova più tardi.');
      }
      
      // Handle specific Supabase errors
      if (e is AuthException) {
        throw Exception(_handleAuthError(e));
      }
      
      throw Exception('Errore durante la registrazione: ${_handleAuthError(e)}');
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔑 Starting login process for: $email');
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('❌ Login timeout after 20 seconds');
          throw Exception('Timeout durante il login. Controlla la connessione internet o riprova più tardi.');
        },
      );
      debugPrint('✅ Login completed successfully!');
      return response;
    } catch (e) {
      debugPrint('💥 Login error: $e');
      if (e.toString().contains('TimeoutException') || e.toString().contains('Timeout')) {
        throw Exception('Timeout durante il login. Controlla la connessione internet o riprova più tardi.');
      }
      throw _handleAuthError(e);
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      debugPrint('🚪 Calling Supabase signOut...');
      await SupabaseConfig.auth.signOut().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('❌ Supabase signOut timeout');
          throw Exception('Timeout durante il logout');
        },
      );
      debugPrint('✅ Supabase signOut completed');
    } catch (e) {
      debugPrint('💥 Supabase signOut error: $e');
      throw _handleAuthError(e);
    }
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      final redirectUrl = _getRedirectUrl();
      debugPrint('📍 Password reset redirect URL: $redirectUrl');
      
      await SupabaseConfig.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with Google
  static Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔑 Starting Google authentication...');
      
      final redirectUrl = _getRedirectUrl();
      debugPrint('📍 Google OAuth redirect URL: $redirectUrl');
      
      // Use Supabase's OAuth flow
      await SupabaseConfig.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
      
      debugPrint('✅ Google OAuth flow initiated successfully!');
    } catch (e) {
      debugPrint('💥 Google authentication error: $e');
      throw _handleAuthError(e);
    }
  }

  /// Get current user
  static User? get currentUser => SupabaseConfig.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Auth state changes stream
  static Stream<AuthState> get authStateChanges =>
      SupabaseConfig.auth.onAuthStateChange;

  /// Create user profile in database (modify based on your schema)
  static Future<void> _createUserProfile(
    User user,
    Map<String, dynamic>? userData,
  ) async {
    try {
      // Check if profile already exists
      final existingUser = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingUser == null) {
        await SupabaseConfig.client.from('users').insert({
          'id': user.id,
          'email': user.email,
          'full_name': userData?['full_name'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // Don't throw here to avoid breaking the signup flow
    }
  }

  /// Handle authentication errors
  static String _handleAuthError(dynamic error) {
    String errorMessage;
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          errorMessage = 'Email o password non validi';
          break;
        case 'Email not confirmed':
          errorMessage = 'Controlla la tua email e conferma il tuo account';
          break;
        case 'User not found':
          errorMessage = 'Nessun account trovato con questa email';
          break;
        case 'Signup requires a valid password':
          errorMessage = 'La password deve avere almeno 6 caratteri';
          break;
        case 'Too many requests':
          errorMessage = 'Troppi tentativi. Riprova più tardi';
          break;
        default:
          errorMessage = 'Errore di autenticazione: ${error.message}';
          break;
      }
    } else if (error is PostgrestException) {
      errorMessage = 'Errore del database: ${error.message}';
    } else {
      errorMessage = 'Errore di connessione. Controlla la tua connessione internet';
    }
    
    // Stampa l'errore per il debug
    debugPrint('Auth Error: $error');
    
    return errorMessage;
  }
}

/// Generic database service for CRUD operations
class SupabaseService {
  /// Select multiple records from a table
  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).select(select ?? '*');

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query;
    } catch (e) {
      throw _handleDatabaseError('select', table, e);
    }
  }

  /// Select a single record from a table
  static Future<Map<String, dynamic>?> selectSingle(
    String table, {
    String? select,
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).select(select ?? '*');

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      return await query.maybeSingle();
    } catch (e) {
      throw _handleDatabaseError('selectSingle', table, e);
    }
  }

  /// Insert a record into a table
  static Future<List<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      return await SupabaseConfig.client.from(table).insert(data).select();
    } catch (e) {
      throw _handleDatabaseError('insert', table, e);
    }
  }

  /// Insert multiple records into a table
  static Future<List<Map<String, dynamic>>> insertMultiple(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      return await SupabaseConfig.client.from(table).insert(data).select();
    } catch (e) {
      throw _handleDatabaseError('insertMultiple', table, e);
    }
  }

  /// Update records in a table
  static Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).update(data);

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      return await query.select();
    } catch (e) {
      throw _handleDatabaseError('update', table, e);
    }
  }

  /// Delete records from a table
  static Future<void> delete(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).delete();

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      await query;
    } catch (e) {
      throw _handleDatabaseError('delete', table, e);
    }
  }

  /// Get direct table reference for complex queries
  static SupabaseQueryBuilder from(String table) =>
      SupabaseConfig.client.from(table);

  /// Handle database errors
  static String _handleDatabaseError(
    String operation,
    String table,
    dynamic error,
  ) {
    if (error is PostgrestException) {
      return 'Failed to $operation from $table: ${error.message}';
    } else {
      return 'Failed to $operation from $table: ${error.toString()}';
    }
  }
}
