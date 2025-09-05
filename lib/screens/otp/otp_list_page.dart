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
          if (mounted) {
            setState(() {
              _otps.add(otp);
            });
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteOtp),
        content: Text(AppLocalizations.of(context)!.deleteOtpConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final response = await OtpService.burnOtp(
                  idOtp: otp.idOtp,
                  idUser: otp.idUser,
                );

                if (!mounted) return;
                try {
                  Navigator.pop(context); // Close loading dialog
                } catch (navigatorError) {
                  // Navigator might be invalid, ignore the error
                  debugPrint('Navigator pop failed: $navigatorError');
                }

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
                    try {
                      _scaffoldMessenger!.showSnackBar(
                        SnackBar(
                          content: Text(_localizations!.otpBurnedSuccessfully),
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
                          content: Text(response.error ?? _localizations!.otpBurnFailed),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (scaffoldError) {
                      debugPrint('ScaffoldMessenger failed: $scaffoldError');
                    }
                  }
                }
              } catch (e) {
                if (mounted) {
                  try {
                    Navigator.pop(context); // Close loading dialog
                  } catch (navigatorError) {
                    // Navigator might be invalid, ignore the error
                    debugPrint('Navigator pop failed: $navigatorError');
                  }
                  if (_scaffoldMessenger != null && _localizations != null) {
                    try {
                      _scaffoldMessenger!.showSnackBar(
                        SnackBar(
                          content: Text(_localizations!.otpBurnFailed),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (scaffoldError) {
                      // ScaffoldMessenger might be invalid, ignore the error
                      debugPrint('ScaffoldMessenger failed: $scaffoldError');
                    }
                  }
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      body: MainLayout(
        currentRoute: '/otp',
        title: AppLocalizations.of(context)!.myOtps,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : _otps.isEmpty
                    ? _buildEmptyState()
                    : _buildOtpList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewOtpModal,
        backgroundColor: const Color(0xFF6B46C1),
        icon: Icon(
          Icons.add,
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
            fontWeight: FontWeight.bold,
            fontSize: isMobile
                ? 12
                : isTablet
                    ? 14
                    : 16,
          ),
        ),
        extendedPadding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 12
              : isTablet
                  ? 16
                  : 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final containerPadding = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;
    final containerMargin = isMobile
        ? 12.0
        : isTablet
            ? 14.0
            : 16.0;
    final iconSize = isMobile
        ? 18.0
        : isTablet
            ? 19.0
            : 20.0;
    final iconPadding = isMobile
        ? 6.0
        : isTablet
            ? 7.0
            : 8.0;
    final titleFontSize = isMobile
        ? 16.0
        : isTablet
            ? 17.0
            : 18.0;
    final subtitleFontSize = isMobile
        ? 12.0
        : isTablet
            ? 13.0
            : 14.0;
    final spacing = isMobile
        ? 8.0
        : isTablet
            ? 10.0
            : 12.0;
    final sectionSpacing = isMobile
        ? 12.0
        : isTablet
            ? 14.0
            : 16.0;

    return Column(
      children: [
        // Permanent OTP Codes Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(containerPadding),
          margin: EdgeInsets.all(containerMargin),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.permanentOtpCodes,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          AppLocalizations.of(context)!.manageSecureAccessCodes,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sectionSpacing),
              Container(
                padding: EdgeInsets.all(isMobile
                    ? 12
                    : isTablet
                        ? 14
                        : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.vpn_key,
                      color: const Color(0xFF6B46C1),
                      size: iconSize,
                    ),
                    SizedBox(width: spacing),
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: isMobile
                            ? 20
                            : isTablet
                                ? 22
                                : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.activeOtps,
                        style: TextStyle(
                          fontSize: isMobile
                              ? 12
                              : isTablet
                                  ? 13
                                  : 14,
                          color: const Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Empty State
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isMobile
                      ? 80
                      : isTablet
                          ? 100
                          : 120,
                  height: isMobile
                      ? 80
                      : isTablet
                          ? 100
                          : 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.security,
                    color: const Color(0xFF6B46C1),
                    size: isMobile
                        ? 32
                        : isTablet
                            ? 40
                            : 48,
                  ),
                ),
                SizedBox(
                    height: isMobile
                        ? 16
                        : isTablet
                            ? 20
                            : 24),
                Text(
                  AppLocalizations.of(context)!.noOtpGenerated,
                  style: TextStyle(
                    fontSize: isMobile
                        ? 16
                        : isTablet
                            ? 18
                            : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(
                    height: isMobile
                        ? 8
                        : isTablet
                            ? 10
                            : 12),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile
                          ? 16
                          : isTablet
                              ? 24
                              : 32),
                  child: Text(
                    AppLocalizations.of(context)!.createFirstOtpDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile
                          ? 12
                          : isTablet
                              ? 14
                              : 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                SizedBox(
                    height: isMobile
                        ? 24
                        : isTablet
                            ? 28
                            : 32),
                ElevatedButton.icon(
                  onPressed: _showNewOtpModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile
                            ? 16
                            : isTablet
                                ? 20
                                : 24,
                        vertical: isMobile
                            ? 10
                            : isTablet
                                ? 11
                                : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    Icons.add,
                    size: isMobile
                        ? 16
                        : isTablet
                            ? 18
                            : 20,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.generateFirstOtp,
                    style: TextStyle(
                      fontSize: isMobile
                          ? 12
                          : isTablet
                              ? 14
                              : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpList() {
    return Column(
      children: [
        // Permanent OTP Codes Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.permanentOtpCodes,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.manageSecureAccessCodes,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.vpn_key,
                      color: Color(0xFF6B46C1),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_otps.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.activeOtps,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOtps,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(OtpModel otp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B46C1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otp.tag ?? AppLocalizations.of(context)!.otpNumber(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCreatedAt(otp.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStatusText(otp),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(otp),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteOtp(otp);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            otp.code,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyOtpCode(otp.code),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6B46C1)),
                    foregroundColor: const Color(0xFF6B46C1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(AppLocalizations.of(context)!.copy),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showQrCodeModal(otp),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6B46C1)),
                    foregroundColor: const Color(0xFF6B46C1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code, size: 18),
                  label: Text(AppLocalizations.of(context)!.qrCode),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.createdNow;
    } else if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)!
          .createdMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)!.createdHoursAgo(difference.inHours);
    } else {
      return AppLocalizations.of(context)!.createdDaysAgo(difference.inDays);
    }
  }

  String _getStatusText(OtpModel otp) {
    if (otp.isBurned) return AppLocalizations.of(context)!.otpStatusBurned;
    if (otp.isUsed) return AppLocalizations.of(context)!.otpStatusUsed;
    if (otp.isExpired) return AppLocalizations.of(context)!.otpStatusExpired;
    return AppLocalizations.of(context)!.otpStatusValid;
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
                content: Text('Database connection failed: ${dbTest.error}'),
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
                content: Text('Edge Function not accessible: ${edgeTest.error}'),
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
                content: Text(response.error ?? _localizations!.otpCreationFailed),
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
