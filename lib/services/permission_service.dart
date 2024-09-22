import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Microphone permission not granted');
      }
    }
  }
}
