import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';
import 'package:jetcv__utenti/services/otp_service.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/screens/authenticated_home_page.dart';
import 'package:flutter/services.dart';

class OtpListPage extends StatefulWidget {
  const OtpListPage({super.key});

  @override
  State<OtpListPage> createState() => _OtpListPageState();
}

class _OtpListPageState extends State<OtpListPage> {
  List<OtpModel> _otps = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Riferimenti salvati per evitare errori di contesto invalidato
  ScaffoldMessengerState? _scaffoldMessenger;
  AppLocalizations? _localizations;

  @override
  void initState() {
    super.initState();
    _loadOtps();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Salva i riferimenti per evitare errori di contesto invalidato
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _localizations = AppLocalizations.of(context);
  }

  Future<void> _loadOtps() async {
    debugPrint('🔄 _loadOtps() called');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = SupabaseConfig.client.auth.currentSession;
      final userId = session?.user.id;

      if (userId != null) {
        debugPrint('📋 Loading OTPs for user: $userId');

        final response = await OtpService.getUserOtps(
          idUser: userId,
          limit: 50,
          offset: 0,
        );

        if (mounted) {
          if (response.success && response.data != null) {
            setState(() {
              _otps = response.data!;
              _isLoading = false;
              _errorMessage = null;
            });
            debugPrint('✅ Loaded ${_otps.length} OTPs');
          } else {
            setState(() {
              _errorMessage = response.error ?? 'Failed to load OTPs';
              _isLoading = false;
            });
            debugPrint('❌ Failed to load OTPs: ${response.error}');
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'User not authenticated';
            _isLoading = false;
          });
        }
        debugPrint('❌ User not authenticated');
      }
    } catch (e) {
      debugPrint('❌ Error loading OTPs: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading OTPs: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showNewOtpModal() {
    showDialog(
      context: context,
      builder: (context) => NewOtpModal(
        onOtpCreated: (otp) {
          debugPrint('🔄 OTP created callback called, reloading OTPs...');
          if (mounted) {
            // Ricarica la lista completa per assicurarsi che sia aggiornata
            _loadOtps();
          }
        },
      ),
    );
  }

  void _showQrCodeModal(OtpModel otp) {
    showDialog(
      context: context,
      builder: (context) => QrCodeModal(otp: otp),
    );
  }

  void _showEditOtpModal(OtpModel otp) {
    showDialog(
      context: context,
      builder: (context) => EditOtpModal(
        otp: otp,
        onOtpUpdated: (updatedOtp) {
          // Update the OTP in the list and refresh UI
          _updateOtpInList(updatedOtp);
        },
      ),
    );
  }

  void _updateOtpInList(OtpModel updatedOtp) {
    if (!mounted) return;
    
    setState(() {
      final index = _otps.indexWhere((o) => o.idOtp == updatedOtp.idOtp);
      if (index != -1) {
        // Replace the OTP in the list with the updated version
        _otps[index] = updatedOtp;
        debugPrint('✅ OTP updated in list: ${updatedOtp.tag}');
      } else {
        debugPrint('⚠️ OTP not found in list for update: ${updatedOtp.idOtp}');
      }
    });
  }

  void _copyOtpCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    if (mounted && _scaffoldMessenger != null && _localizations != null) {
      try {
        _scaffoldMessenger!.showSnackBar(
          SnackBar(
            content: Text(_localizations!.otpCodeCopied),
            backgroundColor: Colors.green,
          ),
        );
      } catch (scaffoldError) {
        debugPrint('ScaffoldMessenger failed: $scaffoldError');
      }
    }
  }

  void _deleteOtp(OtpModel otp) async {
    // Mostra conferma
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteOtp),
        content: Text(AppLocalizations.of(context)!.deleteOtpConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    try {
      final response = await OtpService.burnOtp(
        idOtp: otp.idOtp,
        idUser: otp.idUser,
      );

      // Chiudi loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      if (response.success) {
        setState(() {
          _otps.removeWhere((item) => item.idOtp == otp.idOtp);
          // Se la lista è vuota, aggiorna lo stato
          if (_otps.isEmpty) {
            _isLoading = false;
            _errorMessage = null;
          }
        });

        if (mounted && _scaffoldMessenger != null && _localizations != null) {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(
              content: Text(_localizations!.otpBurnedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted && _scaffoldMessenger != null && _localizations != null) {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(
              content: Text(response.error ?? _localizations!.otpBurnFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting OTP: $e');

      // Chiudi loading dialog se ancora aperto
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted && _scaffoldMessenger != null && _localizations != null) {
        _scaffoldMessenger!.showSnackBar(
          SnackBar(
            content: Text('${_localizations!.otpBurnFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: MainLayout(
        currentRoute: '/otp',
        title: AppLocalizations.of(context)!.myOtps,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          child: _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
                  ? _buildErrorState()
                  : _otps.isEmpty
                      ? _buildEmptyState()
                      : _buildOtpList(),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B46C1).withValues(alpha: 0.3),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showNewOtpModal,
          backgroundColor: const Color(0xFF6B46C1),
          elevation: 0,
          icon: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: isMobile
                ? 18
                : isTablet
                    ? 20
                    : 24,
          ),
          label: Text(
            AppLocalizations.of(context)!.newOtp,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isMobile
                  ? 12
                  : isTablet
                      ? 14
                      : 16,
            ),
          ),
          extendedPadding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? 16
                : isTablet
                    ? 20
                    : 24,
            vertical: isMobile
                ? 12
                : isTablet
                    ? 14
                    : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile
                ? 20
                : isTablet
                    ? 24
                    : 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF6B46C1),
              ),
              strokeWidth: 3,
            ),
          ),
          SizedBox(
              height: isMobile
                  ? 20
                  : isTablet
                      ? 24
                      : 28),
          Text(
            'Caricamento...',
            style: TextStyle(
              fontSize: isMobile
                  ? 16
                  : isTablet
                      ? 18
                      : 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(
              height: isMobile
                  ? 8
                  : isTablet
                      ? 10
                      : 12),
          Text(
            'Attendere prego...',
            style: TextStyle(
              fontSize: isMobile
                  ? 14
                  : isTablet
                      ? 15
                      : 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile
            ? 24
            : isTablet
                ? 32
                : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with gradient
            Container(
              width: isMobile
                  ? 120
                  : isTablet
                      ? 140
                      : 160,
              height: isMobile
                  ? 120
                  : isTablet
                      ? 140
                      : 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6B46C1).withValues(alpha: 0.1),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFF6B46C1).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.security,
                size: isMobile
                    ? 60
                    : isTablet
                        ? 70
                        : 80,
                color: const Color(0xFF6B46C1),
              ),
            ),

            SizedBox(
                height: isMobile
                    ? 32
                    : isTablet
                        ? 36
                        : 40),

            // Title
            Text(
              AppLocalizations.of(context)!.noOtpsYet,
              style: TextStyle(
                fontSize: isMobile
                    ? 24
                    : isTablet
                        ? 28
                        : 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
                height: isMobile
                    ? 16
                    : isTablet
                        ? 20
                        : 24),

            // Description
            Text(
              AppLocalizations.of(context)!.createYourFirstOtp,
              style: TextStyle(
                fontSize: isMobile
                    ? 16
                    : isTablet
                        ? 18
                        : 20,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
                height: isMobile
                    ? 32
                    : isTablet
                        ? 36
                        : 40),

            // Features list
            Container(
              padding: EdgeInsets.all(isMobile
                  ? 20
                  : isTablet
                      ? 24
                      : 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildFeatureItem(
                    Icons.shield,
                    AppLocalizations.of(context)!.secureAccess,
                    AppLocalizations.of(context)!.secureAccessDescription,
                    isMobile,
                    isTablet,
                  ),
                  SizedBox(
                      height: isMobile
                          ? 16
                          : isTablet
                              ? 20
                              : 24),
                  _buildFeatureItem(
                    Icons.timer,
                    AppLocalizations.of(context)!.timeLimited,
                    AppLocalizations.of(context)!.timeLimitedDescription,
                    isMobile,
                    isTablet,
                  ),
                  SizedBox(
                      height: isMobile
                          ? 16
                          : isTablet
                              ? 20
                              : 24),
                  _buildFeatureItem(
                    Icons.qr_code,
                    AppLocalizations.of(context)!.qrCodeSupport,
                    AppLocalizations.of(context)!.qrCodeSupportDescription,
                    isMobile,
                    isTablet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    bool isMobile,
    bool isTablet,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile
              ? 8
              : isTablet
                  ? 10
                  : 12),
          decoration: BoxDecoration(
            color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: isMobile
                ? 20
                : isTablet
                    ? 22
                    : 24,
            color: const Color(0xFF6B46C1),
          ),
        ),
        SizedBox(
            width: isMobile
                ? 12
                : isTablet
                    ? 14
                    : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile
                      ? 14
                      : isTablet
                          ? 15
                          : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(
                  height: isMobile
                      ? 4
                      : isTablet
                          ? 6
                          : 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: isMobile
                      ? 12
                      : isTablet
                          ? 13
                          : 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpList() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Column(
      children: [
        // Header Section - Compact
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: isMobile
                ? 16
                : isTablet
                    ? 20
                    : 24,
            vertical: isMobile
                ? 8
                : isTablet
                    ? 10
                    : 12,
          ),
          padding: EdgeInsets.all(isMobile
              ? 12
              : isTablet
                  ? 14
                  : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF6B46C1).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile
                    ? 6
                    : isTablet
                        ? 8
                        : 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B46C1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.security,
                  color: Colors.white,
                  size: isMobile
                      ? 16
                      : isTablet
                          ? 18
                          : 20,
                ),
              ),
              SizedBox(
                  width: isMobile
                      ? 8
                      : isTablet
                          ? 10
                          : 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.permanentOtpCodes,
                  style: TextStyle(
                    fontSize: isMobile
                        ? 14
                        : isTablet
                            ? 16
                            : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile
                      ? 8
                      : isTablet
                          ? 10
                          : 12,
                  vertical: isMobile
                      ? 4
                      : isTablet
                          ? 5
                          : 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.vpn_key,
                      color: const Color(0xFF6B46C1),
                      size: isMobile
                          ? 14
                          : isTablet
                              ? 16
                              : 18,
                    ),
                    SizedBox(
                        width: isMobile
                            ? 4
                            : isTablet
                                ? 6
                                : 8),
                    Text(
                      '${_otps.length}',
                      style: TextStyle(
                        fontSize: isMobile
                            ? 14
                            : isTablet
                                ? 16
                                : 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B46C1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // OTP List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile
                  ? 16
                  : isTablet
                      ? 20
                      : 24,
              vertical: isMobile
                  ? 8
                  : isTablet
                      ? 12
                      : 16,
            ),
            itemCount: _otps.length,
            itemBuilder: (context, index) {
              final otp = _otps[index];
              return _buildOtpCard(otp);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile
            ? 24
            : isTablet
                ? 32
                : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon container
            Container(
              width: isMobile
                  ? 120
                  : isTablet
                      ? 140
                      : 160,
              height: isMobile
                  ? 120
                  : isTablet
                      ? 140
                      : 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.withValues(alpha: 0.1),
                    Colors.red.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: isMobile
                    ? 60
                    : isTablet
                        ? 70
                        : 80,
                color: Colors.red.shade600,
              ),
            ),

            SizedBox(
                height: isMobile
                    ? 32
                    : isTablet
                        ? 36
                        : 40),

            // Error title
            Text(
              AppLocalizations.of(context)!.errorOccurred,
              style: TextStyle(
                fontSize: isMobile
                    ? 24
                    : isTablet
                        ? 28
                        : 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
                height: isMobile
                    ? 16
                    : isTablet
                        ? 20
                        : 24),

            // Error message
            Container(
              padding: EdgeInsets.all(isMobile
                  ? 20
                  : isTablet
                      ? 24
                      : 28),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                _errorMessage ?? AppLocalizations.of(context)!.unknownError,
                style: TextStyle(
                  fontSize: isMobile
                      ? 16
                      : isTablet
                          ? 18
                          : 20,
                  color: Colors.red.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(
                height: isMobile
                    ? 32
                    : isTablet
                        ? 36
                        : 40),

            // Retry button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade300.withValues(alpha: 0.3),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _loadOtps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? 24
                        : isTablet
                            ? 28
                            : 32,
                    vertical: isMobile
                        ? 16
                        : isTablet
                            ? 18
                            : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  Icons.refresh,
                  size: isMobile
                      ? 20
                      : isTablet
                          ? 22
                          : 24,
                ),
                label: Text(
                  AppLocalizations.of(context)!.retry,
                  style: TextStyle(
                    fontSize: isMobile
                        ? 16
                        : isTablet
                            ? 18
                            : 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard(OtpModel otp) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Container(
      margin: EdgeInsets.only(
          bottom: isMobile
              ? 16
              : isTablet
                  ? 20
                  : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(otp).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(otp).withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status indicator
          Container(
            padding: EdgeInsets.all(isMobile
                ? 20
                : isTablet
                    ? 24
                    : 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getStatusColor(otp).withValues(alpha: 0.1),
                  _getStatusColor(otp).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile
                      ? 10
                      : isTablet
                          ? 12
                          : 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getStatusColor(otp),
                        _getStatusColor(otp).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(otp),
                    color: Colors.white,
                    size: isMobile
                        ? 20
                        : isTablet
                            ? 24
                            : 28,
                  ),
                ),
                SizedBox(
                    width: isMobile
                        ? 16
                        : isTablet
                            ? 20
                            : 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otp.tag ?? AppLocalizations.of(context)!.otpNumber(1),
                        style: TextStyle(
                          fontSize: isMobile
                              ? 18
                              : isTablet
                                  ? 20
                                  : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(
                          height: isMobile
                              ? 4
                              : isTablet
                                  ? 6
                                  : 8),
                      Text(
                        _formatCreatedAt(otp.createdAt),
                        style: TextStyle(
                          fontSize: isMobile
                              ? 12
                              : isTablet
                                  ? 14
                                  : 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? 12
                        : isTablet
                            ? 14
                            : 16,
                    vertical: isMobile
                        ? 6
                        : isTablet
                            ? 8
                            : 10,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(otp).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(otp).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(otp),
                    style: TextStyle(
                      fontSize: isMobile
                          ? 10
                          : isTablet
                              ? 11
                              : 12,
                      color: _getStatusColor(otp),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // OTP Code Section
          Container(
            padding: EdgeInsets.all(isMobile
                ? 20
                : isTablet
                    ? 24
                    : 28),
            child: Column(
              children: [
                // OTP Code
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile
                      ? 20
                      : isTablet
                          ? 24
                          : 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade50,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Codice OTP',
                        style: TextStyle(
                          fontSize: isMobile
                              ? 12
                              : isTablet
                                  ? 14
                                  : 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                          height: isMobile
                              ? 8
                              : isTablet
                                  ? 10
                                  : 12),
                      Text(
                        otp.code,
                        style: TextStyle(
                          fontSize: isMobile
                              ? 32
                              : isTablet
                                  ? 36
                                  : 40,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B46C1),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                    height: isMobile
                        ? 20
                        : isTablet
                            ? 24
                            : 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.copy,
                        label: AppLocalizations.of(context)!.copy,
                        color: const Color(0xFF6B46C1),
                        onPressed: () => _copyOtpCode(otp.code),
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(
                        width: isMobile
                            ? 12
                            : isTablet
                                ? 16
                                : 20),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.qr_code,
                        label: AppLocalizations.of(context)!.qrCode,
                        color: Colors.green.shade600,
                        onPressed: () => _showQrCodeModal(otp),
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(
                        width: isMobile
                            ? 12
                            : isTablet
                                ? 16
                                : 20),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.edit,
                        label: AppLocalizations.of(context)!.editOtp,
                        color: Colors.orange.shade600,
                        onPressed: () => _showEditOtpModal(otp),
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(
                        width: isMobile
                            ? 12
                            : isTablet
                                ? 16
                                : 20),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.delete,
                        label: AppLocalizations.of(context)!.delete,
                        color: Colors.red.shade600,
                        onPressed: () => _deleteOtp(otp),
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
    required bool isTablet,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: isMobile
                ? 12
                : isTablet
                    ? 14
                    : 16,
            horizontal: isMobile
                ? 8
                : isTablet
                    ? 10
                    : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isMobile
                  ? 18
                  : isTablet
                      ? 20
                      : 22,
            ),
            SizedBox(
                height: isMobile
                    ? 4
                    : isTablet
                        ? 6
                        : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile
                    ? 10
                    : isTablet
                        ? 11
                        : 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(OtpModel otp) {
    if (otp.isBurned) return Icons.local_fire_department;
    if (otp.isUsed) return Icons.check_circle;
    if (otp.isExpired) return Icons.timer_off;
    return Icons.timer;
  }

  String _formatCreatedAt(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.createdNow;
    } else if (difference.inMinutes < 60) {
      return 'Creato ${difference.inMinutes} minuti fa';
    } else if (difference.inHours < 24) {
      return 'Creato ${difference.inHours} ore fa';
    } else {
      return 'Creato ${difference.inDays} giorni fa';
    }
  }

  String _getStatusText(OtpModel otp) {
    if (otp.isBurned) return AppLocalizations.of(context)!.statusBurned;
    if (otp.isUsed) return AppLocalizations.of(context)!.statusUsed;
    if (otp.isExpired) return AppLocalizations.of(context)!.statusExpired;
    return AppLocalizations.of(context)!.statusValid;
  }

  Color _getStatusColor(OtpModel otp) {
    if (otp.isBurned) return Colors.red;
    if (otp.isUsed) return Colors.orange;
    if (otp.isExpired) return Colors.grey;
    return Colors.green;
  }
}

class NewOtpModal extends StatefulWidget {
  final Function(OtpModel)? onOtpCreated;

  const NewOtpModal({super.key, this.onOtpCreated});

  @override
  State<NewOtpModal> createState() => _NewOtpModalState();
}

class _NewOtpModalState extends State<NewOtpModal> {
  final _tagController = TextEditingController();
  bool _isGenerating = false;

  // Riferimenti salvati per evitare errori di contesto invalidato
  ScaffoldMessengerState? _scaffoldMessenger;
  AppLocalizations? _localizations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Salva i riferimenti per evitare errori di contesto invalidato
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _localizations = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _generateOtp() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final session = SupabaseConfig.client.auth.currentSession;
      final userId = session?.user.id;

      if (userId == null) {
        if (mounted && _scaffoldMessenger != null && _localizations != null) {
          try {
            _scaffoldMessenger!.showSnackBar(
              SnackBar(
                content: Text(_localizations!.userNotLoaded),
                backgroundColor: Colors.red,
              ),
            );
          } catch (scaffoldError) {
            debugPrint('ScaffoldMessenger failed: $scaffoldError');
          }
        }
        return;
      }

      // First test database connection
      debugPrint('🧪 Testing database connection before creating OTP...');
      final dbTest = await OtpService.testDatabaseConnection();
      if (!dbTest.success) {
        debugPrint('❌ Database connection failed: ${dbTest.error}');
        if (mounted && _scaffoldMessenger != null && _localizations != null) {
          try {
            _scaffoldMessenger!.showSnackBar(
              SnackBar(
                content: Text(
                    '${AppLocalizations.of(context)!.databaseConnectionFailed}: ${dbTest.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } catch (scaffoldError) {
            debugPrint('ScaffoldMessenger failed: $scaffoldError');
          }
        }
        return;
      }
      debugPrint('✅ Database connection successful');

      // Test Edge Function accessibility
      debugPrint('🧪 Testing Edge Function accessibility...');
      final edgeTest = await OtpService.testEdgeFunction();
      if (!edgeTest.success) {
        debugPrint('❌ Edge Function test failed: ${edgeTest.error}');
        if (mounted && _scaffoldMessenger != null && _localizations != null) {
          try {
            _scaffoldMessenger!.showSnackBar(
              SnackBar(
                content: Text(
                    '${AppLocalizations.of(context)!.edgeFunctionNotAccessible}: ${edgeTest.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } catch (scaffoldError) {
            debugPrint('ScaffoldMessenger failed: $scaffoldError');
          }
        }
        return;
      }
      debugPrint('✅ Edge Function accessible');

      final response = await OtpService.createOtp(
        idUser: userId,
        tag: _tagController.text.trim().isEmpty
            ? null
            : _tagController.text.trim(),
        ttlSeconds: 3600, // 1 hour
        length: 6,
        numericOnly: true,
      );

      if (response.success && response.data != null) {
        debugPrint('✅ OTP created successfully, calling callback...');
        Navigator.pop(context);
        widget.onOtpCreated?.call(response.data!);

        if (mounted && _scaffoldMessenger != null && _localizations != null) {
          try {
            _scaffoldMessenger!.showSnackBar(
              SnackBar(
                content: Text(_localizations!.otpCreatedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
          } catch (scaffoldError) {
            debugPrint('ScaffoldMessenger failed: $scaffoldError');
          }
        }
      } else {
        if (mounted && _scaffoldMessenger != null && _localizations != null) {
          try {
            _scaffoldMessenger!.showSnackBar(
              SnackBar(
                content:
                    Text(response.error ?? _localizations!.otpCreationFailed),
                backgroundColor: Colors.red,
              ),
            );
          } catch (scaffoldError) {
            debugPrint('ScaffoldMessenger failed: $scaffoldError');
          }
        }
      }
    } catch (e) {
      if (mounted && _scaffoldMessenger != null && _localizations != null) {
        try {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(
              content: Text(_localizations!.otpCreationFailed),
              backgroundColor: Colors.red,
            ),
          );
        } catch (scaffoldError) {
          debugPrint('ScaffoldMessenger failed: $scaffoldError');
        }
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.newOtp,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.addOptionalTagDescription,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.tagOptional,
                prefixIcon: const Icon(
                  Icons.tag,
                  color: Color(0xFF6B7280),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6B46C1)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isGenerating ? null : () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: const TextStyle(
                        color: Color(0xFF6B46C1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: _isGenerating ? null : _generateOtp,
                    child: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6B46C1)),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.generateOtp,
                            style: const TextStyle(
                              color: Color(0xFF6B46C1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QrCodeModal extends StatelessWidget {
  final OtpModel otp;

  const QrCodeModal({super.key, required this.otp});

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: otp.code));
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(localizations.otpCodeCopied),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('ScaffoldMessenger failed in QrCodeModal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.qrCodeOtp,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              otp.tag ?? AppLocalizations.of(context)!.otpNumber(1),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code,
                  size: 80,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${AppLocalizations.of(context)!.qrCodeFor} ${otp.code}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              otp.code,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6B46C1)),
                      foregroundColor: const Color(0xFF6B46C1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.close),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () => _copyCode(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B46C1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(AppLocalizations.of(context)!.copy),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditOtpModal extends StatefulWidget {
  final OtpModel otp;
  final Function(OtpModel)? onOtpUpdated;

  const EditOtpModal({super.key, required this.otp, this.onOtpUpdated});

  @override
  State<EditOtpModal> createState() => _EditOtpModalState();
}

class _EditOtpModalState extends State<EditOtpModal> {
  final _tagController = TextEditingController();
  bool _isUpdating = false;

  // Riferimenti salvati per evitare errori di contesto invalidato
  ScaffoldMessengerState? _scaffoldMessenger;
  AppLocalizations? _localizations;

  @override
  void initState() {
    super.initState();
    _tagController.text = widget.otp.tag ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Salva i riferimenti per evitare errori di contesto invalidato
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _localizations = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _updateOtpTag() async {
    if (_tagController.text.trim().isEmpty) {
      if (mounted && _scaffoldMessenger != null && _localizations != null) {
        try {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(
              content: Text(_localizations!.tagOptional),
              backgroundColor: Colors.orange,
            ),
          );
        } catch (e) {
          debugPrint('Error showing snackbar: $e');
        }
      }
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final session = SupabaseConfig.client.auth.currentSession;
      final userId = session?.user.id;

      if (userId != null) {
        final response = await OtpService.updateOtpTag(
          idOtp: widget.otp.idOtp,
          idUser: userId,
          newTag: _tagController.text.trim(),
        );

        if (mounted) {
          if (response.success && response.data != null) {
            // Callback per aggiornare la lista
            widget.onOtpUpdated?.call(response.data!);

            // Mostra messaggio di successo
            if (_scaffoldMessenger != null && _localizations != null) {
              try {
                _scaffoldMessenger!.showSnackBar(
                  SnackBar(
                    content: Text(_localizations!.otpTagUpdated),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                debugPrint('Error showing success snackbar: $e');
              }
            }

            // Chiudi il modal
            Navigator.pop(context);
          } else {
            // Mostra messaggio di errore
            if (_scaffoldMessenger != null && _localizations != null) {
              try {
                _scaffoldMessenger!.showSnackBar(
                  SnackBar(
                    content: Text(
                        response.error ?? _localizations!.otpTagUpdateError),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                debugPrint('Error showing error snackbar: $e');
              }
            }
          }
        }
      } else {
        if (mounted && _scaffoldMessenger != null && _localizations != null) {
          try {
            _scaffoldMessenger!.showSnackBar(
              SnackBar(
                content: Text(_localizations!.userNotLoaded),
                backgroundColor: Colors.red,
              ),
            );
          } catch (e) {
            debugPrint('Error showing user not loaded snackbar: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating OTP tag: $e');
      if (mounted && _scaffoldMessenger != null && _localizations != null) {
        try {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(
              content: Text(_localizations!.otpTagUpdateError),
              backgroundColor: Colors.red,
            ),
          );
        } catch (e) {
          debugPrint('Error showing error snackbar: $e');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: isMobile ? double.infinity : 500,
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade50,
                    Colors.orange.shade100,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade600,
                          Colors.orange.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: isMobile ? 24 : 28,
                    ),
                  ),
                  SizedBox(width: isMobile ? 16 : 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.editOtpTag,
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: isMobile ? 4 : 6),
                        Text(
                          'Modifica il tag per identificare questo OTP',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 24 : 32),

            // Tag Input
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.tagOptional,
                hintText: 'Inserisci un tag per identificare questo OTP',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.orange.shade600,
                    width: 2,
                  ),
                ),
              ),
              maxLength: 50,
              textCapitalization: TextCapitalization.words,
            ),

            SizedBox(height: isMobile ? 24 : 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isUpdating ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      foregroundColor: Colors.grey.shade700,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.close,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateOtpTag,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isUpdating
                        ? SizedBox(
                            height: isMobile ? 20 : 24,
                            width: isMobile ? 20 : 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.updateTag,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
