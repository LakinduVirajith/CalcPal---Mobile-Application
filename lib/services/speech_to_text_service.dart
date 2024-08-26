import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();

  Future<bool> checkAndRequestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<bool> initializeSpeechToText({
    required Function onError,
    required Function(String) onStatus,
  }) async {
    return await _speechToText.initialize(
      onError: (error) => onError(error),
      onStatus: (status) => onStatus(status),
    );
  }

  void startListening({
    required String localeId,
    required Function(String) onResult,
  }) {
    _speechToText.listen(
      localeId: localeId,
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
