import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/member.dart';
import '../models/transaction.dart';

class DashboardTab extends StatelessWidget {
  final List<Book> books;
  final List<Member> members;
  final List<Transaction> transactions;
  final String appName;
  final String schoolName;
  final Function(String) onNavigateTab;

  const DashboardTab({
    Key? key,
    required this.books,
    required this.members,
    required this.transactions,
    required this.appName,
    required this.schoolName,
    required this.onNavigateTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int bookTitles = books.length;
    final int memberCount = members.length;
    final int borrowedCount =
        transactions.where((t) => t.status == 'borrowed').length;
    final int availableCount =
        books.fold<int>(0, (sum, b) => sum + b.available);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Jumbotron
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF156444), Color(0xFF1E8A5F), Color(0xFF2EBD82)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: const Text(
                  'PANEL KONTROL AKTIF',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selamat Datang di Portal $appName $schoolName',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gunakan menu navigasi samping untuk mengelola buku perpus, keanggotaan siswa, dan proses simulasikan sirkulasi scan barcode / NIS.',
                style: TextStyle(fontSize: 13, color: Color(0xFFE2FBF0)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Metrics Grid Row
        LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = (constraints.maxWidth - 36) /
                (constraints.maxWidth > 800 ? 4 : 2);
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMetricsCard('Koleksi Buku', '$bookTitles Judul',
                    Icons.menu_book, const Color(0xFF10B981), cardWidth),
                _buildMetricsCard('Siswa Anggota', '$memberCount Siswa',
                    Icons.people, Colors.blue, cardWidth),
                _buildMetricsCard('Aktif Dipinjam', '$borrowedCount Sirkulasi',
                    Icons.swap_horiz, Colors.orange, cardWidth),
                _buildMetricsCard('Tersedia Alokasi', '$availableCount Buku',
                    Icons.check_circle_outline, Colors.teal, cardWidth),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Double Columns (Recent Loans & Quick Scanner Simulation)
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sirkulasi Peminjaman Terbaru',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab('transactions'),
                      child: const Text('Lihat Selengkapnya',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF1E8A5F))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                transactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'Belum ada riwayat transaksi.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            transactions.length > 5 ? 5 : transactions.length,
                        itemBuilder: (context, idx) {
                          final tx = transactions[idx];
                          final bk = books.firstWhere(
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
                          final student = members.firstWhere(
                            (m) => m.id == tx.memberId,
                            orElse: () => Member(
                                id: 0, name: 'Siswa', nis: '', memberClass: ''),
                          );

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: tx.status == 'borrowed'
                                      ? Colors.orange.shade50
                                      : const Color(0xFFECFDF5),
                                  child: Icon(
                                    tx.status == 'borrowed'
                                        ? Icons.timelapse
                                        : Icons.check,
                                    size: 16,
                                    color: tx.status == 'borrowed'
                                        ? Colors.orange.shade800
                                        : const Color(0xFF065F46),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(student.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B))),
                                      Text('Meminjam: "${bk.title}"',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF475569))),
                                    ],
                                  ),
                                ),
                                Text(
                                  tx.borrowDate,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          );
                        },
                      )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCard(
      String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8))),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          )
        ],
      ),
    );
  }
}
