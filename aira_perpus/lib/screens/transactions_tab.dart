import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/book.dart';
import '../models/member.dart';
import '../models/transaction.dart';
import '../utils/sound_utils.dart';

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
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext ctx) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Konfirmasi Pengembalian Buku'),
                                            content: Text(
                                                'Apakah Anda yakin siswa ${student.name} ingin mengembalikan buku "${bk.title}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(
                                                            0xFF1E8A5F)),
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  widget.onProcessReturn(tx.id);
                                                },
                                                child: const Text(
                                                    'Ya, Kembalikan',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BorrowScannerDialog(
          books: widget.books,
          members: widget.members,
          onProcessBorrow: widget.onProcessBorrow,
          triggerSnackBar: widget.triggerSnackBar,
        );
      },
    );
  }

  void _showReturnDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ReturnScannerDialog(
          transactions: widget.transactions,
          books: widget.books,
          members: widget.members,
          onProcessReturn: widget.onProcessReturn,
          triggerSnackBar: widget.triggerSnackBar,
        );
      },
    );
  }
}

class BorrowScannerDialog extends StatefulWidget {
  final List<Book> books;
  final List<Member> members;
  final Function(int bookId, int memberId) onProcessBorrow;
  final Function(String message, {bool isError}) triggerSnackBar;

  const BorrowScannerDialog({
    Key? key,
    required this.books,
    required this.members,
    required this.onProcessBorrow,
    required this.triggerSnackBar,
  }) : super(key: key);

  @override
  State<BorrowScannerDialog> createState() => _BorrowScannerDialogState();
}

class _BorrowScannerDialogState extends State<BorrowScannerDialog> {
  int? selectedBookId;
  int? selectedMemberId;
  final scanNisCtrl = TextEditingController();
  final scanIsbnCtrl = TextEditingController();
  String simFeedback = "";
  bool isCameraOpen = false;
  MobileScannerController? cameraController;

  @override
  void dispose() {
    scanNisCtrl.dispose();
    scanIsbnCtrl.dispose();
    cameraController?.dispose();
    super.dispose();
  }

  void _toggleCamera(bool val) {
    setState(() {
      isCameraOpen = val;
      if (isCameraOpen) {
        cameraController = MobileScannerController();
      } else {
        cameraController?.dispose();
        cameraController = null;
      }
    });
  }

  void _handleBarcode(String val) {
    SoundUtils.playBeep();
    final cleanVal = val.trim();
    if (cleanVal.isEmpty) return;

    // Check student NIS first
    try {
      final student = widget.members.firstWhere((m) => m.nis == cleanVal);
      setState(() {
        selectedMemberId = student.id;
        simFeedback =
            "Kamera Terdeteksi: Siswa ${student.name} (NIS $cleanVal)";
      });
      return;
    } catch (_) {}

    // Check book ISBN
    try {
      final book = widget.books.firstWhere((b) => b.isbn == cleanVal);
      if (book.available <= 0) {
        setState(() {
          simFeedback =
              "Kamera Terdeteksi: Buku \"${book.title}\" tapi stok habis!";
        });
      } else {
        setState(() {
          selectedBookId = book.id;
          simFeedback =
              "Kamera Terdeteksi: Buku \"${book.title}\" (ISBN $cleanVal)";
        });
      }
      return;
    } catch (_) {}

    setState(() {
      simFeedback =
          "Kamera Terdeteksi barcode \"$cleanVal\" tidak cocok dengan Siswa/Buku mana pun.";
    });
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle Camera Scanner section
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2FBF0),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color(0xFF2EBD82).withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.videocam,
                              color: Color(0xFF1E8A5F), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isCameraOpen
                                ? 'Kamera Scan Aktif'
                                : 'Gunakan Kamera HP/Laptop',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E8A5F)),
                          ),
                        ],
                      ),
                      Switch(
                        value: isCameraOpen,
                        activeColor: const Color(0xFF1E8A5F),
                        onChanged: _toggleCamera,
                      ),
                    ],
                  ),
                  if (isCameraOpen) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: MobileScanner(
                                controller: cameraController,
                                onDetect: (capture) {
                                  final List<Barcode> barcodes =
                                      capture.barcodes;
                                  for (final barcode in barcodes) {
                                    final String? val = barcode.rawValue;
                                    if (val != null) {
                                      _handleBarcode(val);
                                      break;
                                    }
                                  }
                                },
                              ),
                            ),
                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 2,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Input Scanner Fisik (Cepat & Akurat)',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF156444))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: scanNisCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Scan Kartu Siswa (Ketik NIS & tekan ENTER)',
                        labelStyle: TextStyle(fontSize: 10)),
                    onSubmitted: (val) {
                      try {
                        final found = widget.members
                            .firstWhere((m) => m.nis == val.trim());
                        setState(() {
                          selectedMemberId = found.id;
                          simFeedback = "Siswa terdeteksi: ${found.name}";
                        });
                      } catch (e) {
                        setState(() {
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
                        setState(() {
                          selectedBookId = found.id;
                          simFeedback = "Buku terdeteksi: \"${found.title}\"";
                        });
                      } catch (e) {
                        setState(() {
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
            const Text('Atau Pilih Manual Di Bawah:',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            DropdownButtonFormField<int>(
              value: selectedMemberId,
              decoration: const InputDecoration(
                  labelText: 'Pilih Siswa', isDense: true),
              items: widget.members.map((m) {
                return DropdownMenuItem(
                    value: m.id, child: Text('${m.nis} - ${m.name}'));
              }).toList(),
              onChanged: (val) => setState(() => selectedMemberId = val),
            ),
            DropdownButtonFormField<int>(
              value: selectedBookId,
              decoration:
                  const InputDecoration(labelText: 'Pilih Buku', isDense: true),
              items: widget.books.where((b) => b.available > 0).map((b) {
                return DropdownMenuItem(value: b.id, child: Text(b.title));
              }).toList(),
              onChanged: (val) => setState(() => selectedBookId = val),
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
              widget.onProcessBorrow(selectedBookId!, selectedMemberId!);
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
  }
}

class ReturnScannerDialog extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Book> books;
  final List<Member> members;
  final Function(int txId) onProcessReturn;
  final Function(String message, {bool isError}) triggerSnackBar;

  const ReturnScannerDialog({
    Key? key,
    required this.transactions,
    required this.books,
    required this.members,
    required this.onProcessReturn,
    required this.triggerSnackBar,
  }) : super(key: key);

  @override
  State<ReturnScannerDialog> createState() => _ReturnScannerDialogState();
}

class _ReturnScannerDialogState extends State<ReturnScannerDialog> {
  int? selectedTxId;
  final scanIsbnCtrl = TextEditingController();
  String simFeedback = "";
  bool isCameraOpen = false;
  MobileScannerController? cameraController;

  @override
  void dispose() {
    scanIsbnCtrl.dispose();
    cameraController?.dispose();
    super.dispose();
  }

  void _toggleCamera(bool val) {
    setState(() {
      isCameraOpen = val;
      if (isCameraOpen) {
        cameraController = MobileScannerController();
      } else {
        cameraController?.dispose();
        cameraController = null;
      }
    });
  }

  void _handleBarcode(String val) {
    SoundUtils.playBeep();
    final cleanVal = val.trim();
    if (cleanVal.isEmpty) return;

    final activeLoans =
        widget.transactions.where((t) => t.status == 'borrowed').toList();

    try {
      final book = widget.books.firstWhere((b) => b.isbn == cleanVal);
      final tx = activeLoans.firstWhere((t) => t.bookId == book.id);
      final student = widget.members.firstWhere((m) => m.id == tx.memberId);
      setState(() {
        selectedTxId = tx.id;
        simFeedback =
            "Kamera Terdeteksi: Siswa ${student.name} meminjam buku \"${book.title}\" (ISBN $cleanVal)";
      });
    } catch (_) {
      setState(() {
        simFeedback =
            "Kamera Terdeteksi: Buku dengan ISBN $cleanVal sedang tidak dipinjam!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLoans =
        widget.transactions.where((t) => t.status == 'borrowed').toList();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.assignment_return_outlined, color: Color(0xFF1E8A5F)),
          SizedBox(width: 8),
          Text('Proses Surat Kembali'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle Camera Section
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2FBF0),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color(0xFF2EBD82).withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.videocam,
                              color: Color(0xFF1E8A5F), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isCameraOpen
                                ? 'Kamera Scan Aktif'
                                : 'Gunakan Kamera HP/Laptop',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E8A5F)),
                          ),
                        ],
                      ),
                      Switch(
                        value: isCameraOpen,
                        activeColor: const Color(0xFF1E8A5F),
                        onChanged: _toggleCamera,
                      ),
                    ],
                  ),
                  if (isCameraOpen) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: MobileScanner(
                                controller: cameraController,
                                onDetect: (capture) {
                                  final List<Barcode> barcodes =
                                      capture.barcodes;
                                  for (final barcode in barcodes) {
                                    final String? val = barcode.rawValue;
                                    if (val != null) {
                                      _handleBarcode(val);
                                      break;
                                    }
                                  }
                                },
                              ),
                            ),
                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 2,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Scanner Fisik Peminjaman Selesai',
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
                        final tx =
                            activeLoans.firstWhere((t) => t.bookId == book.id);
                        final student = widget.members
                            .firstWhere((m) => m.id == tx.memberId);
                        setState(() {
                          selectedTxId = tx.id;
                          simFeedback =
                              "Siswa terdeteksi: ${student.name} meminjam buku \"${book.title}\"";
                        });
                      } catch (e) {
                        setState(() {
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
            const Text('Atau Pilih Transaksi Manual Di Bawah:',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            DropdownButtonFormField<int>(
              value: selectedTxId,
              decoration: const InputDecoration(
                  labelText: 'Pilih Transaksi Aktif', isDense: true),
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
                  orElse: () =>
                      Member(id: 0, name: 'Siswa', nis: '', memberClass: ''),
                );
                return DropdownMenuItem(
                    value: t.id, child: Text('${m.name} - ${b.title}'));
              }).toList(),
              onChanged: (val) => setState(() => selectedTxId = val),
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
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Pengembalian Buku'),
                    content: const Text(
                        'Apakah Anda yakin ingin menyelesaikan transaksi pengembalian buku ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E8A5F)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          widget.onProcessReturn(selectedTxId!);
                          Navigator.pop(context);
                        },
                        child: const Text('Ya, Selesaikan',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
              );
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
  }
}
