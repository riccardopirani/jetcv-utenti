import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';
import 'package:jetcv__utenti/screens/cv/personal_info_page.dart';
import 'package:jetcv__utenti/screens/cv/cv_view_page.dart';
import 'package:jetcv__utenti/screens/otp/otp_list_page.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _currentUser;

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
        });
      }
    } catch (e) {
      // Error is handled silently, user can still navigate
    }
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PersonalInfoPage(),
      ),
    );
  }

  void _navigateToCV() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CVViewPage(cvUserId: _currentUser?.idUser),
      ),
    );
  }

  void _navigateToCertifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CVViewPage(cvUserId: _currentUser?.idUser),
      ),
    );
  }

  void _navigateToOTP() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OtpListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return MainLayout(
      currentRoute: '/home',
      title: localizations.home,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Text(
              localizations.quickActions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.person,
                  title: localizations.myProfile,
                  subtitle: localizations.enterYourPersonalInfo,
                  color: Colors.green,
                  onTap: _navigateToProfile,
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.description,
                  title: localizations.myCV,
                  subtitle: localizations.yourDigitalCV,
                  color: Colors.blue,
                  onTap: _navigateToCV,
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.verified,
                  title: localizations.myCertifications,
                  subtitle: localizations.blockchainVerification,
                  color: Colors.orange,
                  onTap: _navigateToCertifications,
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.key,
                  title: localizations.otp,
                  subtitle: localizations.manageSecureAccessCodes,
                  color: Colors.purple,
                  onTap: _navigateToOTP,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 180,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
