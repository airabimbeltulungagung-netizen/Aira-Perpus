import 'package:flutter/material.dart';
import '../models/book.dart';

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
            const Text(
              'Database Koleksi Buku',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            ElevatedButton.icon(
              onPressed: () => _showBookFormDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Buku'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8A5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
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
                          onPressed: () => widget.onDeleteBook(book.id),
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
    final isbnCtrl = TextEditingController(text: isEdit ? book.isbn : '');
    final stockCtrl =
        TextEditingController(text: isEdit ? book.totalStock.toString() : '1');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Sunting Data Buku' : 'Tambah Buku Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Judul Buku *')),
                const SizedBox(height: 8),
                TextField(
                    controller: authorCtrl,
                    decoration: const InputDecoration(labelText: 'Penulis *')),
                const SizedBox(height: 8),
                TextField(
                    controller: categoryCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Kategori (cth: Pelajaran, Novel)')),
                const SizedBox(height: 8),
                TextField(
                    controller: isbnCtrl,
                    decoration: const InputDecoration(
                        labelText: 'ISBN / Barcode Code *')),
                const SizedBox(height: 8),
                TextField(
                    controller: stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Stok')),
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
  }
}
