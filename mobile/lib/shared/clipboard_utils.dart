import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'i18n/app_language.dart';

Future<void> copyToClipboard(
  BuildContext context,
  String text, {
  String? message,
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message ?? tl('Copied to clipboard')),
      duration: const Duration(seconds: 2),
    ),
  );
}
