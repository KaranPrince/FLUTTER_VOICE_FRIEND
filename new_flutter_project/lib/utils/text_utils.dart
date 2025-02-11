Map<String, dynamic> segmentTextBySentence(String text) {
  final sentencePattern = RegExp(r'(?<=[.!?])\s+|\n+');
  final sentences = text.split(sentencePattern);
  final completeSentences = sentences.sublist(0, sentences.length - 1);
  final remainingText = sentences.isNotEmpty ? sentences.last : '';
  return {
    'completeSentences': completeSentences,
    'remainingText': remainingText,
  };
}

String timeSinceLastCompleted(DateTime? lastCompleted) {
  if (lastCompleted == null) return '';

  final now = DateTime.now();
  final difference = now.difference(lastCompleted);

  if (difference.inDays >= 365) {
    final years = (difference.inDays / 365).floor();
    return years == 1 ? '1 year ago' : '$years years ago';
  } else if (difference.inDays >= 30) {
    final months = (difference.inDays / 30).floor();
    return months == 1 ? '1 month ago' : '$months months ago';
  } else if (difference.inDays >= 7) {
    final weeks = (difference.inDays / 7).floor();
    return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
  } else if (difference.inDays > 1) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 1) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 1) {
    return '${difference.inMinutes} mins ago';
  } else {
    return 'Just now';
  }
}
