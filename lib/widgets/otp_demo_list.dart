import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/utils/otp_data_parser.dart';

/// Demo widget to show how to display OTP data from the curl response
class OtpDemoList extends StatefulWidget {
  /// Sample JSON data from your curl response
  final String jsonData;

  const OtpDemoList({
    super.key,
    required this.jsonData,
  });

  @override
  State<OtpDemoList> createState() => _OtpDemoListState();
}

class _OtpDemoListState extends State<OtpDemoList> {
  List<OtpModel> _otps = [];
  List<OtpModel> _filteredOtps = [];
  String _currentFilter = 'all';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOtpData();
  }

  void _loadOtpData() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parse the JSON data using our utility
      _otps = OtpDataParser.parseFromApiResponse(widget.jsonData);
      _applyFilter();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredOtps = OtpDataParser.filterOtps(_otps, _currentFilter);
      // Sort by date (newest first)
      _filteredOtps = OtpDataParser.sortByDate(_filteredOtps);
    });
  }

  void _changeFilter(String filter) {
    _currentFilter = filter;
    _applyFilter();
  }

  void _copyOtpCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.otpCodeCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statistics = OtpDataParser.getOtpStatistics(_otps);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myOtps),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(statistics, l10n),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorOccurred,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? l10n.unknownError,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadOtpData,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, int> statistics, AppLocalizations l10n) {
    return Column(
      children: [
        // Statistics Card
        _buildStatisticsCard(statistics, l10n),

        // Filter Buttons
        _buildFilterButtons(l10n),

        // OTP List
        Expanded(
          child:
              _filteredOtps.isEmpty ? _buildEmptyState(l10n) : _buildOtpList(),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(
      Map<String, int> statistics, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(l10n.allOtps, statistics['total']!, Colors.blue),
          _buildStatItem(l10n.activeOtps, statistics['active']!, Colors.green),
          _buildStatItem(l10n.blockedOtps, statistics['blocked']!, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(l10n.allOtps, 'all', l10n),
          const SizedBox(width: 8),
          _buildFilterChip(l10n.activeOtps, 'active', l10n),
          const SizedBox(width: 8),
          _buildFilterChip(l10n.blockedOtps, 'blocked', l10n),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, AppLocalizations l10n) {
    final isSelected = _currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _changeFilter(filter);
      },
      selectedColor: const Color(0xFF6B46C1).withOpacity(0.2),
      checkmarkColor: const Color(0xFF6B46C1),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noOtpsFound,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noOtpsFoundDescription,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOtps.length,
      itemBuilder: (context, index) {
        final otp = _filteredOtps[index];
        return _buildOtpCard(otp);
      },
    );
  }

  Widget _buildOtpCard(OtpModel otp) {
    final l10n = AppLocalizations.of(context)!;

    // Determine status
    String status;
    Color statusColor;
    IconData statusIcon;

    if (otp.isBurned) {
      status = l10n.statusBurned;
      statusColor = Colors.grey;
      statusIcon = Icons.local_fire_department;
    } else if (otp.isUsed) {
      status = l10n.statusUsed;
      statusColor = Colors.orange;
      statusIcon = Icons.check_circle;
    } else if (otp.isExpired) {
      status = l10n.statusExpired;
      statusColor = Colors.red;
      statusIcon = Icons.access_time;
    } else {
      status = l10n.statusValid;
      statusColor = Colors.green;
      statusIcon = Icons.verified;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with code and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // OTP Code
                GestureDetector(
                  onTap: () => _copyOtpCode(otp.code),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          otp.code,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Color(0xFF6B46C1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.copy,
                          size: 16,
                          color: Color(0xFF6B46C1),
                        ),
                      ],
                    ),
                  ),
                ),

                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tag (if present)
            if (otp.tag != null && otp.tag!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.label,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    otp.tag!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Timestamps
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatCreatedTime(otp.createdAt, l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons.timer_off,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.otpExpiresAt}: ${_formatDateTime(otp.expiresAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCreatedTime(DateTime createdAt, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return l10n.createdNow;
    } else if (difference.inHours < 1) {
      return l10n.createdMinutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.createdHoursAgo(difference.inHours);
    } else {
      return l10n.createdDaysAgo(difference.inDays);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
