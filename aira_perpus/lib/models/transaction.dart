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
        'book_id': bookId,
        'member_id': memberId,
        'borrow_date': borrowDate,
        'return_date': returnDate,
        'status': status,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawBookId = json['book_id'] ?? json['bookId'];
    final rawMemberId = json['member_id'] ?? json['memberId'];

    return Transaction(
      // Menggunakan tryParse + toString() agar kebal terhadap error format angka maupun null
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      bookId: rawBookId != null ? int.tryParse(rawBookId.toString()) ?? 0 : 0,
      memberId:
          rawMemberId != null ? int.tryParse(rawMemberId.toString()) ?? 0 : 0,

      borrowDate: json['borrow_date'] ?? json['borrowDate'] ?? '',
      returnDate: json['return_date'] ?? json['returnDate'],
      status: json['status'] ?? 'borrowed',
    );
  }
}
