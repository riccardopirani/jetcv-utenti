import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/models/wallet_model.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Service for wallet-related database operations
class WalletService {
  static final _client = SupabaseConfig.client;

  /// Get wallet by user ID using Edge Function
  static Future<WalletModel?> getWalletByUserId(String userId) async {
    try {
      debugPrint(
          '🔍 WalletService: Getting wallet for user: $userId using Edge Function');

      final response = await _client.functions.invoke(
        'get-wallet-byuser',
        body: {'idUser': userId},
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final walletData = data['wallet'] as Map<String, dynamic>;

        debugPrint('✅ WalletService: Wallet found for user: $userId');
        debugPrint('📋 WalletService: Wallet data: $walletData');

        return WalletModel.fromJson(walletData);
      } else if (response.status == 404) {
        debugPrint('⚠️ WalletService: No wallet found for user: $userId');
        return null;
      } else {
        debugPrint(
            '❌ WalletService: Edge Function error ${response.status}: ${response.data}');
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

      // Test Edge Function with a dummy user ID to see response structure
      final testUserId = '00000000-0000-0000-0000-000000000000';

      try {
        final response = await _client.functions.invoke(
          'get-wallet-byuser',
          body: {'idUser': testUserId},
        );

        debugPrint('📋 WalletService: Edge Function response structure:');
        debugPrint('  - Status: ${response.status}');
        debugPrint('  - Data: ${response.data}');

        if (response.status == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          if (data['wallet'] != null) {
            final walletData = data['wallet'] as Map<String, dynamic>;
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
        } else if (response.status == 404) {
          debugPrint(
              '✅ WalletService: Edge Function working correctly (404 for test user)');
        } else {
          debugPrint(
              '⚠️ WalletService: Edge Function returned status ${response.status}');
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
