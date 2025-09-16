import 'package:flutter/material.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/screens/home_page_public.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/screens/cv/personal_info_page.dart';
import 'package:jetcv__utenti/screens/cv/cv_view_page.dart';
import 'package:jetcv__utenti/screens/otp/otp_list_page.dart';
import 'package:jetcv__utenti/services/locale_service.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';
import 'package:jetcv__utenti/utils/user_name_utils.dart';

class AuthenticatedHomePage extends StatefulWidget {
  final bool forceRefresh;

  const AuthenticatedHomePage({
    super.key,
    this.forceRefresh = false,
  });

  @override
  State<AuthenticatedHomePage> createState() => _AuthenticatedHomePageState();
}

class _AuthenticatedHomePageState extends State<AuthenticatedHomePage> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Always load user data, but if forceRefresh is true, ensure fresh data
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Set loading state if forcing refresh
    if (widget.forceRefresh && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser != null) {
        final userData = await UserService.getUserById(currentUser.idUser);
        if (userData != null) {
          if (mounted) {
            setState(() {
              _user = userData;
              _isLoading = false;
            });
          }

          // Carica la lingua dal profilo utente se disponibile
          if (userData.languageCodeApp != null) {
            LocaleService.instance
                .loadLanguageFromUserProfile(userData.languageCodeApp);
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Errore nel caricamento dati utente: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    debugPrint('🚪 Starting immediate logout and redirect...');

    if (!mounted) return;

    // Navigate immediately to HomePage
    debugPrint('🔄 Navigating to HomePage immediately...');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomePagePublic(),
      ),
      (route) => false,
    );

    // Execute Supabase logout in background
    _performBackgroundLogout();
  }

  void _performBackgroundLogout() {
    debugPrint('🔧 Performing Supabase logout in background...');

    // Execute logout in background without blocking UI
    SupabaseAuth.signOut().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('❌ Background logout timeout after 10 seconds');
        throw Exception('Timeout durante il logout');
      },
    ).then((_) {
      debugPrint('✅ Background logout successful');
    }).catchError((e) {
      debugPrint('💥 Background logout error: $e');
      // Error is logged but doesn't affect user experience
    });
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

    return MainLayout(
      currentRoute: '/home',
      title: AppLocalizations.of(context)!.home,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserHeader(user: _user, onSignOut: _signOut),
              const SizedBox(height: 30),
              QuickActionsSection(
                user: _user,
                onDataChanged: _loadUserData,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onSignOut;

  const UserHeader({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final userName = UserNameUtils.getUserDisplayName(context, user);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  UserNameUtils.getInitial(context, user),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.welcome,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                    Text(
                      userName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  onPressed: onSignOut,
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Show blockchain verification badge only if user has a CV
          if (user?.hasCv == true)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.verifiedOnBlockchain,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onDataChanged;

  const QuickActionsSection({
    super.key,
    required this.user,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.quickActions,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Wrap per mostrare le card affiancate
          Wrap(
            spacing: 16, // Spazio orizzontale tra le card
            runSpacing: 16, // Spazio verticale tra le righe
            children: [
              // Card CV (Nuova o Visualizza)
              if (user?.hasCv == false)
                SizedBox(
                  width: MediaQuery.of(context).size.width < 768
                      ? double.infinity
                      : (MediaQuery.of(context).size.width - 80) /
                          2, // 80 = padding + spacing
                  child: QuickActionCard(
                    icon: Icons.add_circle_outline,
                    title: AppLocalizations.of(context)!.newCV,
                    subtitle: AppLocalizations.of(context)!.createYourDigitalCV,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PersonalInfoPage(initialUser: user),
                        ),
                      )
                          .then((result) {
                        if (result == true) {
                          // Ricarica i dati utente se sono stati aggiornati
                          onDataChanged();
                        }
                      });
                    },
                  ),
                )
              else if (user?.hasCv == true)
                SizedBox(
                  width: MediaQuery.of(context).size.width < 768
                      ? double.infinity
                      : (MediaQuery.of(context).size.width - 80) /
                          2, // 80 = padding + spacing
                  child: QuickActionCard(
                    icon: Icons.visibility,
                    title: AppLocalizations.of(context)!.viewMyCV,
                    subtitle: AppLocalizations.of(context)!.yourDigitalCV,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CVViewPage(cvUserId: user?.idUser),
                        ),
                      );
                    },
                  ),
                ),

              // OTP Card
              SizedBox(
                width: MediaQuery.of(context).size.width < 768
                    ? double.infinity
                    : (MediaQuery.of(context).size.width - 80) /
                        2, // 80 = padding + spacing
                child: QuickActionCard(
                  icon: Icons.key,
                  title: AppLocalizations.of(context)!.myOtps,
                  subtitle:
                      AppLocalizations.of(context)!.manageSecureAccessCodes,
                  color: const Color(0xFF6B46C1),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OtpListPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final UserModel? user;

  const CustomBottomNavigationBar({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomNavItem(
                icon: Icons.home,
                label: AppLocalizations.of(context)!.home,
                isSelected: true,
                onTap: () {},
              ),
              BottomNavItem(
                icon: Icons.description,
                label: AppLocalizations.of(context)!.cv,
                isSelected: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CVViewPage(cvUserId: user?.idUser),
                    ),
                  );
                },
              ),
              BottomNavItem(
                icon: Icons.key,
                label: AppLocalizations.of(context)!.otp,
                isSelected: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OtpListPage(),
                    ),
                  );
                },
              ),
              BottomNavItem(
                icon: Icons.person,
                label: AppLocalizations.of(context)!.profile,
                isSelected: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PersonalInfoPage(initialUser: user),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
