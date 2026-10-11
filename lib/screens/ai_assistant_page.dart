import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  late stt.SpeechToText speech;
  final FlutterTts flutterTts = FlutterTts();

  bool isListening = false;
  bool isSpeaking = false;

  String recognizedText = '';
  String speechStatus = 'Ready to help';
  String assistantResponse =
      'Hello! I am EASE. How can I help you today?';

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    speak(assistantResponse);
  }

  Future<void> speak(String text) async {
    try {
      await flutterTts.setLanguage('en-IN');
      await flutterTts.setSpeechRate(0.45);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      if (!mounted) return;

      setState(() {
        isSpeaking = true;
        speechStatus = 'EASE is speaking...';
      });

      await flutterTts.speak(text);
    } catch (error) {
      debugPrint('Text-to-speech error: $error');

      if (!mounted) return;

      setState(() {
        isSpeaking = false;
        speechStatus = 'Unable to speak: $error';
      });
    }
  }

  String getResponse(String input) {
    final message = input.toLowerCase();

    if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! It is lovely to talk to you. How can I help?';
    } else if (message.contains('time')) {
      return 'I can help you with your daily activities. '
          'Please check your device for the current time.';
    } else if (message.contains('reminder') ||
        message.contains('medicine')) {
      return 'You can open My Reminders to manage your reminders. '
          'Would you like to add a reminder?';
    } else if (message.contains('emergency') ||
        message.contains('help')) {
      return 'If you are in immediate danger, please contact '
          'your local emergency service or a trusted person.';
    } else if (message.contains('thank')) {
      return 'You are very welcome! I am always happy to help.';
    } else {
      return 'I heard you say: $input. '
          'I am still learning how to help with that. '
          'Please try asking me about reminders or help.';
    }
  }

  Future<void> startListening() async {
    try {
      setState(() {
        speechStatus = 'Checking microphone...';
        recognizedText = '';
      });

      debugPrint('EASE: Initializing speech recognition');

      final available = await speech.initialize(
        onStatus: (status) {
          debugPrint('EASE speech status: $status');

          if (!mounted) return;

          setState(() {
            if (status == 'listening') {
              isListening = true;
              speechStatus = 'Listening... Please speak.';
            } else if (status == 'notListening' || status == 'done') {
              isListening = false;

              if (recognizedText.trim().isEmpty) {
                speechStatus =
                    'Stopped listening. No words were detected.';
              }
            } else {
              speechStatus = 'Speech status: $status';
            }
          });
        },
        onError: (error) {
          debugPrint('EASE speech error: ${error.errorMsg}');

          if (!mounted) return;

          setState(() {
            isListening = false;
            speechStatus = 'Speech error: ${error.errorMsg}';
          });
        },
      );

      debugPrint('EASE speech available: $available');

      if (!mounted) return;

      if (!available) {
        setState(() {
          isListening = false;
          speechStatus =
              'Speech recognition is unavailable in this browser.';
        });
        return;
      }

      await flutterTts.stop();

      if (!mounted) return;

      setState(() {
        isSpeaking = false;
        isListening = true;
        speechStatus = 'Starting microphone...';
      });

      await speech.listen(
        onResult: (result) {
          debugPrint(
            'EASE recognized words: ${result.recognizedWords}',
          );
          debugPrint('EASE final result: ${result.finalResult}');

          if (!mounted) return;

          setState(() {
            recognizedText = result.recognizedWords;

            speechStatus = recognizedText.trim().isEmpty
                ? 'Listening... No words detected yet.'
                : 'Words detected!';
          });

          if (result.finalResult &&
              result.recognizedWords.trim().isNotEmpty) {
            processSpeech(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
      );

      debugPrint('EASE: Listen command completed');
    } catch (error, stackTrace) {
      debugPrint('EASE microphone startup error: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        isListening = false;
        speechStatus = 'Microphone error: $error';
      });
    }
  }

  Future<void> processSpeech(String input) async {
    await speech.stop();

    if (!mounted) return;

    setState(() {
      isListening = false;
      recognizedText = input;
      assistantResponse = getResponse(input);
      speechStatus = 'Preparing response...';
    });

    await speak(assistantResponse);
  }

  Future<void> stopListening() async {
    try {
      await speech.stop();

      if (!mounted) return;

      setState(() {
        isListening = false;
        speechStatus = recognizedText.trim().isEmpty
            ? 'Listening stopped. No words were detected.'
            : 'Listening stopped.';
      });
    } catch (error) {
      debugPrint('EASE stop listening error: $error');
    }
  }

  Future<void> repeatResponse() async {
    await flutterTts.stop();

    if (!mounted) return;

    await speak(assistantResponse);
  }

  @override
  void dispose() {
    speech.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EASE AI Assistant',
          style: TextStyle(
            fontSize: 24,
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
                Icons.record_voice_over,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Hello! I am EASE.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                speechStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              if (recognizedText.isNotEmpty) ...[
                const Text(
                  'You said:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recognizedText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'EASE says:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                assistantResponse,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed:
                    isListening ? stopListening : startListening,
                icon: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  size: 28,
                ),
                label: Text(
                  isListening ? 'Stop Listening' : 'Tap to Talk',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: repeatResponse,
                icon: const Icon(Icons.volume_up, size: 26),
                label: const Text(
                  'Repeat Response',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
