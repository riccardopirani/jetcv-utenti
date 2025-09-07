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

  /// Get wallet by user ID using Edge Function
  static Future<WalletModel?> getWalletByUserId(String userId) async {
    try {
      debugPrint(
          '🔍 WalletService: Getting wallet for user: $userId using Edge Function');

      // Use direct HTTP GET request to ensure GET method is used
      final session = _client.auth.currentSession;
      if (session == null) {
        debugPrint('❌ WalletService: No active session');
        return null;
      }

      final url =
          '${SupabaseConfig.supabaseUrl}/functions/v1/get-wallet-byuser?idUser=$userId';
      debugPrint('🔍 WalletService: Making GET request to: $url');
      debugPrint('🔍 WalletService: User ID: $userId');
      debugPrint(
          '🔍 WalletService: Session token: ${session.accessToken.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.anonKey,
        },
      );

      debugPrint('📋 WalletService: Response status: ${response.statusCode}');
      debugPrint('📋 WalletService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('wallet')) {
          final walletValue = data['wallet'];

          // Handle both array and object responses
          if (walletValue is List) {
            if (walletValue.isEmpty) {
              debugPrint(
                  '⚠️ WalletService: No wallet found for user: $userId (empty array)');
              return null;
            } else {
              // If it's an array with items, take the first one
              final walletData = walletValue.first as Map<String, dynamic>;
              debugPrint('✅ WalletService: Wallet found for user: $userId');
              debugPrint('📋 WalletService: Wallet data: $walletData');
              return WalletModel.fromJson(walletData);
            }
          } else if (walletValue is Map<String, dynamic>) {
            // If it's already an object
            debugPrint('✅ WalletService: Wallet found for user: $userId');
            debugPrint('📋 WalletService: Wallet data: $walletValue');
            return WalletModel.fromJson(walletValue);
          } else {
            debugPrint(
                '⚠️ WalletService: Unexpected wallet data type: ${walletValue.runtimeType}');
            return null;
          }
        } else {
          debugPrint(
              '⚠️ WalletService: Response does not contain wallet data: $data');
          return null;
        }
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ WalletService: No wallet found for user: $userId');
        return null;
      } else {
        debugPrint(
            '❌ WalletService: Edge Function error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ WalletService: Error getting wallet for user $userId: $e');
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
      debugPrint('🔍 WalletService: Testing Edge Function compatibility');

      // First, test if we can query the wallet table directly
      try {
        debugPrint('🔍 WalletService: Testing direct database query...');
        final directQuery = await _client
            .from('wallet')
            .select('idWallet, idUser, publicAddress, createdAt, updatedAt')
            .limit(1);
        debugPrint(
            '✅ WalletService: Direct query successful, found ${directQuery.length} wallets');
        if (directQuery.isNotEmpty) {
          debugPrint('📋 WalletService: Sample wallet: ${directQuery.first}');
        }
      } catch (directError) {
        debugPrint('❌ WalletService: Direct query failed: $directError');
      }

      // Test Edge Function with a dummy user ID to see response structure
      final testUserId = '00000000-0000-0000-0000-000000000000';

      try {
        final session = _client.auth.currentSession;
        if (session == null) {
          debugPrint('❌ WalletService: No active session for test');
          return;
        }

        final url =
            '${SupabaseConfig.supabaseUrl}/functions/v1/get-wallet-byuser?idUser=$testUserId';
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
            'apikey': SupabaseConfig.anonKey,
          },
        );

        debugPrint('📋 WalletService: Edge Function response structure:');
        debugPrint('  - Status: ${response.statusCode}');
        debugPrint('  - Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data.containsKey('wallet')) {
            final walletValue = data['wallet'];

            if (walletValue is List) {
              if (walletValue.isEmpty) {
                debugPrint('📋 WalletService: No wallet found (empty array)');
              } else {
                final walletData = walletValue.first as Map<String, dynamic>;
                debugPrint('📋 WalletService: Wallet data structure:');
                walletData.forEach((key, value) {
                  debugPrint('  - $key: ${value.runtimeType} = $value');
                });

                // Test parsing
                try {
                  final wallet = WalletModel.fromJson(walletData);
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
            } else if (walletValue is Map<String, dynamic>) {
              debugPrint('📋 WalletService: Wallet data structure:');
              walletValue.forEach((key, value) {
                debugPrint('  - $key: ${value.runtimeType} = $value');
              });

              // Test parsing
              try {
                final wallet = WalletModel.fromJson(walletValue);
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
          }
        } else if (response.statusCode == 404) {
          debugPrint(
              '✅ WalletService: Edge Function working correctly (404 for test user)');
        } else {
          debugPrint(
              '⚠️ WalletService: Edge Function returned status ${response.statusCode}');
        }
      } catch (edgeFunctionError) {
        debugPrint(
            '❌ WalletService: Edge Function test failed: $edgeFunctionError');
      }
    } catch (e) {
      debugPrint('❌ WalletService: Error testing Edge Function: $e');
    }
  }
}
