import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../models/book.dart';
import '../models/member.dart';
import '../models/transaction.dart';
import '../utils/sound_utils.dart';

class RemoteScannerTab extends StatefulWidget {
  final List<Member> members;
  final List<Book> books;
  final List<Transaction> transactions;
  final Function(String nis, String method) onRegisterVisitor;
  final Function(int bookId, int memberId) onProcessBorrow;
  final Function(int transactionId) onProcessReturn;
  final Function(String message, {bool isError}) triggerSnackBar;
  final bool initialMobileMode;
  final String? initialSessionId;

  const RemoteScannerTab({
    Key? key,
    required this.members,
    required this.books,
    required this.transactions,
    required this.onRegisterVisitor,
    required this.onProcessBorrow,
    required this.onProcessReturn,
    required this.triggerSnackBar,
    this.initialMobileMode = false,
    this.initialSessionId,
  }) : super(key: key);

  @override
  State<RemoteScannerTab> createState() => _RemoteScannerTabState();
}

class _RemoteScannerTabState extends State<RemoteScannerTab> {
  bool _isMobileMode =
      false; // false = Terminal Utama (Desktop), true = Pemindai HP (Mobile)

  // Terminal States
  late String _pairingCode;
  bool _isListening = false;
  StreamSubscription? _realtimeSubscription;
  final List<String> _scanHistory = [];
  String _selectedAction = 'visitor'; // visitor, borrow, return
  Member? _activeBorrowMember; // Memori sementara untuk menyimpan peminjam

  // Mobile Pemindai States
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _scanInputController = TextEditingController();
  bool _isPaired = false;
  String _pairedSessionId = "";
  final List<String> _sentHistory = [];

  @override
  void initState() {
    super.initState();
    _isMobileMode = widget.initialMobileMode;
    if (widget.initialSessionId != null) {
      _isPaired = true;
      _pairedSessionId = widget.initialSessionId!;
    }
    // Generate random 4-digit pairing code
    _pairingCode = (Random().nextInt(9000) + 1000).toString();
    _checkAndStartListening();
  }

  @override
  void dispose() {
    _stopListening();
    _codeController.dispose();
    _scanInputController.dispose();
    super.dispose();
  }

  void _checkAndStartListening() {
    if (AppConfig.isConfigured && !_isMobileMode) {
      _startListening();
    }
  }

  void _startListening() {
    _stopListening();
    setState(() {
      _isListening = true;
    });

    try {
      // Listen to new inserts into 'remote_scans' where session_id matches our pairingCode
      _realtimeSubscription = Supabase.instance.client
          .from('remote_scans')
          .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
        if (!mounted) return;

        for (var row in data) {
          if (row['session_id'] == _pairingCode) {
            final String scannedCode = row['scanned_code'].toString().trim();

            // Process only new scans we haven't handled yet in our visual scan history
            if (!_scanHistory.contains(scannedCode)) {
              setState(() {
                _scanHistory.insert(0, scannedCode);
              });
              _handleScannedCode(scannedCode);

              // Delete from remote scans to avoid processing multiple times and save storage
              Supabase.instance.client
                  .from('remote_scans')
                  .delete()
                  .eq('id', row['id'])
                  .onError((error, stackTrace) => {});
            }
          }
        }
      }, onError: (err) {
        debugPrint("Supabase Realtime Error: $err");
      });
    } catch (e) {
      debugPrint("Gagal mengaktifkan listening realtime: $e");
    }
  }

  void _stopListening() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _handleScannedCode(String code) {
    SoundUtils.playBeep();
    widget.triggerSnackBar("Menerima scan satelit HP: $code");

    // 1. MODE PENGUNJUNG
    if (_selectedAction == 'visitor') {
      widget.onRegisterVisitor(code, 'barcode');
    }

    // 2. MODE PEMINJAMAN (REVISI LOGIKA)
    else if (_selectedAction == 'borrow') {
      // Cek apakah barcode ini adalah NIS Anggota
      final member = widget.members.firstWhere(
        (m) => m.nis == code,
        orElse: () => Member(id: -1, name: '', nis: '', memberClass: ''),
      );

      if (member.id != -1) {
        // Simpan anggota ke memori sementara
        setState(() {
          _activeBorrowMember = member;
        });
        widget.triggerSnackBar(
            "Peminjam diset: ${member.name}. Sekarang arahkan HP ke ISBN Buku untuk proses pinjam.",
            isError: false);
      } else {
        // Jika bukan NIS, cek apakah ini ISBN Buku
        final book = widget.books.firstWhere(
          (b) => b.isbn == code,
          orElse: () => Book(
              id: -1,
              title: '',
              author: '',
              category: '',
              isbn: '',
              totalStock: 0,
              available: 0),
        );

        if (book.id != -1) {
          if (_activeBorrowMember != null) {
            // EKSEKUSI UTAMA: Member ada & Buku ada -> Eksekusi Pinjam!
            widget.onProcessBorrow(book.id, _activeBorrowMember!.id);
            widget.triggerSnackBar(
                "Sukses! Buku '${book.title}' dipinjam oleh ${_activeBorrowMember!.name}.",
                isError: false);

            // Reset memori agar siap untuk peminjam berikutnya
            setState(() {
              _activeBorrowMember = null;
            });
          } else {
            widget.triggerSnackBar(
                "Buku '${book.title}' terdeteksi. Tapi Anda belum men-scan Kartu Anggota peminjamnya!",
                isError: true);
          }
        } else {
          widget.triggerSnackBar(
              "Barcode '$code' tidak dikenal di perpustakaan.",
              isError: true);
        }
      }
    }

    // 3. MODE PENGEMBALIAN (REVISI LOGIKA)
    else if (_selectedAction == 'return') {
      final book = widget.books.firstWhere(
        (b) => b.isbn == code,
        orElse: () => Book(
            id: -1,
            title: '',
            author: '',
            category: '',
            isbn: '',
            totalStock: 0,
            available: 0),
      );

      if (book.id != -1) {
        // Cari transaksi sirkulasi aktif yang belum dikembalikan untuk buku ini
        final List<Transaction> activeLoans = widget.transactions
            .where((t) => t.bookId == book.id && t.status == 'borrowed')
            .toList();

        if (activeLoans.isNotEmpty) {
          // Ambil sirkulasi tertua/paling awal untuk dikembalikan
          final txToReturn = activeLoans.first;
          widget.onProcessReturn(txToReturn.id);
          widget.triggerSnackBar(
              "Proses pengembalian berhasil untuk '${book.title}'.");
        } else {
          widget.triggerSnackBar(
              "Buku '${book.title}' terdeteksi, namun tidak memiliki sirkulasi pinjam aktif.",
              isError: true);
        }
      } else {
        widget.triggerSnackBar("Buku tidak ditemukan di sistem.",
            isError: true);
      }
    }
  }

  // Mobile: Send scan to supabase
  void _sendScanToServer(String scannedCode) async {
    if (scannedCode.trim().isEmpty) return;
    if (!AppConfig.isConfigured) {
      widget.triggerSnackBar(
          "Pastikan sistem server utama terkonfigurasi dengan valid terlebih dahulu.",
          isError: true);
      return;
    }

    try {
      await Supabase.instance.client.from('remote_scans').insert({
        'session_id': _pairedSessionId,
        'scanned_code': scannedCode.trim(),
      });

      setState(() {
        _sentHistory.insert(0, scannedCode.trim());
      });
      _scanInputController.clear();
      widget.triggerSnackBar(
          "Sukses mengirimkan barcode '$scannedCode' ke desktop.");
    } catch (e) {
      widget.triggerSnackBar("Gagal kirim pemindaian: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode Selector Headers
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isMobileMode = false;
                      _checkAndStartListening();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isMobileMode
                          ? const Color(0xFF1E8A5F)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '🖥️ TERMINAL UTAMA (Desktop / Laptop)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: !_isMobileMode
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isMobileMode = true;
                      _stopListening();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isMobileMode
                          ? const Color(0xFF1E8A5F)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '📱 PEMINDAI SATELIT (Kamera HP)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isMobileMode
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _isMobileMode ? _buildMobileView() : _buildDesktopView(),
      ],
    );
  }

  // --- TERMINAL UTAMA VIEW ---
  Widget _buildDesktopView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left - pairing card
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.phonelink_ring_rounded,
                          size: 48, color: Color(0xFF1E8A5F)),
                      const SizedBox(height: 12),
                      const Text(
                        "Ubah HP Menjadi Wireless Barcode Scanner",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Pindai barcode kartu anggota / buku menggunakan kamera HP dari mana saja secara real-time, lalu data masuk otomatis ke laptop ini.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey, height: 1.4),
                      ),
                      const SizedBox(height: 20),

                      // Code generator
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2FBF0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      const Color(0xFF2EBD82).withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "KODE OTENTIKASI PAIRING",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      color: Color(0xFF1E8A5F)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _pairingCode,
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      letterSpacing: 4,
                                      color: Color(0xFF156444)),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _pairingCode =
                                          (Random().nextInt(9000) + 1000)
                                              .toString();
                                    });
                                    _stopListening();
                                    _startListening();
                                    widget.triggerSnackBar(
                                        "Kode baru berhasil diacak: $_pairingCode");
                                  },
                                  icon: const Icon(Icons.refresh,
                                      size: 16, color: Color(0xFF1E8A5F)),
                                  label: const Text('Acak Kode Baru',
                                      style: TextStyle(
                                          color: Color(0xFF1E8A5F),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // QR Code & Link Sharing
                          Card(
                            elevation: 0,
                            color: const Color(0xFFF8FAFC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text(
                                    "Scan atau Salin Tautan untuk HP",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent("${Uri.base.toString().split('?')[0]}?scanner=$_pairingCode")}",
                                      width: 140,
                                      height: 140,
                                      errorBuilder: (ctx, err, stack) =>
                                          const Icon(Icons.qr_code_2,
                                              size: 80, color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E8A5F),
                                      foregroundColor: Colors.white,
                                      minimumSize:
                                          const Size(double.infinity, 38),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      final baseUrl =
                                          Uri.base.toString().split('?')[0];
                                      final pairingUrl =
                                          "$baseUrl?scanner=$_pairingCode";
                                      Clipboard.setData(
                                          ClipboardData(text: pairingUrl));
                                      widget.triggerSnackBar(
                                          "Tautan scan HP disalin ke clipboard!");
                                    },
                                    icon: const Icon(Icons.copy_all, size: 16),
                                    label: const Text('Salin Tautan Akses',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Steps
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Cara Integrasi:",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const SizedBox(height: 8),
                            _buildStepText(1,
                                "Buka website perpustakaan ini di Google Chrome HP Anda."),
                            _buildStepText(2,
                                "Pilih menu 'Satelit Scanner HP' di bagian navigasi samping."),
                            _buildStepText(3,
                                "Buka tab '📱 PEMINDAI SATELIT (Kamera HP)'."),
                            _buildStepText(4,
                                "Masukkan Kode Otentikasi '$_pairingCode' lalu klik Hubungkan."),
                            _buildStepText(5,
                                "Posisikan kamera HP pada barcode kartu/buku, data akan instan terkirim!"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (!AppConfig.isConfigured)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning,
                                  color: Colors.amber.shade800, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Layanan database belum terkonfigurasi. Silakan hubungi administrator sistem Anda.",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isListening
                                  ? "Koneksi Realtime Aktif & Menunggu Scan..."
                                  : "Koneksi Offline atau Ditangguhkan",
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // Right - controls & history
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Tujuan Sinkronisasi Scan HP",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 10),

                      // Set active target for remote scans
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Presensi Buku Tamu Pengunjung',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: const Text(
                                'Input scan dari HP otomatis mengisi presensi siswa masuk perpus.',
                                style: TextStyle(fontSize: 10)),
                            value: 'visitor',
                            groupValue: _selectedAction,
                            activeColor: const Color(0xFF1E8A5F),
                            onChanged: (val) {
                              setState(() {
                                _selectedAction = val!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Catat Peminjaman Buku',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: const Text(
                                'Input scan diperlakukan sebagai pembacaan NIS siswa / ISBN Buku.',
                                style: TextStyle(fontSize: 10)),
                            value: 'borrow',
                            groupValue: _selectedAction,
                            activeColor: const Color(0xFF1E8A5F),
                            onChanged: (val) {
                              setState(() {
                                _selectedAction = val!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Catat Pengembalian Buku',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: const Text(
                                'Input scan dari HP otomatis memproses pengembalian sirkulasi buku.',
                                style: TextStyle(fontSize: 10)),
                            value: 'return',
                            groupValue: _selectedAction,
                            activeColor: const Color(0xFF1E8A5F),
                            onChanged: (val) {
                              setState(() {
                                _selectedAction = val!;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_selectedAction == 'borrow' &&
                          _activeBorrowMember != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade700, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Peminjam Aktif: ${_activeBorrowMember!.name} (${_activeBorrowMember!.nis}).\nSilakan scan ISBN Buku untuk menyelesaikan peminjaman.",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                      height: 1.3),
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close,
                                    size: 16, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _activeBorrowMember = null;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                      const Divider(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Log Pemindaian Nirkabel Masuk",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B)),
                          ),
                          if (_scanHistory.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _scanHistory.clear();
                                });
                              },
                              child: const Text('Bersihkan Log',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 10)),
                            )
                        ],
                      ),
                      const SizedBox(height: 8),

                      _scanHistory.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  "Belum ada pemindaian masuk via HP.",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ),
                            )
                          : Container(
                              constraints: const BoxConstraints(maxHeight: 250),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _scanHistory.length,
                                itemBuilder: (ctx, idx) {
                                  final code = _scanHistory[idx];
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(
                                        Icons.phonelink_ring_rounded,
                                        size: 16,
                                        color: Color(0xFF1E8A5F)),
                                    title: Text(
                                      "Terscan: $code",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace'),
                                    ),
                                    subtitle: Text(
                                        "Diterjemahkan secara nirkabel pada ${DateTime.now().hour}:${DateTime.now().minute}"),
                                    trailing: const Icon(Icons.check_circle,
                                        color: Colors.green, size: 16),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              // Shopee Scanner helper banner
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.scanner_outlined,
                        color: Colors.orange, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "🛒 Menggunakan Alat Scan Fisik Shopee?",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Alat scan fisik dicolok via USB atau bluetooth berperilaku persis seperti keyboard komputer biasa. Cukup posisikan kursor mouse Anda pada TextBox di menu Peminjaman / Presensi Masuk, lalu scan benda. Sistem langsung menginput dan menekan Enter otomatis!",
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- PEMINDAI SATELIT HP VIEW ---
  Widget _buildMobileView() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Color(0xFF1E8A5F), size: 24),
                SizedBox(width: 8),
                Text(
                  "Panel Mobile Web Scanner Satelit",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Hubungkan kamera HP Anda untuk memasukkan input barcode / NIS langsung ke aplikasi perpustakaan utama di komputer.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Divider(height: 32),
            if (!_isPaired) ...[
              const Text(
                '🔐 Otentikasi & Pairing',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan 4-Digit Kode Pairing yang tertera pada layar laptop operator komputer untuk memulai sinkronisasi aman.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6),
                decoration: InputDecoration(
                  hintText: '1234',
                  hintStyle: const TextStyle(
                      color: Colors.grey, fontSize: 24, letterSpacing: 4),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final code = _codeController.text.trim();
                  if (code.length == 4) {
                    setState(() {
                      _isPaired = true;
                      _pairedSessionId = code;
                    });
                    widget
                        .triggerSnackBar("Tersambung ke sesi pairing '$code'!");
                  } else {
                    widget.triggerSnackBar(
                        "Kode pairing harus berisi 4 digit angka!",
                        isError: true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('HUBUNGKAN SEKARANG',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              // Paired Success Screen
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2FBF0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF1E8A5F).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_clock_outlined,
                            color: Color(0xFF1E8A5F), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Penyandian Aktif: SESSION $_pairedSessionId",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E8A5F)),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isPaired = false;
                          _pairedSessionId = "";
                        });
                      },
                      child: const Text(
                        "Putuskan",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Simulating mobile web barcode camera scan inputs
              const Text(
                "Arahkan Kamera / Input Barcode",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Ketuk kotak teks di bawah untuk memasukkan barcode. Apabila Anda membuka halaman ini di browser HP, kamera hp dapat membaca barcode otomatis.",
                style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _scanInputController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Arahkan kursor / ketik NIS atau ISBN...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        prefixIcon: const Icon(Icons.qr_code_scanner, size: 16),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          _sendScanToServer(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _sendScanToServer(_scanInputController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8A5F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Text('Kirim'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      label: const Text('NIS 1001',
                          style: TextStyle(fontSize: 10)),
                      onPressed: () => _sendScanToServer('1001'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      label: const Text('NIS 1002',
                          style: TextStyle(fontSize: 10)),
                      onPressed: () => _sendScanToServer('1002'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      label: const Text('ISBN 9786022829843',
                          style: TextStyle(fontSize: 10)),
                      onPressed: () => _sendScanToServer('9786022829843'),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              const Text(
                "Riwayat Scan Terkirim:",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _sentHistory.isEmpty
                  ? const Text("Belum ada data terkirim dari sesi ini.",
                      style: TextStyle(fontSize: 11, color: Colors.grey))
                  : Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _sentHistory.length,
                        itemBuilder: (ctx, idx) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_circle_outline,
                                color: Colors.green, size: 14),
                            title: Text(
                              "Terkirim instan: ${_sentHistory[idx]}",
                              style: const TextStyle(
                                  fontSize: 11, fontFamily: 'monospace'),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepText(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Color(0xFF1E8A5F), shape: BoxShape.circle),
            child: Text(
              step.toString(),
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
            ),
          )
        ],
      ),
    );
  }
}
