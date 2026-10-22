import 'package:flutter/services.dart';

/// Plays the platform's rejection/error feedback without affecting the action.
Future<void> errorHaptic() async {
  try {
    await const MethodChannel('corevia-talk/haptics').invokeMethod<void>('error');
  } on PlatformException {
    // Feedback is optional on devices without a haptic engine.
  } on MissingPluginException {
    await HapticFeedback.heavyImpact();
  }
}
