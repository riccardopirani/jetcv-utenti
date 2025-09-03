import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';
import 'package:jetcv__utenti/widgets/otp_management_widget.dart';

/// Test page to demonstrate OTP functionality
class OtpTestPage extends StatelessWidget {
  const OtpTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        currentRoute: '/otp-test',
        title: 'OTP Test Page',
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OTP Management System',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Test and manage OTP operations using the deployed Supabase function',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),

              // OTP Management Widget
              const OtpManagementWidget(),

              // Information card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Available Operations',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _OperationItem(
                        icon: Icons.add,
                        title: 'Create OTP',
                        description:
                            'Generate a new OTP with custom parameters',
                      ),
                      const _OperationItem(
                        icon: Icons.verified,
                        title: 'Verify OTP',
                        description:
                            'Verify and optionally mark an OTP as used',
                      ),
                      const _OperationItem(
                        icon: Icons.delete,
                        title: 'Burn OTP',
                        description: 'Invalidate an OTP permanently',
                      ),
                      const _OperationItem(
                        icon: Icons.cleaning_services,
                        title: 'Cleanup Expired',
                        description: 'Remove expired OTPs from the system',
                      ),
                      const _OperationItem(
                        icon: Icons.info,
                        title: 'Get Metadata',
                        description:
                            'Retrieve OTP information without sensitive data',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OperationItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B46C1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
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
