class Note {
  final DateTime createdAt;
  final String body;

  const Note({this.createdAt, this.body});

  factory Note.fromJson(Map<String, dynamic> json) {
    return new Note(
      createdAt: DateTime.parse(json['createdAt']),
      body: json['body'],
    );
  }
}
