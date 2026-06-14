/// One chapter of a book — a title and the asset path to its markdown file.
class Chapter {
  final String title;
  final String file;

  const Chapter({required this.title, required this.file});

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        title: json['title'] as String,
        file: json['file'] as String,
      );
}

/// A book in the reader: metadata plus an ordered list of chapters.
class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final List<Chapter> chapters;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        description: json['description'] as String,
        chapters: (json['chapters'] as List)
            .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
