
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  Future<void> _makeEmergencyCall(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '112');

    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text(
              'Emergency Call',
              style: TextStyle(fontSize: 24),
            ),
            content: const Text(
              'Do you want to call emergency services now?',
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: const Text(
                  'Call Now',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    try {
      final bool launched = await launchUrl(phoneUri);

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open the phone app on this device.',
            ),
          ),
        );
      }
    } catch (error) {
      debugPrint('Emergency call error: $error');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Calling is not supported on this device.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Assistance',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.health_and_safety,
                color: Colors.red,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Need Emergency Help?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Press the button below to contact '
                'emergency services.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 85,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => _makeEmergencyCall(context),
                  icon: const Icon(
                    Icons.call,
                    size: 32,
                  ),
                  label: const Text(
                    'CALL 112',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'India emergency number: 112',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              const Text(
                'If possible, tell the emergency operator '
                'your location and what help you need.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
