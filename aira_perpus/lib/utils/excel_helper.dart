import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/member.dart';
import '../models/book.dart';
import '../models/transaction.dart';
import '../models/visitor.dart';
import 'file_saver.dart';

class ExcelHelper {
  /// Generates and triggers Excel download for Borrowed Books (Active Loans)
  static Future<void> exportBorrowedBooks({
    required List<Transaction> transactions,
    required List<Book> books,
    required List<Member> members,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Header cells
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('ID Transaksi'),
      TextCellValue('NIS Siswa'),
      TextCellValue('Nama Siswa'),
      TextCellValue('Kelas'),
      TextCellValue('Judul Buku'),
      TextCellValue('Penulis'),
      TextCellValue('Kategori'),
      TextCellValue('ISBN'),
      TextCellValue('Tanggal Pinjam'),
      TextCellValue('Status'),
    ]);

    final activeLoans =
        transactions.where((tx) => tx.status == 'borrowed').toList();

    for (int i = 0; i < activeLoans.length; i++) {
      final tx = activeLoans[i];

      // Look up book
      String title = "-";
      String author = "-";
      String cat = "-";
      String isbn = "-";
      try {
        final b = books.firstWhere((book) => book.id == tx.bookId);
        title = b.title;
        author = b.author;
        cat = b.category;
        isbn = b.isbn;
      } catch (_) {}

      // Look up student
      String sName = "-";
      String sClass = "-";
      String sNis = "-";
      try {
        final m = members.firstWhere((mem) => mem.id == tx.memberId);
        sName = m.name;
        sClass = m.memberClass;
        sNis = m.nis;
      } catch (_) {}

      sheet.appendRow([
        IntCellValue(i + 1),
        IntCellValue(tx.id),
        TextCellValue(sNis),
        TextCellValue(sName),
        TextCellValue(sClass),
        TextCellValue(title),
        TextCellValue(author),
        TextCellValue(cat),
        TextCellValue(isbn),
        TextCellValue(tx.borrowDate),
        TextCellValue('SANGAT PINJAM (BELUM KEMBALI)'),
      ]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      await FileSaverUtils.saveAndDownload(
          'Laporan_Buku_Sedang_Dipinjam.xlsx', bytes);
    }
  }

  /// Generates and triggers Excel download for Returned Books & Circulation History (Buku Keluar)
  static Future<void> exportCirculationHistory({
    required List<Transaction> transactions,
    required List<Book> books,
    required List<Member> members,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('ID Transaksi'),
      TextCellValue('NIS Siswa'),
      TextCellValue('Nama Siswa'),
      TextCellValue('Kelas'),
      TextCellValue('Judul Buku'),
      TextCellValue('Penulis'),
      TextCellValue('Kategori'),
      TextCellValue('ISBN'),
      TextCellValue('Tanggal Pinjam'),
      TextCellValue('Tanggal Kembali'),
      TextCellValue('Status sirkulasi'),
    ]);

    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];

      // Look up book
      String title = "-";
      String author = "-";
      String cat = "-";
      String isbn = "-";
      try {
        final b = books.firstWhere((book) => book.id == tx.bookId);
        title = b.title;
        author = b.author;
        cat = b.category;
        isbn = b.isbn;
      } catch (_) {}

      // Look up student
      String sName = "-";
      String sClass = "-";
      String sNis = "-";
      try {
        final m = members.firstWhere((mem) => mem.id == tx.memberId);
        sName = m.name;
        sClass = m.memberClass;
        sNis = m.nis;
      } catch (_) {}

      sheet.appendRow([
        IntCellValue(i + 1),
        IntCellValue(tx.id),
        TextCellValue(sNis),
        TextCellValue(sName),
        TextCellValue(sClass),
        TextCellValue(title),
        TextCellValue(author),
        TextCellValue(cat),
        TextCellValue(isbn),
        TextCellValue(tx.borrowDate),
        TextCellValue(tx.returnDate ?? "-"),
        TextCellValue(
            tx.status == 'returned' ? 'SUDAH KEMBALI' : 'SEDANG DIPINJAM'),
      ]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      await FileSaverUtils.saveAndDownload(
          'Laporan_Sirkulasi_Buku_Keluar_Masuk.xlsx', bytes);
    }
  }

  /// Generates and triggers Excel download for Visitors/Attendance (Anak-anak yang hadir di perpus)
  static Future<void> exportVisitors({
    required List<Visitor> visitors,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('ID Kunjungan'),
      TextCellValue('NIS'),
      TextCellValue('Nama Lengkap Siswa'),
      TextCellValue('Kelas'),
      TextCellValue('Waktu / Jam Hadir'),
      TextCellValue('Metode Pemindaian'),
    ]);

    for (int i = 0; i < visitors.length; i++) {
      final v = visitors[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(v.id),
        TextCellValue(v.nis),
        TextCellValue(v.name),
        TextCellValue(v.classRoom),
        TextCellValue(v.timestamp),
        TextCellValue(v.method.toUpperCase()),
      ]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      await FileSaverUtils.saveAndDownload(
          'Laporan_Kehadiran_Siswa_Perpus.xlsx', bytes);
    }
  }

  /// Generates a blank formatted Excel template for importing students
  static Future<void> downloadStudentImportTemplate() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('NIS'),
      TextCellValue('Nama Lengkap'),
      TextCellValue('Kelas'),
    ]);

    // Sample data for reference
    sheet.appendRow([
      TextCellValue('195966'),
      TextCellValue('Farhan Mahendra'),
      TextCellValue('VII-A'),
    ]);
    sheet.appendRow([
      TextCellValue('100201'),
      TextCellValue('Aira Shalsabila'),
      TextCellValue('VIII-C'),
    ]);

    final bytes = excel.encode();
    if (bytes != null) {
      await FileSaverUtils.saveAndDownload('Template_Import_Siswa.xlsx', bytes);
    }
  }

  /// Parses student import spreadsheet and returns a list of members
  static List<Member> parseMembersExcel(Uint8List fileBytes) {
    final List<Member> parsedMembers = [];
    final excel = Excel.decodeBytes(fileBytes);

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null || sheet.maxRows <= 1) continue;

      // Start from index 1 to skip headers (NIS, Nama Lengkap, Kelas)
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty) continue;

        // Extract cells, safeguard bounds
        final String nis = row.isNotEmpty && row[0] != null
            ? row[0]!.value.toString().trim()
            : '';
        final String name = row.length > 1 && row[1] != null
            ? row[1]!.value.toString().trim()
            : '';
        final String memberClass = row.length > 2 && row[2] != null
            ? row[2]!.value.toString().trim()
            : 'VII-A';

        // Check if vital fields are present
        if (nis.isEmpty || name.isEmpty) continue;

        // Create a unique bigint id from DateTime & random number to guarantee unique bigint values in supabase
        final randSeed = (100 + (DateTime.now().millisecond % 900));
        final uniqueId = DateTime.now().millisecondsSinceEpoch + randSeed;

        parsedMembers.add(Member(
          id: uniqueId,
          name: name,
          nis: nis,
          memberClass: memberClass,
        ));
      }
    }

    return parsedMembers;
  }
}
