import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/services/certification_service.dart';

class BlockchainInfoPage extends StatelessWidget {
  final CvModel cv;
  final UserCertificationDetail certification;

  const BlockchainInfoPage({
    super.key,
    required this.cv,
    required this.certification,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          localizations.blockchainCertificate,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green.shade800),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Polygon logo and title
            _buildHeader(context, isMobile),
            const SizedBox(height: 24),

            // Transaction ID section
            _buildTransactionSection(context, isMobile),
            const SizedBox(height: 24),

            // NFT Information section
            _buildNftInfoSection(context, isMobile),
            const SizedBox(height: 24),

            // Mint Information section
            _buildMintInfoSection(context, isMobile),
            const SizedBox(height: 24),

            // Certificate Details section
            _buildCertificateDetailsSection(context, isMobile),
            const SizedBox(height: 24),

            // Blockchain Verification section
            _buildVerificationSection(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Polygon logo
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/images/polygon-logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.blockchainCertificate,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.verifiedOnPolygonNetwork,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.green.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSection(BuildContext context, bool isMobile) {
    final localizations = AppLocalizations.of(context)!;

    // Extract transaction ID from URL
    String transactionId = 'N/A';
    if (cv.nftMintTransactionUrl != null &&
        cv.nftMintTransactionUrl!.isNotEmpty) {
      final uri = Uri.tryParse(cv.nftMintTransactionUrl!);
      if (uri != null) {
        // Extract transaction hash from URL (usually the last segment)
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          transactionId = segments.last;
        }
      }
    }

    return _buildInfoCard(
      context,
      isMobile,
      localizations.transactionInformation,
      Icons.receipt_long,
      [
        _buildInfoRow(
          localizations.transactionId,
          transactionId,
          isMobile,
        ),
        _buildInfoRow(
          localizations.network,
          localizations.polygon,
          isMobile,
        ),
        _buildInfoRow(
          localizations.blockHeight,
          '2,847,392', // TODO: Get from actual data
          isMobile,
        ),
        // Gas Used is now hidden as requested
      ],
    );
  }

  Widget _buildNftInfoSection(BuildContext context, bool isMobile) {
    final localizations = AppLocalizations.of(context)!;

    return _buildInfoCard(
      context,
      isMobile,
      localizations.nftInformation,
      Icons.image,
      [
        _buildInfoRow(
          localizations.tokenId,
          cv.nftTokenId ?? 'N/A',
          isMobile,
        ),
        _buildInfoRow(
          localizations.contractAddress,
          '0x1234...5678', // TODO: Get from actual data
          isMobile,
        ),
        _buildInfoRow(
          localizations.standard,
          localizations.erc721,
          isMobile,
        ),
        _buildInfoRow(
          localizations.metadataUri,
          cv.ipfsUrl ?? 'N/A',
          isMobile,
          isFullWidth: true, // Show full URI without truncation
        ),
      ],
    );
  }

  Widget _buildMintInfoSection(BuildContext context, bool isMobile) {
    final localizations = AppLocalizations.of(context)!;

    return _buildInfoCard(
      context,
      isMobile,
      localizations.mintInformation,
      Icons.add_circle,
      [
        _buildInfoRow(
          localizations.mintDate,
          _formatDate(cv.createdAt), // Use actual CV creation date
          isMobile,
        ),
        _buildInfoRow(
          localizations.minterAddress,
          '0x1234...5678', // TODO: Get from actual data
          isMobile,
        ),
        // Mint Price hidden as requested
        _buildInfoRow(
          localizations.certificateStatus,
          localizations.confirmed,
          isMobile,
          valueColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildCertificateDetailsSection(BuildContext context, bool isMobile) {
    final localizations = AppLocalizations.of(context)!;

    return _buildInfoCard(
      context,
      isMobile,
      localizations.certificateDetails,
      Icons.verified,
      [
        _buildInfoRow(
          localizations.certificateName,
          certification.certification?.category?.name ?? 'N/A',
          isMobile,
        ),
        _buildInfoRow(
          localizations.serialNumber,
          certification.certificationUser.serialNumber ?? 'N/A',
          isMobile,
        ),
        _buildInfoRow(
          localizations.certifier,
          certification.certification?.nomeCertificatore ?? 'JetCV',
          isMobile,
        ),
        _buildInfoRow(
          localizations.issueDate,
          _formatDate(certification.certificationUser.createdAt),
          isMobile,
        ),
      ],
    );
  }

  Widget _buildVerificationSection(BuildContext context, bool isMobile) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user,
            size: isMobile ? 40 : 50,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.blockchainVerified,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.blockchainVerificationMessage,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isMobile,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.green.shade700,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isMobile, {
    Color? valueColor,
    bool isFullWidth = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: isFullWidth
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: valueColor ?? Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: SelectableText(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: valueColor ?? Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
