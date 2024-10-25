import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  Timer? _stopListeningTimer;

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
    required void Function() onDone,
  }) {
    _speechToText.listen(
      localeId: localeId,
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );

    _stopListeningTimer = Timer(const Duration(seconds: 6), () async {
      await stopListening();
      onDone();
    });
  }

  Future<void> stopListening() async {
    _stopListeningTimer?.cancel();
    await _speechToText.stop();
  }
}
