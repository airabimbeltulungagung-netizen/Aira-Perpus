import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/member.dart';
import '../models/transaction.dart';

class TransactionsTab extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Book> books;
  final List<Member> members;
  final Function(int bookId, int memberId) onProcessBorrow;
  final Function(int txId) onProcessReturn;
  final Function(String message, {bool isError}) triggerSnackBar;

  const TransactionsTab({
    Key? key,
    required this.transactions,
    required this.books,
    required this.members,
    required this.onProcessBorrow,
    required this.onProcessReturn,
    required this.triggerSnackBar,
  }) : super(key: key);

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  @override
  Widget build(BuildContext context) {
    final activeLoans =
        widget.transactions.where((t) => t.status == 'borrowed').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sirkulasi Peminjaman Buku',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showReturnDialog(),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Pengembalian (Scan)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E8A5F),
                    side: const BorderSide(color: Color(0xFF1E8A5F)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showBorrowDialog(),
                  icon: const Icon(Icons.qr_code_scanner_outlined, size: 16),
                  label: const Text('Catat Pinjaman (Scan)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8A5F),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Live Active Circulation Table
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buku yang Sedang Dipinjam Siswa (Sirkulasi Aktif)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                activeLoans.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                        child: Center(
                          child: Text(
                              'Semua buku berada di rak. Tidak ada peminjaman aktif.',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeLoans.length,
                        itemBuilder: (context, idx) {
                          final tx = activeLoans[idx];
                          final bk = widget.books.firstWhere(
                            (b) => b.id == tx.bookId,
                            orElse: () => Book(
                                id: 0,
                                title: 'Buku',
                                author: '',
                                category: '',
                                isbn: '',
                                totalStock: 0,
                                available: 0),
                          );
                          final student = widget.members.firstWhere(
                            (m) => m.id == tx.memberId,
                            orElse: () => Member(
                                id: 0, name: 'Siswa', nis: '', memberClass: ''),
                          );

                          return Card(
                            elevation: 0,
                            color: Colors.orange.withOpacity(0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: Colors.orange.withOpacity(0.12)),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(student.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        Text(
                                            'ISBN BARCODE: ${bk.isbn} | Buku: "${bk.title}"',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        Text('Diberikan pada: ${tx.borrowDate}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1E8A5F),
                                      elevation: 0,
                                      side: const BorderSide(
                                          color: Color(0xFFE2E8F0)),
                                    ),
                                    onPressed: () =>
                                        widget.onProcessReturn(tx.id),
                                    child: const Text('Kembalikan',
                                        style: TextStyle(fontSize: 12)),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBorrowDialog() {
    int? selectedBookId;
    int? selectedMemberId;
    final scanNisCtrl = TextEditingController();
    final scanIsbnCtrl = TextEditingController();
    String simFeedback = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSubState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: Color(0xFF1E8A5F)),
                  SizedBox(width: 8),
                  Text('Proses Surat Pinjam'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Simulasi Hardware Barcode Scanner',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Color(0xFF156444))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: scanNisCtrl,
                            decoration: const InputDecoration(
                                labelText:
                                    'Scan Kartu Siswa (Ketik NIS & tekan ENTER)',
                                labelStyle: TextStyle(fontSize: 10)),
                            onSubmitted: (val) {
                              try {
                                final found = widget.members
                                    .firstWhere((m) => m.nis == val.trim());
                                setSubState(() {
                                  selectedMemberId = found.id;
                                  simFeedback =
                                      "Siswa terdeteksi: ${found.name}";
                                });
                              } catch (e) {
                                setSubState(() {
                                  simFeedback =
                                      "Siswa dengan NIS $val tidak terdaftar!";
                                });
                              }
                            },
                          ),
                          TextField(
                            controller: scanIsbnCtrl,
                            decoration: const InputDecoration(
                                labelText:
                                    'Scan Barcode Buku (Ketik ISBN & tekan ENTER)',
                                labelStyle: TextStyle(fontSize: 10)),
                            onSubmitted: (val) {
                              try {
                                final found = widget.books
                                    .firstWhere((b) => b.isbn == val.trim());
                                setSubState(() {
                                  selectedBookId = found.id;
                                  simFeedback =
                                      "Buku terdeteksi: \"${found.title}\"";
                                });
                              } catch (e) {
                                setSubState(() {
                                  simFeedback =
                                      "Buku dengan ISBN $val tidak ditemukan!";
                                });
                              }
                            },
                          ),
                          if (simFeedback.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(simFeedback,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.blue)),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Atau Pilih Manual Di Bawah:'),
                    DropdownButtonFormField<int>(
                      value: selectedMemberId,
                      decoration:
                          const InputDecoration(labelText: 'Pilih Siswa'),
                      items: widget.members.map((m) {
                        return DropdownMenuItem(
                            value: m.id, child: Text('${m.nis} - ${m.name}'));
                      }).toList(),
                      onChanged: (val) =>
                          setSubState(() => selectedMemberId = val),
                    ),
                    DropdownButtonFormField<int>(
                      value: selectedBookId,
                      decoration:
                          const InputDecoration(labelText: 'Pilih Buku'),
                      items:
                          widget.books.where((b) => b.available > 0).map((b) {
                        return DropdownMenuItem(
                            value: b.id, child: Text(b.title));
                      }).toList(),
                      onChanged: (val) =>
                          setSubState(() => selectedBookId = val),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8A5F),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    if (selectedBookId != null && selectedMemberId != null) {
                      widget.onProcessBorrow(
                          selectedBookId!, selectedMemberId!);
                      Navigator.pop(context);
                    } else {
                      widget.triggerSnackBar('Siswa dan Buku harus terpilih.',
                          isError: true);
                    }
                  },
                  child: const Text('Proses Pinjam'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showReturnDialog() {
    int? selectedTxId;
    final scanIsbnCtrl = TextEditingController();
    String simFeedback = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSubState) {
            final activeLoans = widget.transactions
                .where((t) => t.status == 'borrowed')
                .toList();

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.assignment_return_outlined,
                      color: Color(0xFF1E8A5F)),
                  SizedBox(width: 8),
                  Text('Proses Surat Kembali'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Simulasi Barcode Scan Pengembalian',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Color(0xFF156444))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: scanIsbnCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Ketik ISBN Buku & tekan ENTER',
                                labelStyle: TextStyle(fontSize: 10)),
                            onSubmitted: (val) {
                              try {
                                final book = widget.books
                                    .firstWhere((b) => b.isbn == val.trim());
                                final tx = activeLoans
                                    .firstWhere((t) => t.bookId == book.id);
                                final student = widget.members
                                    .firstWhere((m) => m.id == tx.memberId);
                                setSubState(() {
                                  selectedTxId = tx.id;
                                  simFeedback =
                                      "Siswa terdeteksi: ${student.name} meminjam buku \"${book.title}\"";
                                });
                              } catch (e) {
                                setSubState(() {
                                  simFeedback =
                                      "Buku dengan ISBN $val sedang tidak dipinjam!";
                                });
                              }
                            },
                          ),
                          if (simFeedback.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(simFeedback,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.blue)),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Atau Pilih Transaksi Manual Di Bawah:'),
                    DropdownButtonFormField<int>(
                      value: selectedTxId,
                      decoration: const InputDecoration(
                          labelText: 'Pilih Transaksi Aktif'),
                      items: activeLoans.map((t) {
                        final b = widget.books.firstWhere(
                          (book) => book.id == t.bookId,
                          orElse: () => Book(
                              id: 0,
                              title: 'Buku',
                              author: '',
                              category: '',
                              isbn: '',
                              totalStock: 0,
                              available: 0),
                        );
                        final m = widget.members.firstWhere(
                          (mem) => mem.id == t.memberId,
                          orElse: () => Member(
                              id: 0, name: 'Siswa', nis: '', memberClass: ''),
                        );
                        return DropdownMenuItem(
                            value: t.id, child: Text('${m.name} - ${b.title}'));
                      }).toList(),
                      onChanged: (val) => setSubState(() => selectedTxId = val),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8A5F),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    if (selectedTxId != null) {
                      widget.onProcessReturn(selectedTxId!);
                      Navigator.pop(context);
                    } else {
                      widget.triggerSnackBar(
                          'Silakan pilih data transaksi pengembalian terlebih dahulu.',
                          isError: true);
                    }
                  },
                  child: const Text('Proses Kembali'),
                )
              ],
            );
          },
        );
      },
    );
  }
}
