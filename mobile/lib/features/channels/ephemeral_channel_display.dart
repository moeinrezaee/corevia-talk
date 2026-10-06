import 'dart:math' as math;

import 'channel.dart';
import '../../shared/i18n/app_language.dart';
import '../../shared/i18n/persian_date.dart';

class EphemeralChannelDisplay {
  final String? detailLabel;
  final String tooltipLabel;

  const EphemeralChannelDisplay({
    required this.detailLabel,
    required this.tooltipLabel,
  });
}

bool isEphemeralChannel(Channel channel) =>
    channel.ttlSeconds != null || channel.ttlDeadline != null;

EphemeralChannelDisplay? ephemeralChannelDisplay(
  Channel channel, {
  DateTime? now,
}) {
  if (!isEphemeralChannel(channel)) return null;

  final deadline = channel.ttlDeadline;
  final remainingSeconds = deadline == null
      ? null
      : ((deadline.millisecondsSinceEpoch -
                    (now ?? DateTime.now()).millisecondsSinceEpoch) /
                1000)
            .ceil();

  if (remainingSeconds == null) {
    final ttlSeconds = channel.ttlSeconds;
    return EphemeralChannelDisplay(
      detailLabel: ttlSeconds == null ? null : formatCompactTtl(ttlSeconds),
      tooltipLabel: ttlSeconds == null
          ? tl('Ephemeral channel. Cleans up automatically after inactivity.')
          : tlt('Ephemeral channel. Cleans up after {0} of inactivity.', [
              formatVerboseTtl(ttlSeconds),
            ]),
    );
  }

  final compactRemaining = formatCompactRemaining(remainingSeconds);
  final verboseRemaining = formatVerboseRemaining(remainingSeconds);
  final absoluteDeadlineLabel = formatAbsoluteDeadline(deadline!);

  return EphemeralChannelDisplay(
    detailLabel: compactRemaining,
    tooltipLabel: compactRemaining == tl('Cleanup due')
        ? tl('Ephemeral channel. Cleanup is due now.')
        : tlt('Ephemeral channel. Cleans up {0}. Scheduled for {1}.', [
            verboseRemaining,
            absoluteDeadlineLabel,
          ]),
  );
}

String formatCompactRemaining(int remainingSeconds) {
  if (remainingSeconds <= 0) return tl('Cleanup due');
  if (remainingSeconds <= 60) return tlt('{0}m left', ['1']);
  if (remainingSeconds < 60 * 60) {
    return tlt('{0}m left', ['${math.max(1, (remainingSeconds / 60).ceil())}']);
  }
  if (remainingSeconds < 60 * 60 * 24) {
    return tlt('{0}h left', [
      '${math.max(1, (remainingSeconds / (60 * 60)).ceil())}',
    ]);
  }
  return tlt('{0}d left', [
    '${math.max(1, (remainingSeconds / (60 * 60 * 24)).ceil())}',
  ]);
}

String formatVerboseRemaining(int remainingSeconds) {
  if (remainingSeconds <= 0) return tl('now');
  if (remainingSeconds <= 60) return tl('in 1 minute');
  if (remainingSeconds < 60 * 60) {
    final minutes = math.max(1, (remainingSeconds / 60).ceil());
    return tlt(minutes == 1 ? 'in {0} minute' : 'in {0} minutes', ['$minutes']);
  }
  if (remainingSeconds < 60 * 60 * 24) {
    final hours = math.max(1, (remainingSeconds / (60 * 60)).ceil());
    return tlt(hours == 1 ? 'in {0} hour' : 'in {0} hours', ['$hours']);
  }
  final days = math.max(1, (remainingSeconds / (60 * 60 * 24)).ceil());
  return tlt(days == 1 ? 'in {0} day' : 'in {0} days', ['$days']);
}

String formatCompactTtl(int ttlSeconds) {
  if (ttlSeconds < 60) return '${math.max(1, ttlSeconds)}s TTL';
  if (ttlSeconds < 60 * 60) {
    return '${math.max(1, (ttlSeconds / 60).ceil())}m TTL';
  }
  if (ttlSeconds < 60 * 60 * 24) {
    return '${math.max(1, (ttlSeconds / (60 * 60)).ceil())}h TTL';
  }
  return '${math.max(1, (ttlSeconds / (60 * 60 * 24)).ceil())}d TTL';
}

String formatVerboseTtl(int ttlSeconds) {
  if (usesPersianCalendar) return _persianVerboseTtl(ttlSeconds);
  if (ttlSeconds < 60) {
    final seconds = math.max(1, ttlSeconds);
    return '$seconds second${seconds == 1 ? '' : 's'}';
  }
  if (ttlSeconds < 60 * 60) {
    final minutes = math.max(1, (ttlSeconds / 60).ceil());
    return '$minutes minute${minutes == 1 ? '' : 's'}';
  }
  if (ttlSeconds < 60 * 60 * 24) {
    final hours = math.max(1, (ttlSeconds / (60 * 60)).ceil());
    return '$hours hour${hours == 1 ? '' : 's'}';
  }
  final days = math.max(1, (ttlSeconds / (60 * 60 * 24)).ceil());
  return '$days day${days == 1 ? '' : 's'}';
}

String formatAbsoluteDeadline(DateTime deadline) {
  if (usesPersianCalendar) {
    return '${persianMonthDay(deadline)}، ${persianTime(deadline)}';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = deadline.toLocal();
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${months[local.month - 1]} ${local.day}, $hour12:$minute $period';
}

String _persianVerboseTtl(int ttlSeconds) {
  if (ttlSeconds < 60) {
    return toPersianDigits('${math.max(1, ttlSeconds)} ثانیه');
  }
  if (ttlSeconds < 60 * 60) {
    return toPersianDigits('${math.max(1, (ttlSeconds / 60).ceil())} دقیقه');
  }
  if (ttlSeconds < 60 * 60 * 24) {
    return toPersianDigits(
      '${math.max(1, (ttlSeconds / (60 * 60)).ceil())} ساعت',
    );
  }
  return toPersianDigits(
    '${math.max(1, (ttlSeconds / (60 * 60 * 24)).ceil())} روز',
  );
}
