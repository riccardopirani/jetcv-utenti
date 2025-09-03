import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/services/open_badge_service.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/models/user_model.dart';

/// Widget per il pulsante di creazione Open Badge
class OpenBadgeButton extends StatefulWidget {
  final UserCertificationDetail certification;
  final bool isCompact;

  const OpenBadgeButton({
    super.key,
    required this.certification,
    this.isCompact = false,
  });

  @override
  State<OpenBadgeButton> createState() => _OpenBadgeButtonState();
}

class _OpenBadgeButtonState extends State<OpenBadgeButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    
      return _buildCompactButton();
   
  }

  Widget _buildCompactButton() {
    return IconButton(
      onPressed: _isLoading ? null : _createOpenBadge,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.workspace_premium, size: 20),
      tooltip: AppLocalizations.of(context)!.createOpenBadge,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildFullButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _createOpenBadge,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.workspace_premium, size: 20),
      label: Text(
        AppLocalizations.of(context)!.createOpenBadge,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _createOpenBadge() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Ottieni i dati dell'utente corrente
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Mostra dialog di conferma
      final shouldProceed = await _showConfirmationDialog(currentUser);
      if (shouldProceed != true) {
        return;
      }

      // Crea l'Open Badge
      final badge = await OpenBadgeService.createBadgeForCertification(
        certification: widget.certification,
        recipientEmail: currentUser.email ?? 'user@example.com',
        recipientName: currentUser.fullName ?? 'User',
      );

      // Condividi il badge
      if (mounted) {
        await OpenBadgeService.shareBadge(
          badge: badge,
          context: context,
        );
      }
    } catch (e) {
      debugPrint('❌ OpenBadgeButton: Error creating badge: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating Open Badge: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmationDialog(UserModel currentUser) {
    final certName =
        widget.certification.certification?.category?.name ?? 'Certification';
    final issuer = widget.certification.certification?.idCertifier ?? 'JetCV';
    final date = widget.certification.certificationUser.createdAt;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createOpenBadge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.openBadgeDescription),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📜 Certification Details:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: $certName'),
                    Text('Issuer: $issuer'),
                    Text('Issue Date: ${date.day}/${date.month}/${date.year}'),
                    const SizedBox(height: 8),
                    Text(
                      'Recipient: ${currentUser.fullName ?? currentUser.email}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.openBadgeBenefits,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.createBadge),
          ),
        ],
      ),
    );
  }
}
