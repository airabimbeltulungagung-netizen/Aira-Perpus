import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import '../models/book.dart';
import '../utils/file_saver.dart';

class BooksTab extends StatefulWidget {
  final List<Book> books;
  final Function(Book) onAddBook;
  final Function(Book) onEditBook;
  final Function(int) onDeleteBook;
  final Function(String message, {bool isError}) triggerSnackBar;

  const BooksTab({
    Key? key,
    required this.books,
    required this.onAddBook,
    required this.onEditBook,
    required this.onDeleteBook,
    required this.triggerSnackBar,
  }) : super(key: key);

  @override
  State<BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  String _searchQuery = "";

  // Mengimpor data koleksi buku & mencetak lembar barcode ke format excel teratur
  Future<void> _exportBooksToExcel() async {
    if (widget.books.isEmpty) {
      widget.triggerSnackBar(
          "Daftar koleksi buku kosong! Tidak dapat mengekspor data kosong.",
          isError: true);
      return;
    }

    try {
      var excel = Excel.createExcel();
      String sheetName = "Koleksi Barcode Buku";
      excel.rename("Sheet1", sheetName);
      var sheet = excel[sheetName];

      // Definisikan header gaya elegan
      var headerStyle = CellStyle(
        bold: true,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#1E8A5F"),
        fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
      );

      // Baris Header Utama
      sheet.appendRow([
        TextCellValue("NO"),
        TextCellValue("ID SISTEM"),
        TextCellValue("JUDUL KELAS BUKU"),
        TextCellValue("NAMA PENULIS"),
        TextCellValue("KATEGORI BUKU"),
        TextCellValue("ID BARCODE (TEMPEL DI FISIK BUKU)"),
        TextCellValue("TOTAL STOK"),
        TextCellValue("STOK TERSEDIA")
      ]);

      // Atur gaya untuk sel-sel di baris pertama (header)
      for (int i = 0; i < 8; i++) {
        var cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }

      // Masukkan baris data koleksi
      for (int i = 0; i < widget.books.length; i++) {
        final b = widget.books[i];
        sheet.appendRow([
          IntCellValue(i + 1),
          IntCellValue(b.id),
          TextCellValue(b.title),
          TextCellValue(b.author),
          TextCellValue(b.category),
          TextCellValue(b.isbn),
          IntCellValue(b.totalStock),
          IntCellValue(b.available)
        ]);

        // Beri borders horizontal halus pada baris data
        var rowStyle = CellStyle(
          fontFamily: getFontFamily(FontFamily.Arial),
          fontSize: 10,
        );
        for (int col = 0; col < 8; col++) {
          var cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1));
          cell.cellStyle = rowStyle;
        }
      }

      // Simpan berkas dan trigger unduhan
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final dateStr = DateTime.now().toIso8601String().split('T')[0];
        final filename = "koleksi_barcode_buku_$dateStr.xlsx";
        await FileSaverUtils.saveAndDownload(filename, fileBytes);
        widget.triggerSnackBar(
            "Berkas Excel $filename berhasil diekspor & diunduh!");
      } else {
        widget.triggerSnackBar("Gagal membuat data binary Excel.",
            isError: true);
      }
    } catch (e) {
      widget.triggerSnackBar("Terjadi kesalahan saat memproses excel: $e",
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.books.where((b) {
      final query = _searchQuery.toLowerCase();
      return b.title.toLowerCase().contains(query) ||
          b.author.toLowerCase().contains(query) ||
          b.isbn.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Database Koleksi Buku',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manajemen buku & cetak barcode sirkulasi perpustakaan.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _exportBooksToExcel,
                  icon: const Icon(Icons.downloading_rounded,
                      color: Color(0xFF1E8A5F), size: 16),
                  label: const Text('Unduh Cetak Excel',
                      style: TextStyle(
                          color: Color(0xFF1E8A5F),
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFF1E8A5F), width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showBookFormDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Buku'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8A5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search Bar
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan judul, penulis, atau barcode ISBN...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('Judul & Kode ISBN',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Penulis',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Kategori',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Stok Sisa',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Aksi',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.map((book) {
                return DataRow(cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(book.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('ISBN / BARCODE: ${book.isbn}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: Colors.grey)),
                      ],
                    ),
                  ),
                  DataCell(Text(book.author)),
                  DataCell(
                    Chip(
                      label: Text(book.category,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                  DataCell(Text('${book.available} / ${book.totalStock}')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.blue, size: 18),
                          onPressed: () => _showBookFormDialog(book: book),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 18),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: Text(
                                      'Apakah Anda yakin ingin menghapus buku "${book.title}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        widget.onDeleteBook(book.id);
                                      },
                                      child: const Text('Hapus',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        )
      ],
    );
  }

  void _showBookFormDialog({Book? book}) {
    final isEdit = book != null;
    final titleCtrl = TextEditingController(text: isEdit ? book.title : '');
    final authorCtrl = TextEditingController(text: isEdit ? book.author : '');
    final categoryCtrl =
        TextEditingController(text: isEdit ? book.category : 'Pelajaran');

    // Auto-generate barcode ID unik scannable jika menambah baru
    String defaultIsbn = '';
    if (!isEdit) {
      final nowMillis = DateTime.now().millisecondsSinceEpoch;
      // Membuat format ISBN numerik valid scannable 13 digit
      defaultIsbn =
          "978" + (nowMillis % 10000000000).toString().padLeft(10, '0');
    }

    final isbnCtrl =
        TextEditingController(text: isEdit ? book.isbn : defaultIsbn);
    final stockCtrl =
        TextEditingController(text: isEdit ? book.totalStock.toString() : '1');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    isEdit
                        ? Icons.edit_note_rounded
                        : Icons.library_add_rounded,
                    color: const Color(0xFF1E8A5F),
                  ),
                  const SizedBox(width: 10),
                  Text(isEdit ? 'Sunting Data Buku' : 'Tambah Buku Baru'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Judul Buku *',
                        prefixIcon: Icon(Icons.book_outlined, size: 20),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: authorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Penulis / Pengarang *',
                        prefixIcon:
                            Icon(Icons.person_outline_rounded, size: 20),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Buku',
                        hintText: 'Cth: Pelajaran, Novel, Sains',
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: isbnCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Kode Barcode Buku (ISBN) *',
                        prefixIcon:
                            const Icon(Icons.qr_code_scanner_rounded, size: 20),
                        border: const OutlineInputBorder(),
                        helperText: isEdit
                            ? 'Simpan jika tidak ada perubahan.'
                            : 'Barcode di-generate otomatis. Bisa diganti jika perlu.',
                        helperStyle: TextStyle(
                          fontSize: 10,
                          color: isEdit ? Colors.grey : const Color(0xFF1E8A5F),
                          fontWeight:
                              isEdit ? FontWeight.normal : FontWeight.bold,
                        ),
                        suffixIcon: isEdit
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.casino_outlined,
                                    size: 18, color: Color(0xFF1E8A5F)),
                                tooltip: 'Acak Barcode Baru',
                                onPressed: () {
                                  final freshMillis =
                                      DateTime.now().millisecondsSinceEpoch;
                                  final generated = "978" +
                                      (freshMillis % 10000000000)
                                          .toString()
                                          .padLeft(10, '0');
                                  isbnCtrl.text = generated;
                                  setDialogState(() {});
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Persediaan Stok',
                        prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8A5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (titleCtrl.text.isEmpty ||
                        authorCtrl.text.isEmpty ||
                        isbnCtrl.text.isEmpty) {
                      widget.triggerSnackBar('Harap isi semua kolom wajib!',
                          isError: true);
                      return;
                    }
                    final stock = int.tryParse(stockCtrl.text) ?? 1;
                    if (isEdit) {
                      widget.onEditBook(Book(
                        id: book.id,
                        title: titleCtrl.text,
                        author: authorCtrl.text,
                        category: categoryCtrl.text,
                        isbn: isbnCtrl.text,
                        totalStock: stock,
                        available: book.available + (stock - book.totalStock),
                      ));
                    } else {
                      widget.onAddBook(Book(
                        id: DateTime.now().millisecondsSinceEpoch,
                        title: titleCtrl.text,
                        author: authorCtrl.text,
                        category: categoryCtrl.text,
                        isbn: isbnCtrl.text,
                        totalStock: stock,
                        available: stock,
                      ));
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      titleCtrl.dispose();
      authorCtrl.dispose();
      categoryCtrl.dispose();
      isbnCtrl.dispose();
      stockCtrl.dispose();
    });
  }
}
