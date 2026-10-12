import 'package:flutter/services.dart';

final class AppSound {
  const AppSound._();

  static Future<void> tap() async {
    await SystemSound.play(SystemSoundType.click);
  }
}
