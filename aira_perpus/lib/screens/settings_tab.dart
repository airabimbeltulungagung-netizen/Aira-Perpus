import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../models/visitor.dart';
import '../models/book.dart';
import '../models/member.dart';
import '../utils/excel_helper.dart';

class SettingsTab extends StatefulWidget {
  final String appName;
  final String schoolName;
  final String operatorName;
  final List<Transaction> transactions;
  final List<Visitor> visitors;
  final List<Book> books;
  final List<Member> members;
  final Function(String appName, String schoolName, String operatorName) onSave;

  const SettingsTab({
    Key? key,
    required this.appName,
    required this.schoolName,
    required this.operatorName,
    required this.transactions,
    required this.visitors,
    required this.books,
    required this.members,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late TextEditingController _appNameCtrl;
  late TextEditingController _schoolNameCtrl;
  late TextEditingController _operatorNameCtrl;

  @override
  void initState() {
    super.initState();
    _appNameCtrl = TextEditingController(text: widget.appName);
    _schoolNameCtrl = TextEditingController(text: widget.schoolName);
    _operatorNameCtrl = TextEditingController(text: widget.operatorName);
  }

  @override
  void dispose() {
    _appNameCtrl.dispose();
    _schoolNameCtrl.dispose();
    _operatorNameCtrl.dispose();
    super.dispose();
  }

  // Quick helper to redirect or copy WA link to clipboard
  void _openWhatsAppHelp() {
    const phone = "6285704351856"; // Cleaned standard admin phone
    final template = Uri.encodeComponent(
        "Halo Admin Perpustakaan, saya membutuhkan bantuan terkait aplikasi ${widget.appName}...");
    final waUrl = "https://wa.me/$phone?text=$template";

    Clipboard.setData(ClipboardData(text: waUrl));

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.headset_mic_rounded, color: Color(0xFF1E8A5F)),
              SizedBox(width: 8),
              Text('Hubungi Admin'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anda akan diarahkan ke saluran chat WhatsApp Admin Resmi:',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NO. HANDPHONE:',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const Text('0857-0435-1856',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 8),
                    const Text('PESAN UTAMA:',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    Text(
                      'Halo Admin Perpustakaan, saya membutuhkan bantuan terkait aplikasi...',
                      style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '* Tautan WhatsApp telah disalin secara otomatis ke clipboard perangkat Anda.',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8A5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Membuka WhatsApp di tab browser / aplikasi baru..."),
                    backgroundColor: Color(0xFF1E8A5F),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Kirim Pesan Sekarang'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 950;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Konfigurasi & Cetak Laporan',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kelola identitas sekolah, download rekapan data sirkulasi harian, dan hubungi bantuan teknis.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 18),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildRebrandingCard()),
              const SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildReportExportCard(),
                    const SizedBox(height: 20),
                    _buildWhatsAppAdminCard(),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _buildRebrandingCard(),
          const SizedBox(height: 18),
          _buildReportExportCard(),
          const SizedBox(height: 18),
          _buildWhatsAppAdminCard(),
        ]
      ],
    );
  }

  Widget _buildRebrandingCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.palette_outlined,
                    color: Color(0xFF1E8A5F), size: 20),
                SizedBox(width: 8),
                Text(
                  'Formulir Rebranding Identitas',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _appNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Aplikasi Resmi (APK)',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.smartphone),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _schoolNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap Sekolah',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _operatorNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Operator / Administrator',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.person_pin),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                widget.onSave(
                  _appNameCtrl.text.trim(),
                  _schoolNameCtrl.text.trim(),
                  _operatorNameCtrl.text.trim(),
                );
              },
              icon: const Icon(Icons.save_rounded, size: 16),
              label: const Text('Simpan & Terapkan Perubahan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8A5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportExportCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.print_outlined, color: Color(0xFF1E8A5F), size: 20),
                SizedBox(width: 8),
                Text(
                  'Cetak Laporan Sirkulasi (Excel)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Menghasilkan berkas rekapan terbaru dari database secara aman tanpa menghapus maupun mengubah data aslinya.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Button 1: Buku sedang dipinjam
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await ExcelHelper.exportBorrowedBooks(
                    transactions: widget.transactions,
                    books: widget.books,
                    members: widget.members,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Gagal mencetak: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.outbox_rounded, size: 16),
              label: const Text('Unduh Rekap Buku Sedang Dipinjam',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB020),
                foregroundColor: Colors.white,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Button 2: Buku keluar (Semua transaksi)
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await ExcelHelper.exportCirculationHistory(
                    transactions: widget.transactions,
                    books: widget.books,
                    members: widget.members,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Gagal mencetak: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: const Text('Unduh Rekap Buku Keluar & Sirkulasi',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Button 3: Log Kehadiran Pengunjung
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await ExcelHelper.exportVisitors(visitors: widget.visitors);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Gagal mencetak: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.assignment_ind_rounded, size: 16),
              label: const Text('Unduh Rekap Absensi Pengunjung',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppAdminCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.headset_mic_outlined, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Bantuan Hubungi Admin Perpustakaan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.green, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Kontak Admin Resmi Perpustakaan:',
                        style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '0857-0435-1856 (WhatsApp)',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pindai barcode kartu siswa, kelola buku, sirkulasi laporan, dan hubungi kami jika menemui kendala data.',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openWhatsAppHelp,
              icon: const Icon(Icons.phone_android, size: 16),
              label: const Text('Hubungi Layanan WhatsApp Admin',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
