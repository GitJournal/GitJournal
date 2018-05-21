class Note implements Comparable {
  final String id;
  final DateTime createdAt;
  final String body;

  const Note({this.createdAt, this.body, this.id});

  factory Note.fromJson(Map<String, dynamic> json) {
    return new Note(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "createdAt": createdAt.toIso8601String(),
      "body": body,
      "id": id,
    };
  }

  @override
  int get hashCode => id.hashCode ^ createdAt.hashCode ^ body.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          body == other.body &&
          createdAt == other.createdAt;

  @override
  String toString() {
    return 'Note{id: $id, body: $body, createdAt: $createdAt}';
  }

  @override
  int compareTo(other) => createdAt.compareTo(other.createdAt);
}
