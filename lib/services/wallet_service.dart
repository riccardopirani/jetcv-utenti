import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/models/wallet_model.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for wallet-related database operations
class WalletService {
  static final _client = SupabaseConfig.client;

  /// Get wallet by user ID using Edge Function with fallback to direct query
  static Future<WalletModel?> getWalletByUserId(String userId) async {
    try {
      debugPrint(
          '🔍 WalletService: Getting wallet for user: $userId using Edge Function');

      // Try Edge Function first
      final wallet = await _getWalletByUserIdEdgeFunction(userId);
      if (wallet != null) {
        return wallet;
      }

      // Fallback to direct database query if Edge Function fails
      debugPrint(
          '🔄 WalletService: Edge Function failed, trying direct query...');
      return await _getWalletByUserIdDirectQuery(userId);
    } catch (e) {
      debugPrint('❌ WalletService: Error getting wallet for user $userId: $e');
      return null;
    }
  }

  /// Get wallet using Edge Function
  static Future<WalletModel?> _getWalletByUserIdEdgeFunction(
      String userId) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        debugPrint('❌ WalletService: No active session');
        return null;
      }

      final url =
          '${SupabaseConfig.supabaseUrl}/functions/v1/get-wallet-byuser';
      debugPrint('🔍 WalletService: Making POST request to: $url');
      debugPrint('🔍 WalletService: User ID: $userId');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.anonKey,
        },
        body: json.encode({'idUser': userId}),
      );

      debugPrint(
          '📋 WalletService: Edge Function response status: ${response.statusCode}');
      debugPrint(
          '📋 WalletService: Edge Function response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('wallet')) {
          final walletValue = data['wallet'];

          // Handle both array and object responses
          if (walletValue is List) {
            if (walletValue.isEmpty) {
              debugPrint('⚠️ WalletService: No wallet found (empty array)');
              return null;
            } else {
              final walletData = walletValue.first as Map<String, dynamic>;
              debugPrint('✅ WalletService: Wallet found via Edge Function');
              return WalletModel.fromJson(walletData);
            }
          } else if (walletValue is Map<String, dynamic>) {
            debugPrint('✅ WalletService: Wallet found via Edge Function');
            return WalletModel.fromJson(walletValue);
          }
        }
      } else if (response.statusCode == 500) {
        debugPrint(
            '⚠️ WalletService: Edge Function error 500 - will try direct query');
        return null;
      }

      return null;
    } catch (e) {
      debugPrint('❌ WalletService: Edge Function error: $e');
      return null;
    }
  }

  /// Get wallet using direct database query as fallback
  static Future<WalletModel?> _getWalletByUserIdDirectQuery(
      String userId) async {
    try {
      debugPrint('🔍 WalletService: Trying direct database query...');

      final response = await _client
          .from('wallet')
          .select(
              'idWallet, idUser, publicAddress, secretKey, createdAt, updatedAt, createdBy')
          .eq('idUser', userId)
          .maybeSingle();

      if (response != null) {
        debugPrint('✅ WalletService: Wallet found via direct query');
        return WalletModel.fromJson(response);
      } else {
        debugPrint('⚠️ WalletService: No wallet found for user: $userId');
        return null;
      }
    } catch (e) {
      debugPrint('❌ WalletService: Direct query error: $e');
      return null;
    }
  }

  /// Get wallet with user information using Edge Function + user query
  static Future<Map<String, dynamic>?> getWalletWithUserInfo(
      String userId) async {
    try {
      debugPrint(
          '🔍 WalletService: Getting wallet with user info for: $userId');

      // Get wallet data using Edge Function
      final wallet = await getWalletByUserId(userId);
      if (wallet == null) {
        debugPrint('⚠️ WalletService: No wallet found for user: $userId');
        return null;
      }

      // Get user data using direct query (fallback)
      try {
        final userResponse = await _client
            .from('user')
            .select('firstName, lastName, fullName')
            .eq('idUser', userId)
            .single();

        if (userResponse != null) {
          final userData = Map<String, dynamic>.from(userResponse);
          debugPrint(
              '✅ WalletService: User data retrieved: ${userData['fullName'] ?? '${userData['firstName']} ${userData['lastName']}'}');

          return {
            'wallet': wallet,
            'user': userData,
          };
        }
      } catch (userError) {
        debugPrint('⚠️ WalletService: Could not fetch user data: $userError');
      }

      debugPrint('⚠️ WalletService: No user data found for: $userId');
      return {
        'wallet': wallet,
        'user': null,
      };
    } catch (e) {
      debugPrint('❌ WalletService: Error getting wallet with user info: $e');
      return null;
    }
  }

  /// Check if user has a wallet using Edge Function
  static Future<bool> hasWallet(String userId) async {
    try {
      final wallet = await getWalletByUserId(userId);
      return wallet != null;
    } catch (e) {
      debugPrint('❌ WalletService: Error checking wallet existence: $e');
      return false;
    }
  }

  /// Test method to verify Edge Function compatibility
  static Future<void> testWalletSchema() async {
    try {
      debugPrint('🔍 WalletService: Testing wallet service compatibility');

      // Test direct database query first
      try {
        debugPrint('🔍 WalletService: Testing direct database query...');
        final directQuery = await _client
            .from('wallet')
            .select(
                'idWallet, idUser, publicAddress, createdAt, updatedAt, createdBy')
            .limit(1);
        debugPrint(
            '✅ WalletService: Direct query successful, found ${directQuery.length} wallets');
        if (directQuery.isNotEmpty) {
          debugPrint('📋 WalletService: Sample wallet: ${directQuery.first}');

          // Test parsing the sample wallet
          try {
            final wallet = WalletModel.fromJson(directQuery.first);
            debugPrint('✅ WalletService: WalletModel parsing successful');
            debugPrint('  - idWallet: ${wallet.idWallet}');
            debugPrint('  - idUser: ${wallet.idUser}');
            debugPrint('  - publicAddress: ${wallet.publicAddress}');
            debugPrint('  - createdAt: ${wallet.createdAt}');
            debugPrint('  - createdBy: ${wallet.createdBy}');
          } catch (parseError) {
            debugPrint(
                '❌ WalletService: WalletModel parsing failed: $parseError');
          }
        }
      } catch (directError) {
        debugPrint('❌ WalletService: Direct query failed: $directError');
      }

      // Test Edge Function with a dummy user ID
      final testUserId = '00000000-0000-0000-0000-000000000000';
      debugPrint(
          '🔍 WalletService: Testing Edge Function with dummy user: $testUserId');

      final wallet = await _getWalletByUserIdEdgeFunction(testUserId);
      if (wallet != null) {
        debugPrint(
            '✅ WalletService: Edge Function returned wallet for test user');
      } else {
        debugPrint(
            '⚠️ WalletService: Edge Function returned null for test user (expected)');
      }

      // Test the main method with fallback
      debugPrint('🔍 WalletService: Testing main method with fallback...');
      final mainResult = await getWalletByUserId(testUserId);
      if (mainResult != null) {
        debugPrint(
            '✅ WalletService: Main method returned wallet for test user');
      } else {
        debugPrint(
            '⚠️ WalletService: Main method returned null for test user (expected)');
      }
    } catch (e) {
      debugPrint('❌ WalletService: Error testing wallet service: $e');
    }
  }
}
