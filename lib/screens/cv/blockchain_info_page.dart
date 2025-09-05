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
          'Blockchain Certificate',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green.shade800),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: Icon(
              Icons.share,
              color: Colors.green.shade700,
            ),
          ),
        ],
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
            child: Center(
              child: Icon(
                Icons.account_balance_wallet,
                size: isMobile ? 30 : 40,
                color: Colors.purple.shade600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Blockchain Certificate',
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Verified on Polygon Network',
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
    return _buildInfoCard(
      context,
      isMobile,
      'Transaction Information',
      Icons.receipt_long,
      [
        _buildInfoRow(
          'Transaction ID',
          cv.nftMintTransactionUrl ?? 'N/A',
          isMobile,
        ),
        _buildInfoRow(
          'Network',
          'Polygon',
          isMobile,
        ),
        _buildInfoRow(
          'Block Height',
          '2,847,392', // TODO: Get from actual data
          isMobile,
        ),
        _buildInfoRow(
          'Gas Used',
          '45,230', // TODO: Get from actual data
          isMobile,
        ),
      ],
    );
  }

  Widget _buildNftInfoSection(BuildContext context, bool isMobile) {
    return _buildInfoCard(
      context,
      isMobile,
      'NFT Information',
      Icons.image,
      [
        _buildInfoRow(
          'Token ID',
          '1,234,567', // TODO: Get from actual data
          isMobile,
        ),
        _buildInfoRow(
          'Contract Address',
          '0x1234...5678', // TODO: Get from actual data
          isMobile,
        ),
        _buildInfoRow(
          'Standard',
          'ERC-721',
          isMobile,
        ),
        _buildInfoRow(
          'Metadata URI',
          'ipfs://Qm...', // TODO: Get from actual data
          isMobile,
        ),
      ],
    );
  }

  Widget _buildMintInfoSection(BuildContext context, bool isMobile) {
    return _buildInfoCard(
      context,
      isMobile,
      'Mint Information',
      Icons.add_circle,
      [
        _buildInfoRow(
          'Mint Date',
          _formatDate(DateTime.now()), // TODO: Get from actual data
          isMobile,
        ),
        _buildInfoRow(
          'Minter Address',
          '0x1234...5678', // TODO: Get from actual data
          isMobile,
        ),
        _buildInfoRow(
          'Mint Price',
          '0.01 MATIC',
          isMobile,
        ),
        _buildInfoRow(
          'Status',
          'Confirmed',
          isMobile,
          valueColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildCertificateDetailsSection(BuildContext context, bool isMobile) {
    return _buildInfoCard(
      context,
      isMobile,
      'Certificate Details',
      Icons.verified,
      [
        _buildInfoRow(
          'Certificate Name',
          certification.certification?.category?.name ?? 'N/A',
          isMobile,
        ),
        _buildInfoRow(
          'Serial Number',
          certification.certificationUser.serialNumber ?? 'N/A',
          isMobile,
        ),
        _buildInfoRow(
          'Certifier',
          'JetCV', // TODO: Get from actual data
          isMobile,
        ),
        _buildInfoRow(
          'Issue Date',
          _formatDate(certification.certificationUser.createdAt),
          isMobile,
        ),
      ],
    );
  }

  Widget _buildVerificationSection(BuildContext context, bool isMobile) {
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
            'Blockchain Verified',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This certificate has been verified and stored on the Polygon blockchain network.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open blockchain explorer
            },
            icon: Icon(
              Icons.open_in_new,
              color: Colors.white,
            ),
            label: Text(
              'View on Polygon Explorer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
            child: Text(
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
