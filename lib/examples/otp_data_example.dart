import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/utils/otp_data_parser.dart';
import 'package:jetcv__utenti/widgets/otp_demo_list.dart';

/// Example demonstrating how to use OTP data parsing
class OtpDataExample extends StatelessWidget {
  const OtpDataExample({super.key});

  // This is your actual API response data
  static const String sampleApiResponse = '''
{
    "data": [
        {
            "id_otp": "8857b7b3-3375-4a75-808a-debe0f2724af",
            "id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
            "code": "908105",
            "code_hash": "74657bd8ce486777d302938e5d982ffaea466ac3b86bc52e114fa30629320c36",
            "tag": null,
            "created_at": "2025-09-07T07:40:49.869494+00:00",
            "updated_at": "2025-09-07T07:40:49.869494+00:00",
            "expires_at": "2025-09-07T07:45:49.869494+00:00",
            "used_at": null,
            "used_by_id_user": null,
            "burned_at": null,
            "id_legal_entity": null
        },
        {
            "id_otp": "b5763163-8ae8-41c3-ac05-aec1449f9bea",
            "id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
            "code": "550505",
            "code_hash": "901ddfc1baaa3eab050409c60a745b0bd37bc1c53bf1348066ecc47e6920c4bc",
            "tag": null,
            "created_at": "2025-09-07T07:40:46.220404+00:00",
            "updated_at": "2025-09-07T07:40:46.220404+00:00",
            "expires_at": "2025-09-07T07:45:46.220404+00:00",
            "used_at": null,
            "used_by_id_user": null,
            "burned_at": null,
            "id_legal_entity": null
        },
        {
            "id_otp": "4f4bd0cc-99aa-4f05-970b-bc9b2c2dd285",
            "id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
            "code": "796206",
            "code_hash": "6a0528bb8fa6384953d0a1a0061713269888031ec1887c8dd4c1733917e51ac8",
            "tag": "test-connection",
            "created_at": "2025-09-06T10:38:19.119687+00:00",
            "updated_at": "2025-09-06T10:38:19.119687+00:00",
            "expires_at": "2025-09-06T10:39:19.119687+00:00",
            "used_at": null,
            "used_by_id_user": null,
            "burned_at": null,
            "id_legal_entity": null
        },
        {
            "id_otp": "589ed7fe-36ad-4558-9c02-e3582cb014bf",
            "id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
            "code": "835881",
            "code_hash": "7cb6c9d8e1af8fed271ba8010ffeb527abdb87b2cbad7cf53e5cce90addb5214",
            "tag": null,
            "created_at": "2025-09-05T17:17:27.622155+00:00",
            "updated_at": "2025-09-05T17:17:27.622155+00:00",
            "expires_at": "2025-09-05T17:22:27.622155+00:00",
            "used_at": null,
            "used_by_id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
            "burned_at": null,
            "id_legal_entity": "bbab400f-b702-465c-bb5d-4804cad2128c"
        }
    ],
    "count": 133,
    "limit": 50,
    "offset": 0
}''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myOtps + ' - Demo'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OTP Data Parser Example',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This demo shows how to parse and display OTP data from your API responses. '
                  'The service has been updated to handle all response formats:\n'
                  '• List: { data: [...], count: number, limit: number, offset: number }\n'
                  '• Create: { data: {...} }\n'
                  '• Update: { data: {...} }',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Demo Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OtpDemoList(
                        jsonData: sampleApiResponse,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('View OTP Demo List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Usage Example
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usage Example:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '''// 1. Parse LIST response { data: [...] }
final otps = OtpDataParser.parseFromApiResponse(jsonString);

// 2. Parse CREATE response { data: {...} }
final newOtp = OtpDataParser.parseFromCreateResponse(createJsonString);

// 3. Parse UPDATE response { data: {...} } (same format as create)
final updatedOtp = OtpDataParser.parseFromCreateResponse(updateJsonString);

// 4. Filter OTPs
final activeOtps = OtpDataParser.filterOtps(otps, 'active');
final blockedOtps = OtpDataParser.filterOtps(otps, 'blocked');

// 3. Get statistics
final stats = OtpDataParser.getOtpStatistics(otps);
print('Total: \${stats['total']}');
print('Active: \${stats['active']}');

// 4. Sort by date
final sortedOtps = OtpDataParser.sortByDate(otps);

// 5. Use in your ListView
ListView.builder(
  itemCount: sortedOtps.length,
  itemBuilder: (context, index) {
    final otp = sortedOtps[index];
    return ListTile(
      title: Text(otp.code),
      subtitle: Text(otp.tag ?? 'No tag'),
      trailing: Text(otp.isValid ? 'Valid' : 'Expired'),
    );
  },
)''',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
