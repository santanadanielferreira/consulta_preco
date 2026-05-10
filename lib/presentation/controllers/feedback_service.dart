import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class FeedbackService {
  Future<void> success({
    required BuildContext context,
    required String message,
    required bool vibracaoAtiva,
  }) async {
    _show(context: context, message: message, isError: false);
    await SystemSound.play(SystemSoundType.click);

    final hasVibrator = await Vibration.hasVibrator();
    if (vibracaoAtiva && hasVibrator) {
      await Vibration.vibrate(duration: 60);
    }
  }

  void error({
    required BuildContext context,
    required String message,
  }) {
    _show(context: context, message: message, isError: true);
  }

  void info({
    required BuildContext context,
    required String message,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _show({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }
}
