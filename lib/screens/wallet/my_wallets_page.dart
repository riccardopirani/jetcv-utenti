import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/services/wallet_service.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/models/wallet_model.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';

class MyWalletsPage extends StatefulWidget {
  const MyWalletsPage({super.key});

  @override
  State<MyWalletsPage> createState() => _MyWalletsPageState();
}

class _MyWalletsPageState extends State<MyWalletsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _walletData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Test wallet schema compatibility
      await WalletService.testWalletSchema();

      // Get current user
      final user = await UserService.getCurrentUser();
      if (user == null) {
        setState(() {
          _error = 'User not found';
          _isLoading = false;
        });
        return;
      }

      // Get wallet data with user info
      final walletData = await WalletService.getWalletWithUserInfo(user.idUser);

      setState(() {
        _walletData = walletData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _copyAddress(String address) async {
    try {
      await Clipboard.setData(ClipboardData(text: address));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addressCopied),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error copying address: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 4)}...${address.substring(address.length - 4)}';
  }

  String _getUserDisplayName(Map<String, dynamic>? userData) {
    if (userData == null) return 'Unknown User';

    if (userData['fullName'] != null &&
        userData['fullName'].toString().isNotEmpty) {
      return userData['fullName'];
    }

    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    }

    return 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return MainLayout(
      currentRoute: '/wallets',
      title: l10n.myWallets,
      child: Container(
        color: Colors.grey[50],
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState(l10n, theme)
                : _walletData == null
                    ? _buildNoWalletState(l10n, theme)
                    : _buildWalletContent(l10n, theme, isMobile),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading wallet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadWalletData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWalletState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noWalletFound,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.walletNotFoundDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadWalletData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletContent(
      AppLocalizations l10n, ThemeData theme, bool isMobile) {
    final wallet = _walletData!['wallet'] as WalletModel;
    final userData = _walletData!['user'] as Map<String, dynamic>?;
    final userName = _getUserDisplayName(userData);
    final formattedAddress = _formatAddress(wallet.publicAddress);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main title and subtitle
          Text(
            l10n.myWallets,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.viewYourDigitalWallets,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Wallet card
          _buildWalletCard(
              l10n, theme, wallet, userName, formattedAddress, isMobile),
        ],
      ),
    );
  }

  Widget _buildWalletCard(
    AppLocalizations l10n,
    ThemeData theme,
    WalletModel wallet,
    String userName,
    String formattedAddress,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF1E3A8A), // Deep blue
            Color(0xFF0EA5E9), // Light blue/teal
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet title
          Text(
            l10n.wallet,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            l10n.walletDescription,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Owner section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.owner,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Wallet icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Wallet address section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.walletAddress,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Copy button
              GestureDetector(
                onTap: () => _copyAddress(wallet.publicAddress),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
