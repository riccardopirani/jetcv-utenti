import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/services/open_badge_service.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';

class OpenBadgesPage extends StatefulWidget {
  const OpenBadgesPage({Key? key}) : super(key: key);

  @override
  State<OpenBadgesPage> createState() => _OpenBadgesPageState();
}

class _OpenBadgesPageState extends State<OpenBadgesPage> {
  List<OpenBadgeModel> _openBadges = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _highlightedBadgeId;

  // Riferimenti salvati per evitare errori di contesto invalidato
  ScaffoldMessengerState? _scaffoldMessenger;
  AppLocalizations? _localizations;

  @override
  void initState() {
    super.initState();
    _loadOpenBadges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _localizations = AppLocalizations.of(context);
  }

  Future<void> _loadOpenBadges() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await OpenBadgeService.getUserOpenBadges(userId);

      if (response.success && response.data != null) {
        setState(() {
          _openBadges = response.data!;
          _isLoading = false;
        });
        debugPrint('✅ Loaded ${_openBadges.length} OpenBadges');
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load OpenBadges';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading OpenBadges: $e';
        _isLoading = false;
      });
      debugPrint('❌ Error loading OpenBadges: $e');
    }
  }

  Future<void> _importOpenBadge() async {
    try {
      // For now, show a dialog to manually enter JSON
      final jsonText = await _showJsonInputDialog();
      if (jsonText != null && jsonText.isNotEmpty) {
        // Parse OpenBadge JSON
        final parseResponse =
            await OpenBadgeService.parseOpenBadgeFromFile(jsonText);

        if (!parseResponse.success) {
          _showSnackBar(parseResponse.error ?? 'Failed to parse OpenBadge');
          return;
        }

        // Show import dialog
        final imported = await _showImportDialog(parseResponse.data!);
        if (imported) {
          await _loadOpenBadges();
        }
      }
    } catch (e) {
      _showSnackBar('Error importing OpenBadge: $e');
      debugPrint('❌ Error importing OpenBadge: $e');
    }
  }

  Future<String?> _showJsonInputDialog() async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localizations?.importOpenBadge ?? 'Import OpenBadge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Paste your OpenBadge JSON here:'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '{"@context": "https://w3id.org/openbadges/v2", ...}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizations?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(_localizations?.import ?? 'Import'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showImportDialog(Map<String, dynamic> assertionJson) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) =>
              ImportOpenBadgeDialog(assertionJson: assertionJson),
        ) ??
        false;
  }

  void _showSnackBar(String message) {
    if (_scaffoldMessenger != null && mounted) {
      _scaffoldMessenger!.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              message.contains('Error') || message.contains('Failed')
                  ? Colors.red
                  : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      appBar: AppBar(
        title: Text(_localizations?.openBadges ?? 'Open Badges'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _importOpenBadge,
            icon: Icon(Icons.upload_file),
            tooltip: _localizations?.importOpenBadge ?? 'Import OpenBadge',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _buildBody(isMobile, isTablet),
      ),
    );
  }

  Widget _buildBody(bool isMobile, bool isTablet) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_openBadges.isEmpty) {
      return _buildEmptyState();
    }

    return _buildOpenBadgesList(isMobile, isTablet);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          SizedBox(height: 16),
          Text(
            _localizations?.loadingOpenBadges ?? 'Loading Open Badges...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16),
            Text(
              _localizations?.errorLoadingOpenBadges ??
                  'Error Loading Open Badges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOpenBadges,
              icon: Icon(Icons.refresh),
              label: Text(_localizations?.retry ?? 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 64,
              color: Colors.blue.shade300,
            ),
            SizedBox(height: 16),
            Text(
              _localizations?.noOpenBadgesFound ?? 'No Open Badges Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _localizations?.noOpenBadgesDescription ??
                  'Import your first OpenBadge to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _importOpenBadge,
              icon: Icon(Icons.upload_file),
              label:
                  Text(_localizations?.importOpenBadge ?? 'Import OpenBadge'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenBadgesList(bool isMobile, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _localizations?.openBadges ?? 'Open Badges',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '${_openBadges.length} ${_localizations?.badges ?? 'badges'}',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // OpenBadges Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.2 : 1.0,
            ),
            itemCount: _openBadges.length,
            itemBuilder: (context, index) {
              final badge = _openBadges[index];
              return _buildOpenBadgeCard(badge, isMobile, isTablet);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOpenBadgeCard(
      OpenBadgeModel badge, bool isMobile, bool isTablet) {
    final isHighlighted = _highlightedBadgeId == badge.idOpenBadge;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? Colors.blue.shade300 : Colors.grey.shade200,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Image and Status
            Row(
              children: [
                // Badge Image
                Container(
                  width: isMobile ? 48 : 56,
                  height: isMobile ? 48 : 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: badge.badgeImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            badge.badgeImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.workspace_premium,
                                color: Colors.blue.shade400,
                                size: isMobile ? 24 : 28,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.workspace_premium,
                          color: Colors.blue.shade400,
                          size: isMobile ? 24 : 28,
                        ),
                ),
                SizedBox(width: 12),

                // Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badge.isValid
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge.isValid
                                  ? (_localizations?.valid ?? 'Valid')
                                  : (_localizations?.invalid ?? 'Invalid'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: badge.isValid
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                          if (badge.isRevoked) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _localizations?.revoked ?? 'Revoked',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Badge Name
            Text(
              badge.badgeName,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8),

            // Issuer
            Text(
              badge.issuerName,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8),

            // Description
            Text(
              badge.badgeDescription,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey.shade500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            Spacer(),

            // Dates
            if (badge.issuedAt != null || badge.expiresAt != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  if (badge.issuedAt != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${badge.issuedAt!.day}/${badge.issuedAt!.month}/${badge.issuedAt!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  if (badge.expiresAt != null) ...[
                    SizedBox(width: 16),
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${badge.expiresAt!.day}/${badge.expiresAt!.month}/${badge.expiresAt!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ImportOpenBadgeDialog extends StatefulWidget {
  final Map<String, dynamic> assertionJson;

  const ImportOpenBadgeDialog({
    Key? key,
    required this.assertionJson,
  }) : super(key: key);

  @override
  State<ImportOpenBadgeDialog> createState() => _ImportOpenBadgeDialogState();
}

class _ImportOpenBadgeDialogState extends State<ImportOpenBadgeDialog> {
  final _noteController = TextEditingController();
  final _sourceController = TextEditingController();
  bool _isImporting = false;

  @override
  void dispose() {
    _noteController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _importBadge() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await OpenBadgeService.importOpenBadge(
        userId: userId,
        assertionJson: widget.assertionJson,
        source:
            _sourceController.text.isNotEmpty ? _sourceController.text : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (response.success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to import OpenBadge'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing OpenBadge: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Extract badge info
    final badgeName = widget.assertionJson['badge']?['name'] as String? ??
        widget.assertionJson['name'] as String? ??
        'Unknown Badge';
    final issuerName =
        widget.assertionJson['badge']?['issuer']?['name'] as String? ??
            widget.assertionJson['issuer']?['name'] as String? ??
            'Unknown Issuer';

    return AlertDialog(
      title: Text(localizations?.importOpenBadge ?? 'Import OpenBadge'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badgeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    issuerName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Source field
            TextField(
              controller: _sourceController,
              decoration: InputDecoration(
                labelText: localizations?.source ?? 'Source (optional)',
                hintText: 'e.g., Mozilla Backpack, Credly',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // Note field
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: localizations?.note ?? 'Note (optional)',
                hintText: 'Add a personal note about this badge',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isImporting ? null : () => Navigator.of(context).pop(false),
          child: Text(localizations?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _isImporting ? null : _importBadge,
          child: _isImporting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(localizations?.import ?? 'Import'),
        ),
      ],
    );
  }
}
