class Transaction {
  final int id;
  final int bookId;
  final int memberId;
  final String borrowDate;
  String? returnDate;
  String status; // 'borrowed' | 'returned'

  Transaction({
    required this.id,
    required this.bookId,
    required this.memberId,
    required this.borrowDate,
    this.returnDate,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'memberId': memberId,
        'borrowDate': borrowDate,
        'returnDate': returnDate,
        'status': status,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        bookId: json['book_id'] ?? json['bookId'],
        memberId: json['member_id'] ?? json['memberId'],
        borrowDate: json['borrow_date'] ?? json['borrowDate'] ?? '',
        returnDate: json['return_date'] ?? json['returnDate'],
        status: json['status'] ?? 'borrowed',
      );
}
