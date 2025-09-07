import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/services/otp_service.dart';
import 'package:jetcv__utenti/services/otp_test_service.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';

/// Comprehensive OTP management widget that demonstrates all OTP operations
class OtpManagementWidget extends StatefulWidget {
  const OtpManagementWidget({super.key});

  @override
  State<OtpManagementWidget> createState() => _OtpManagementWidgetState();
}

class _OtpManagementWidgetState extends State<OtpManagementWidget> {
  final List<OtpModel> _otps = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOtps();
  }

  Future<void> _loadOtps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would store OTP IDs and retrieve their metadata
      // For demonstration, we'll create a sample OTP
      final session = SupabaseConfig.client.auth.currentSession;
      final userId = session?.user.id;

      if (userId != null) {
        final response = await OtpService.createOtp(
          idUser: userId,
          tag: 'demo-management',
          ttlSeconds: 3600,
          length: 6,
          numericOnly: true,
        );

        if (response.success && response.data != null) {
          setState(() {
            _otps.add(response.data!);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Failed to load OTPs';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading OTPs: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = SupabaseConfig.client.auth.currentSession;
      final userId = session?.user.id;

      if (userId == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      final response = await OtpService.createOtp(
        idUser: userId,
        tag: 'manual-${DateTime.now().millisecondsSinceEpoch}',
        ttlSeconds: 300, // 5 minutes
        length: 6,
        numericOnly: true,
      );

      if (response.success && response.data != null) {
        setState(() {
          _otps.add(response.data!);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.otpCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to create OTP';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating OTP: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp(String code) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = SupabaseConfig.client.auth.currentSession;
      final userId = session?.user.id;

      final response = await OtpService.verifyOtp(
        code: code,
        idUser: userId,
        markUsed: true,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.otpVerificationSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _loadOtps(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ??
                AppLocalizations.of(context)!.otpVerificationFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.otpVerificationError),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _burnOtp(OtpModel otp) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await OtpService.burnOtp(
        idOtp: otp.idOtp,
        idUser: otp.idUser,
      );

      if (response.success) {
        setState(() {
          _otps.removeWhere((item) => item.idOtp == otp.idOtp);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.otpBurnedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to burn OTP';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error burning OTP: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnectivity() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await OtpTestService.runAllTests();

      setState(() {
        _isLoading = false;
      });

      // Show results in a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.connectionTestResults),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTestResult('Overall', results['overall']),
                const SizedBox(height: 8),
                _buildTestResult('Connectivity', results['connectivity']),
                const SizedBox(height: 8),
                _buildTestResult('Authentication', results['authentication']),
                const SizedBox(height: 8),
                _buildTestResult('Create OTP', results['createOtp']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error testing connectivity: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildTestResult(String testName, Map<String, dynamic> result) {
    final isSuccess = result['success'] == true;
    return Row(
      children: [
        Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                testName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                result['message'] ?? 'No message',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _cleanupExpiredOtps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await OtpService.cleanupExpiredOtps();

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .otpCleanupSuccess(response.data ?? 0)),
            backgroundColor: Colors.blue,
          ),
        );
        _loadOtps(); // Refresh the list
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to cleanup OTPs';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cleaning up OTPs: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Color(0xFF6B46C1)),
                const SizedBox(width: 8),
                Text(
                  'OTP Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createOtp,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                      AppLocalizations.of(context)?.createOtp ?? 'Create OTP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testConnectivity,
                  icon: const Icon(Icons.network_check, size: 18),
                  label: Text(AppLocalizations.of(context)!.testConnection),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _cleanupExpiredOtps,
                  icon: const Icon(Icons.cleaning_services, size: 18),
                  label: Text(AppLocalizations.of(context)!.cleanupExpired),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadOtps,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(AppLocalizations.of(context)!.refresh),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _errorMessage = null),
                      icon: Icon(Icons.close,
                          color: Colors.red.shade600, size: 18),
                    ),
                  ],
                ),
              ),

            // OTP list
            if (_otps.isNotEmpty) ...[
              Text(
                'OTPs (${_otps.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ..._otps.map((otp) => _buildOtpCard(otp)),
            ] else if (!_isLoading && _errorMessage == null) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.security, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(AppLocalizations.of(context)?.noOtpsAvailable ??
                          'No OTPs available'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard(OtpModel otp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otp.tag ?? 'Untitled OTP',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${otp.code}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B46C1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${_getStatusText(otp)}',
                        style: TextStyle(
                          color: _getStatusColor(otp),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Expires: ${_formatDateTime(otp.expiresAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _copyToClipboard(otp.code),
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy code',
                    ),
                    IconButton(
                      onPressed: () => _verifyOtp(otp.code),
                      icon: const Icon(Icons.verified, size: 18),
                      tooltip: 'Verify OTP',
                    ),
                    IconButton(
                      onPressed: () => _burnOtp(otp),
                      icon: const Icon(Icons.delete, size: 18),
                      tooltip: 'Burn OTP',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(OtpModel otp) {
    if (otp.isBurned) return 'Burned';
    if (otp.isUsed) return 'Used';
    if (otp.isExpired) return 'Expired';
    return 'Valid';
  }

  Color _getStatusColor(OtpModel otp) {
    if (otp.isBurned) return Colors.red;
    if (otp.isUsed) return Colors.orange;
    if (otp.isExpired) return Colors.grey;
    return Colors.green;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppLocalizations.of(context)!.codeCopiedToClipboard),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
