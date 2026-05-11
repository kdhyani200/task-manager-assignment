class Task {
  final String? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.isCompleted,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
