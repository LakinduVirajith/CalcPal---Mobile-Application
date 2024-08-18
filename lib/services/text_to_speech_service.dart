import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TextToSpeechService {
  // RETRIEVE THE API KEY FROM ENVIRONMENT VARIABLES
  final String _apiKey = dotenv.env['SPEECH_SERVICE_API_KEY'] ?? '';
  final String _region = 'centralindia';
  bool _isInitialized = false;

  Future<BytesSource> synthesizeSpeech(String text, String languageCode) async {
    // INITIALIZE THE TTS SERVICE
    if (!_isInitialized) {
      TtsMicrosoft.init(
        subscriptionKey: _apiKey,
        region: _region,
        withLogs: true,
      );
      _isInitialized = true;
    }

    // GET THE LIST OF VOICES
    final voicesResponse = await TtsMicrosoft.getVoices();
    final voices = voicesResponse.voices;

    // PICK A VOICE BASED ON LANGUAGE CODE
    final voice = voices
        .where((element) => element.locale.code.startsWith(languageCode))
        .toList(growable: false)
        .first;

    // SET TTS PARAMETERS
    final ttsParams = TtsParamsMicrosoft(
      voice: voice,
      audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
      text: text,
      rate: 'default',
      pitch: 'default',
    );

    // CONVERT TEXT TO SPEECH
    final ttsResponse = await TtsMicrosoft.convertTts(ttsParams);

    // GET THE AUDIO BYTES
    final audioBytes = ttsResponse.audio.buffer.asByteData();

    return BytesSource(audioBytes.buffer.asUint8List());
  }
}
