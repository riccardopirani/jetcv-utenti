import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';
import 'package:jetcv__utenti/widgets/certification_card.dart' as reusable;

class MyCertificationsPage extends StatefulWidget {
  const MyCertificationsPage({super.key});

  @override
  State<MyCertificationsPage> createState() => _MyCertificationsPageState();
}

class _MyCertificationsPageState extends State<MyCertificationsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  List<UserCertificationDetail> _certifications = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCertifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCertifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await CertificationService.getUserCertificationsDetails();

      if (response.success) {
        final certifications = response.data ?? [];

        // Print complete certifications list to console
        _printCertificationsList(certifications);

        setState(() {
          _certifications = certifications;
          _isLoading = false;
        });

        // Set default tab after loading data
        _setDefaultTab();
      } else {
        setState(() {
          _error = response.error ?? 'Unknown error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  List<UserCertificationDetail> _getCertificationsByStatus(String status) {
    return _certifications
        .where((cert) => cert.certificationUser.status == status)
        .toList();
  }

  List<UserCertificationDetail> _getPendingCertifications() {
    return _certifications
        .where((c) =>
            c.certificationUser.status == 'pending' ||
            c.certificationUser.status == 'draft')
        .toList();
  }

  List<UserCertificationDetail> _getApprovedCertifications() {
    return _getCertificationsByStatus('accepted');
  }

  List<UserCertificationDetail> _getRejectedCertifications() {
    return _getCertificationsByStatus('rejected');
  }

  void _printCertificationsList(List<UserCertificationDetail> certifications) {
    print('\n' + '=' * 80);
    print(
        '📋 ELENCO COMPLETO CERTIFICAZIONI (${certifications.length} totali)');
    print('=' * 80);

    if (certifications.isEmpty) {
      print('❌ Nessuna certificazione trovata');
      print('=' * 80 + '\n');
      return;
    }

    for (int i = 0; i < certifications.length; i++) {
      // final cert = certifications[i];
      // final certUser = cert.certificationUser;
      // final certification = cert.certification;
      // final category = certification?.category;
      // final legalEntity = certification?.legalEntity;
      // final location = certification?.location;
      // final certifier = certification?.certifier;

      // print('\n📄 CERTIFICAZIONE #${i + 1}');
      // print('-' * 40);

      // Basic certification user info
      // print('🆔 ID Certificazione Utente: ${certUser.idCertificationUser}');
      // print('📊 Stato: ${certUser.status.toUpperCase()}');
      // print(
      //     '📅 Creata il: ${certUser.createdAt.toLocal().toString().split('.')[0]}');
      // if (certUser.updatedAt != null) {
      //   print(
      //       '🔄 Aggiornata il: ${certUser.updatedAt!.toLocal().toString().split('.')[0]}');
      // }
      // if (certUser.serialNumber != null) {
      //   print('🏷️ Numero Seriale: ${certUser.serialNumber}');
      // }
      // if (certUser.rejectionReason != null) {
      //   print('❌ Motivo Rifiuto: ${certUser.rejectionReason}');
      // }

      // Category information
      // if (category != null) {
      //   print('\n🏷️ CATEGORIA:');
      //   print('  • Nome: ${category.name}');
      //   print('  • ID: ${category.idCertificationCategory}');
      //   print('  • Tipo: ${category.type ?? 'N/A'}');
      //   print('  • Ordine: ${category.order ?? 'N/A'}');
      //   if (category.pictureUrl != null && category.pictureUrl!.isNotEmpty) {
      //     print('  • 🖼️ Immagine: ${category.pictureUrl}');
      //   } else {
      //     print('  • 🖼️ Immagine: Non disponibile');
      //   }
      // }

      // Legal entity information
      // if (legalEntity != null) {
      //   print('\n🏢 ENTE LEGALE:');
      //   print('  • Nome: ${legalEntity.legalName ?? 'N/A'}');
      //   print('  • ID: ${legalEntity.idLegalEntity}');
      //   if (legalEntity.logoPicture != null &&
      //       legalEntity.logoPicture!.isNotEmpty) {
      //     print('  • 🖼️ Logo: ${legalEntity.logoPicture}');
      //   }
      //   if (legalEntity.website != null && legalEntity.website!.isNotEmpty) {
      //     print('  • 🌐 Sito Web: ${legalEntity.website}');
      //   }
      // }

      // Certifier information
      // if (certifier != null) {
      //   print('\n👤 CERTIFICATORE:');
      //   print('  • Nome Completo: ${certifier.displayName}');
      //   print('  • ID: ${certifier.idCertifier}');
      //   if (certifier.user != null) {
      //     final user = certifier.user!;
      //     print('  • Email: ${user.email ?? 'N/A'}');
      //     print('  • Nome: ${user.firstName ?? 'N/A'}');
      //     print('  • Cognome: ${user.lastName ?? 'N/A'}');
      //   }
      // }

      // Location information
      // if (location != null) {
      //   print('\n📍 UBICAZIONE:');
      //   if (location.name != null && location.name!.isNotEmpty) {
      //     print('  • Nome: ${location.name}');
      //   }
      //   if (location.locality != null && location.locality!.isNotEmpty) {
      //     print('  • Città: ${location.locality}');
      //   }
      //   if (location.country != null && location.country!.isNotEmpty) {
      //     print('  • Paese: ${location.country}');
      //   }
      //   if (location.thoroughfare != null &&
      //       location.thoroughfare!.isNotEmpty) {
      //     print('  • Via: ${location.thoroughfare}');
      //   }
      // }

      // Certification details
      // if (certification != null) {
      //   print('\n📜 DETTAGLI CERTIFICAZIONE:');
      //   print('  • ID Certificazione: ${certification.idCertification}');
      //   print('  • Stato Certificazione: ${certification.status}');
      //   if (certification.serialNumber != null) {
      //     print('  • Numero Seriale: ${certification.serialNumber}');
      //   }
      //   if (certification.sentAt != null) {
      //     print(
      //         '  • Inviata il: ${certification.sentAt!.toLocal().toString().split('.')[0]}');
      //   }
      //   if (certification.closedAt != null) {
      //     print(
      //         '  • Chiusa il: ${certification.closedAt!.toLocal().toString().split('.')[0]}');
      //   }
      //   if (certification.nUsers != null) {
      //     print('  • Numero Utenti: ${certification.nUsers}');
      //   }
      // }

      // Media information
      // final totalMedia =
      //     cert.media.directMedia.length + cert.media.linkedMedia.length;
      // if (totalMedia > 0) {
      //   print('\n🖼️ MEDIA (${totalMedia} totali):');
      //   print('  • Media Diretti: ${cert.media.directMedia.length}');
      //   print('  • Media Collegati: ${cert.media.linkedMedia.length}');
      // }

      // print('-' * 40);
    }

    // Summary statistics
    // final pendingCount = certifications
    //     .where((c) =>
    //         c.certificationUser.status == 'pending' ||
    //         c.certificationUser.status == 'draft')
    //     .length;
    // final approvedCount = certifications
    //     .where((c) => c.certificationUser.status == 'accepted')
    //     .length;
    // final rejectedCount = certifications
    //     .where((c) => c.certificationUser.status == 'rejected')
    //     .length;

    // print('\n📊 STATISTICHE RIASSUNTIVE:');
    // print('  • 🟡 In Attesa: $pendingCount');
    // print('  • 🟢 Approvate: $approvedCount');
    // print('  • 🔴 Rifiutate: $rejectedCount');
    // print('  • 📊 Totale: ${certifications.length}');

    // print('=' * 80 + '\n');
  }

  void _setDefaultTab() {
    final pendingCount = _getPendingCertifications().length;
    final approvedCount = _getApprovedCertifications().length;

    if (pendingCount > 0) {
      // Show pending tab if there are pending certifications
      _tabController.animateTo(0);
    } else if (approvedCount > 0) {
      // Show approved tab if no pending but there are approved
      _tabController.animateTo(1);
    } else {
      // Show rejected tab as last resort
      _tabController.animateTo(2);
    }
  }

  Future<void> _approveCertification(String idCertificationUser) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final response = await CertificationService.approve(idCertificationUser);

      if (response.success) {
        _showSnackBar(localizations.certificationApproved, isError: false);
        await _loadCertifications(); // Reload data
      } else {
        _showSnackBar(
            localizations
                .errorApprovingCertification(response.error ?? 'Unknown error'),
            isError: true);
      }
    } catch (e) {
      _showSnackBar(localizations.errorApprovingCertification(e.toString()),
          isError: true);
    }
  }

  Future<void> _rejectCertification(String idCertificationUser,
      {String? rejectionReason}) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final response = await CertificationService.reject(
        idCertificationUser,
        rejectionReason: rejectionReason,
      );

      if (response.success) {
        _showSnackBar(localizations.certificationRejected, isError: false);
        await _loadCertifications(); // Reload data
      } else {
        _showSnackBar(
            localizations
                .errorRejectingCertification(response.error ?? 'Unknown error'),
            isError: true);
      }
    } catch (e) {
      _showSnackBar(localizations.errorRejectingCertification(e.toString()),
          isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showRejectionDialog(String idCertificationUser) async {
    final localizations = AppLocalizations.of(context)!;
    String? rejectionReason;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmRejection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.rejectCertificationMessage),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: localizations.rejectionReason,
                hintText: localizations.enterRejectionReason,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => rejectionReason = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.confirmReject),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _rejectCertification(idCertificationUser,
          rejectionReason: rejectionReason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return MainLayout(
      currentRoute: '/certifications',
      title: localizations.myCertifications,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _certifications.isEmpty
                  ? _buildEmptyView()
                  : _buildTabView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadCertifications,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Riprova'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            localizations.noCertificationsFound,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCertifications,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Ricarica'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTabBar(
    AppLocalizations localizations,
    List<UserCertificationDetail> pendingCertifications,
    List<UserCertificationDetail> approvedCertifications,
    List<UserCertificationDetail> rejectedCertifications,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 600;
        final isVerySmallScreen = screenWidth < 400;

        return TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          isScrollable: false, // Always fill the available space
          tabAlignment: TabAlignment.fill, // Always fill uniformly
          labelPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          tabs: [
            _buildResponsiveTab(
              icon: Icons.pending,
              text: localizations.pendingShort,
              count: pendingCertifications.length,
              badgeColor: Colors.orange,
              isSmallScreen: isSmallScreen,
              isVerySmallScreen: isVerySmallScreen,
            ),
            _buildResponsiveTab(
              icon: Icons.check_circle,
              text: localizations.approvedShort,
              count: 0, // No badge for approved certifications
              badgeColor: Colors.green,
              isSmallScreen: isSmallScreen,
              isVerySmallScreen: isVerySmallScreen,
            ),
            _buildResponsiveTab(
              icon: Icons.cancel,
              text: localizations.rejectedShort,
              count: 0, // No badge for rejected certifications
              badgeColor: Colors.red,
              isSmallScreen: isSmallScreen,
              isVerySmallScreen: isVerySmallScreen,
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveTab({
    required IconData icon,
    required String text,
    required int count,
    required Color badgeColor,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
  }) {
    if (isVerySmallScreen) {
      // Very small screens: only icon and badge
      return Tab(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 20),
            if (count > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (isSmallScreen) {
      // Small screens: vertical layout with icon, text and badge
      return Tab(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20),
                if (count > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    }

    // Large screens: horizontal layout with icon, text and badge
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabView() {
    final localizations = AppLocalizations.of(context)!;
    final pendingCertifications = _getPendingCertifications();
    final approvedCertifications = _getApprovedCertifications();
    final rejectedCertifications = _getRejectedCertifications();

    return Column(
      children: [
        _buildResponsiveTabBar(
          localizations,
          pendingCertifications,
          approvedCertifications,
          rejectedCertifications,
        ),
        const SizedBox(
            height: 24), // Added margin between TabBar and TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildTabContent(
                pendingCertifications,
                showActions: true,
                tabTitle: 'Certificazioni ${localizations.pendingShort}',
              ),
              _buildTabContent(
                approvedCertifications,
                showActions: false,
                tabTitle: 'Certificazioni ${localizations.approvedShort}',
              ),
              _buildTabContent(
                rejectedCertifications,
                showActions: false,
                showRejectionReason: true,
                tabTitle: 'Certificazioni ${localizations.rejectedShort}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(
    List<UserCertificationDetail> certifications, {
    bool showActions = false,
    bool showRejectionReason = false,
    String? tabTitle,
  }) {
    if (certifications.isEmpty) {
      return _buildEmptyTabContent(tabTitle: tabTitle);
    }

    return RefreshIndicator(
      onRefresh: _loadCertifications,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header with title and count
          if (tabTitle != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              tabTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${certifications.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Certification cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cert = certifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: reusable.CertificationCard(
                      certification: cert,
                      // Uniforma alla card standard usata in cv_view_page.dart
                      showImageHeader: true,
                      showLegalEntityLogo: true,
                      showMediaSection: true,
                      showOpenBadgeButton: true,
                      showCertifiedUserName:
                          true, // Show certified user name in certifications page
                      // Azioni solo per la tab In attesa
                      showActions: showActions,
                      showRejectionReason: showRejectionReason,
                      onApprove: showActions
                          ? () => _approveCertification(
                              cert.certificationUser.idCertificationUser)
                          : null,
                      onReject: showActions
                          ? () => _showRejectionDialog(
                              cert.certificationUser.idCertificationUser)
                          : null,
                    ),
                  );
                },
                childCount: certifications.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTabContent({String? tabTitle}) {
    return Column(
      children: [
        // Header with title and count (0)
        if (tabTitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tabTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '0',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Empty state content
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Nessuna certificazione in questa categoria',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Deprecated local embedded card replaced by reusable widget in widgets/certification_card.dart
