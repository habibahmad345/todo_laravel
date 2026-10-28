class Task {
  final int id;
  final String title;
  final String? category;
  final String? dueDate;
  final String? reminderTime;
  final bool isPinned;
  final bool isCompleted;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.category,
    this.dueDate,
    this.reminderTime,
    required this.isPinned,
    required this.isCompleted,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> j) {
    final time = j['reminder_time'] as String?;
    final done = j['completed_at'] as String?;
    return Task(
      id: j['id'],
      title: j['title'],
      category: j['category']?['name'],
      dueDate: j['due_date'],
      reminderTime:
          time != null && time.length >= 5 ? time.substring(0, 5) : time,
      isPinned: j['is_pinned'] == true,
      isCompleted: j['is_completed'] == true,
      completedAt:
          done == null ? null : DateTime.tryParse(done.replaceFirst(' ', 'T')),
    );
  }

  bool get completedToday {
    if (completedAt == null) return false;
    final n = DateTime.now();
    return completedAt!.year == n.year &&
        completedAt!.month == n.month &&
        completedAt!.day == n.day;
  }
}