class Book {
  final int id;
  final String title;
  final String author;
  final String category;
  final String isbn;
  final int totalStock;
  int available;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.isbn,
    required this.totalStock,
    required this.available,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'category': category,
        'isbn': isbn,
        'totalStock': totalStock,
        'available': available,
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        title: json['title'] ?? '',
        author: json['author'] ?? '',
        category: json['category'] ?? '',
        isbn: json['isbn'] ?? '',
        totalStock: json['total_stock'] ?? json['totalStock'] ?? 1,
        available: json['available'] ?? 1,
      );
}
