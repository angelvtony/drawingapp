import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class VoiceService {
  final FlutterTts tts = FlutterTts();
  final AudioRecorder recorder = AudioRecorder();

  Future<String> recordAndRecognize() async {
    // Check microphone permission
    final hasPermission = await recorder.hasPermission();
    if (!hasPermission) return "No mic permission";

    // Prepare file path
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/recording.wav';

    // Start recording with mono channel and 16kHz sample rate
    await recorder.start(
      const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,     // ✅ Required by Google API
          numChannels: 1,        // ✅ Must be mono
          bitRate: 256000        // Optional: ensure good quality
      ),
      path: filePath,
    );

    // Record for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    final path = await recorder.stop();

    if (path == null) return "No audio recorded";

    // Read and encode the file
    final bytes = await File(path).readAsBytes();
    final base64Audio = base64Encode(bytes);

    // Send to Google Speech-to-Text API
    final response = await http.post(
      Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=GOOGLE_API_KEY'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "config": {
          "encoding": "LINEAR16",
          "sampleRateHertz": 16000,
          "languageCode": "en-US"
        },
        "audio": {
          "content": base64Audio
        }
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final transcript = result['results']?[0]?['alternatives']?[0]?['transcript'];
      return transcript?.toLowerCase() ?? "unknown";
    } else {
      print("Google Speech API error: ${response.body}");
      return "error";
    }
  }

  Future<void> speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.speak(text);
  }
}