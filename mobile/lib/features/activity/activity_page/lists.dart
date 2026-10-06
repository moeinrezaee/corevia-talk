part of '../activity_page.dart';

/// Reminders surface for the Reminders filter — due/pending NIP-ER
/// reminders that deep-link to their target message.
class _RemindersList extends ConsumerWidget {
  final ScrollController scrollController;
  final void Function(Reminder reminder) onOpen;
  final Future<void> Function() onRefresh;

  const _RemindersList({
    required this.scrollController,
    required this.onOpen,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    final reminders = [
      for (final r in remindersAsync.value ?? const <Reminder>[])
        if (r.status == 'pending') r,
    ];

    if (remindersAsync.isLoading && reminders.isEmpty) {
      return Center(
        child: BuzzLoadingIndicator(
          size: 44,
          semanticLabel: tl('Loading reminders'),
        ),
      );
    }
    if (reminders.isEmpty) {
      return _EmptySurface(
        icon: LucideIcons.clock,
        message: tl('No reminders'),
        detail: tl('Reminders you set will show up here.'),
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return BeeRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: _activityScrollPadding(context),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          final due = reminder.isDue(now);
          final title = reminder.note?.trim().isNotEmpty == true
              ? reminder.note!.trim()
              : reminder.target?.preview ?? tl('Reminder');
          return ListTile(
            key: ValueKey('reminder-row-${reminder.id}'),
            leading: Icon(
              due ? LucideIcons.bellRing : LucideIcons.clock,
              size: 20,
              color: due
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: reminder.notBefore != null
                ? Text(
                    due
                        ? tl('Due now')
                        : tlt('Due {0}', [
                            _inboxTimestamp(reminder.notBefore!),
                          ]),
                  )
                : null,
            onTap: () => onOpen(reminder),
          );
        },
      ),
    );
  }
}

/// Drafts surface for the Drafts filter — locally saved unsent composer
/// text that reopens the target composer.
class _DraftsList extends ConsumerWidget {
  final List<ComposeDraft> drafts;
  final ScrollController scrollController;
  final Map<String, Channel> channelById;
  final String? myPubkey;
  final void Function(ComposeDraft draft) onOpen;
  final void Function(ComposeDraft draft) onDelete;

  const _DraftsList({
    required this.drafts,
    required this.scrollController,
    required this.channelById,
    required this.myPubkey,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(identityNameSourcesProvider);
    if (drafts.isEmpty) {
      return _EmptySurface(
        icon: LucideIcons.filePen,
        message: tl('No drafts'),
        detail: tl('Unsent messages you start composing will show up here.'),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: _activityScrollPadding(context),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        final channel = channelById[draft.channelId];
        final destination = channel == null
            ? tl('Unavailable channel')
            : channel.isDm
            ? resolveDmChannelDisplayLabel(
                channel,
                currentPubkey: myPubkey,
                names: names,
              )
            : '#${channel.name}';
        return ListTile(
          key: ValueKey('draft-row-${draft.key}'),
          leading: Icon(
            LucideIcons.filePen,
            size: 20,
            color: context.colors.onSurfaceVariant,
          ),
          title: Text(draft.text, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            draft.threadHeadId != null
                ? tlt('Thread in {0}', [destination])
                : destination,
          ),
          trailing: IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18),
            tooltip: tl('Delete draft'),
            onPressed: () => onDelete(draft),
          ),
          onTap: () => onOpen(draft),
        );
      },
    );
  }
}

/// Inbox list timestamp — desktop's `formatInboxTimestamp`:
/// time today, "Yesterday", short date this year, dated otherwise.
String _inboxTimestamp(int unixSeconds, {DateTime? now}) {
  final current = now ?? DateTime.now();
  if (usesPersianCalendar) {
    final instant = DateTime.fromMillisecondsSinceEpoch(
      unixSeconds * 1000,
      isUtc: true,
    );
    final date = toTehranTime(instant);
    final today = toTehranTime(current);
    final dayDiff = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    if (dayDiff == 0) return persianTime(instant);
    if (dayDiff == 1) return tl('Yesterday');
    final sameYear =
        gregorianToJalali(date.year, date.month, date.day).year ==
        gregorianToJalali(today.year, today.month, today.day).year;
    return persianMonthDay(instant, withYear: !sameYear);
  }
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(date.year, date.month, date.day);
  final dayDiff = today.difference(day).inDays;

  if (dayDiff == 0) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }
  if (dayDiff == 1) return tl('Yesterday');

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
  final label = '${months[date.month - 1]} ${date.day}';
  return date.year == current.year ? label : '$label, ${date.year}';
}
