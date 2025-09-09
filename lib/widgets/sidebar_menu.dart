import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/screens/cv/cv_view_page.dart';
import 'package:jetcv__utenti/screens/home/home_page.dart';
import 'package:jetcv__utenti/screens/otp/otp_list_page.dart';
import 'package:jetcv__utenti/screens/cv/personal_info_page.dart';
import 'package:jetcv__utenti/screens/wallet/my_wallets_page.dart';

class SidebarMenu extends StatefulWidget {
  final VoidCallback? onClose;
  final String? currentRoute;

  const SidebarMenu({
    super.key,
    this.onClose,
    this.currentRoute,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.errorDuringLogout(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    // TODO: Implement account deletion
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.accountDeletionNotImplemented),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _navigateTo(String route) {
    widget.onClose?.call();

    // Navigate based on route
    switch (route) {
      case '/home':
        // Navigate to home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
        break;
      case '/profile':
        // Navigate to personal info page (profile)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PersonalInfoPage(),
          ),
        );
        break;
      case '/cv':
        // Navigate to CV page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CVViewPage(cvUserId: _currentUser?.idUser),
          ),
        );
        break;
      case '/certifications':
        // Navigate to CV page (certifications are shown there)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CVViewPage(cvUserId: _currentUser?.idUser),
          ),
        );
        break;
      case '/otp':
        // Navigate to OTP list page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OtpListPage(),
          ),
        );
        break;
      case '/wallets':
        // Navigate to wallets page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MyWalletsPage(),
          ),
        );
        break;
      default:
        // Do nothing for unknown routes
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    // Theme-aware colors
    final sidebarColor = colorScheme.primaryContainer;
    final sidebarOnColor = colorScheme.onPrimaryContainer;
    final accentColor = colorScheme.primary;

    // Responsive sizing
    final sidebarWidth = isMobile
        ? 280.0
        : isTablet
            ? 300.0
            : 320.0;
    final headerPadding = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;
    final iconSize = isMobile
        ? 20.0
        : isTablet
            ? 22.0
            : 24.0;
    final titleFontSize = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;
    final iconPadding = isMobile
        ? 6.0
        : isTablet
            ? 7.0
            : 8.0;

    return Container(
      width: sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: sidebarColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Header
          Container(
            padding: EdgeInsets.all(headerPadding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.rocket_launch,
                    color: colorScheme.onPrimary,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: TextStyle(
                      color: sidebarOnColor,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // User Profile Section
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile
                  ? 16
                  : isTablet
                      ? 18
                      : 20,
              vertical: isMobile ? 12 : 16,
            ),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: sidebarOnColor,
                      strokeWidth: isMobile ? 1.5 : 2,
                    ),
                  )
                : _currentUser != null
                    ? Row(
                        children: [
                          Container(
                            width: isMobile
                                ? 40
                                : isTablet
                                    ? 45
                                    : 50,
                            height: isMobile
                                ? 40
                                : isTablet
                                    ? 45
                                    : 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sidebarOnColor.withValues(alpha: 0.3),
                                width: isMobile ? 1.5 : 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _currentUser!.profilePicture != null
                                  ? Image.network(
                                      _currentUser!.profilePicture!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        color: sidebarOnColor.withValues(
                                            alpha: 0.7),
                                        size: isMobile
                                            ? 20
                                            : isTablet
                                                ? 22
                                                : 24,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      color:
                                          sidebarOnColor.withValues(alpha: 0.7),
                                      size: isMobile
                                          ? 20
                                          : isTablet
                                              ? 22
                                              : 24,
                                    ),
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_currentUser!.firstName ?? ''} ${_currentUser!.lastName ?? ''}'
                                      .trim(),
                                  style: TextStyle(
                                    color: sidebarOnColor,
                                    fontSize: isMobile
                                        ? 14
                                        : isTablet
                                            ? 15
                                            : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: isMobile ? 1 : 2),
                                Text(
                                  _currentUser!.email ?? '',
                                  style: TextStyle(
                                    color:
                                        sidebarOnColor.withValues(alpha: 0.7),
                                    fontSize: isMobile
                                        ? 10
                                        : isTablet
                                            ? 11
                                            : 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        child: Text(
                          AppLocalizations.of(context)!.userNotLoaded,
                          style: TextStyle(
                            color: sidebarOnColor.withValues(alpha: 0.7),
                            fontSize: isMobile
                                ? 12
                                : isTablet
                                    ? 13
                                    : 14,
                          ),
                        ),
                      ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8),
              children: [
                _buildMenuItem(
                  icon: Icons.home,
                  title: localizations.home,
                  route: '/home',
                ),
                _buildMenuItem(
                  icon: Icons.person,
                  title: localizations.myProfile,
                  route: '/profile',
                ),
                _buildMenuItem(
                  icon: Icons.description,
                  title: localizations.myCV,
                  route: '/cv',
                ),
                _buildMenuItem(
                  icon: Icons.verified,
                  title: localizations.myCertifications,
                  route: '/certifications',
                ),
                _buildMenuItem(
                  icon: Icons.key,
                  title: localizations.otp,
                  route: '/otp',
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet,
                  title: localizations.myWallets,
                  route: '/wallets',
                ),
              ],
            ),
          ),

          // Separator
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(
                horizontal: isMobile
                    ? 16
                    : isTablet
                        ? 18
                        : 20),
            color: sidebarOnColor.withValues(alpha: 0.2),
          ),

          // Action Items
          Padding(
            padding: EdgeInsets.all(isMobile
                ? 16
                : isTablet
                    ? 18
                    : 20),
            child: Column(
              children: [
                _buildActionItem(
                  icon: Icons.person_remove,
                  title: localizations.deleteAccount,
                  isDestructive: true,
                  onTap: _deleteAccount,
                ),
                SizedBox(height: isMobile ? 6 : 8),
                _buildActionItem(
                  icon: Icons.logout,
                  title: localizations.logout,
                  isDestructive: false,
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final isSelected = widget.currentRoute == route;

    // Theme-aware colors
    final sidebarOnColor = colorScheme.onPrimaryContainer;
    final selectedColor = colorScheme.primary.withValues(alpha: 0.15);

    // Responsive sizing
    final iconSize = isMobile
        ? 18.0
        : isTablet
            ? 19.0
            : 20.0;
    final fontSize = isMobile
        ? 13.0
        : isTablet
            ? 13.5
            : 14.0;
    final horizontalPadding = isMobile
        ? 10.0
        : isTablet
            ? 11.0
            : 12.0;
    final verticalPadding = isMobile
        ? 10.0
        : isTablet
            ? 11.0
            : 12.0;
    final spacing = isMobile
        ? 10.0
        : isTablet
            ? 11.0
            : 12.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 1 : 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateTo(route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : sidebarOnColor,
                  size: iconSize,
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? colorScheme.primary : sidebarOnColor,
                      fontSize: fontSize,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required bool isDestructive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    // Theme-aware colors
    final sidebarOnColor = colorScheme.onPrimaryContainer;
    final destructiveColorLight = colorScheme.error.withValues(alpha: 0.7);

    // Responsive sizing
    final iconSize = isMobile
        ? 18.0
        : isTablet
            ? 19.0
            : 20.0;
    final fontSize = isMobile
        ? 13.0
        : isTablet
            ? 13.5
            : 14.0;
    final horizontalPadding = isMobile
        ? 10.0
        : isTablet
            ? 11.0
            : 12.0;
    final verticalPadding = isMobile
        ? 10.0
        : isTablet
            ? 11.0
            : 12.0;
    final spacing = isMobile
        ? 10.0
        : isTablet
            ? 11.0
            : 12.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? destructiveColorLight : sidebarOnColor,
                size: iconSize,
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color:
                        isDestructive ? destructiveColorLight : sidebarOnColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
