import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

class VoiceService {
  final FlutterTts tts = FlutterTts();
  final AudioRecorder recorder = AudioRecorder();

  Future<String> recordAndRecognize() async {
    final hasPermission = await recorder.hasPermission();
    if (!hasPermission) return "No mic permission";

    await recorder.start(
      const RecordConfig(),
      path: 'recording.m4a', // Optional: specify file path
    );

    await Future.delayed(const Duration(seconds: 3));

    final path = await recorder.stop();

    if (path == null) return "No audio";

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('YOUR_GOOGLE_SPEECH_API_ENDPOINT'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    return responseBody.contains("red") ? "red" : "unknown";
  }

  Future<void> speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.speak(text);
  }
}