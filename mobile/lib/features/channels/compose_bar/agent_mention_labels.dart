part of '../compose_bar.dart';

Set<String> _agentMentionLabels({
  required Map<String, MentionCandidate> bindings,
}) => {
  for (final entry in bindings.entries)
    if (entry.value.isAgent) entry.key,
};

List<MentionCandidate> _resolveComposerMentions(
  String text,
  Map<String, MentionCandidate> selected,
  List<MentionCandidate> members,
  List<MentionCandidate> restoredCandidates,
) {
  // A broken record cannot fall back to a same-name roster entry.
  if (selected.values.any((c) => c.pubkey.isEmpty)) {
    throw FormatException(
      tl(
        'Saved mention identity is invalid. Clear the draft and select again.',
      ),
    );
  }
  final candidates = <String, List<MentionCandidate>>{
    for (final e in selected.entries) e.key.toLowerCase(): [e.value],
  };
  final selectedNames = candidates.keys.toSet();
  for (final member in members) {
    final label = member.label.toLowerCase();
    if (!selectedNames.contains(label)) (candidates[label] ??= []).add(member);
  }
  final winners = <String, MentionCandidate>{};
  for (final range in mentionOccurrences(text, candidates.keys)) {
    final identities = {
      for (final c in candidates[range.label]!) c.pubkey.toLowerCase(): c,
    };
    if (identities.length > 1) {
      throw FormatException(
        tlt(
          'The mention @{0} is ambiguous. Choose a recipient from the mention picker.',
          [range.label],
        ),
      );
    }
    for (final entry in identities.entries) {
      final selected = entry.value;
      final current = restoredCandidates
          .where((c) => c.pubkey == entry.key)
          .firstOrNull;
      if (selected.requiresRevalidation && current == null) {
        throw FormatException(
          tl(
            'Saved mention is no longer available. Select it again from the picker.',
          ),
        );
      }
      winners[entry.key] = selected.requiresRevalidation ? current! : selected;
    }
  }
  return winners.values.toList();
}
