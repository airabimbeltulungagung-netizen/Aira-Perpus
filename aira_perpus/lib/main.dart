import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import config and models
import 'config.dart';
import 'models/book.dart';
import 'models/member.dart';
import 'models/transaction.dart';
import 'models/visitor.dart';

// Import screens and tabs
import 'screens/login_screen.dart';
import 'screens/dashboard_tab.dart';
import 'screens/books_tab.dart';
import 'screens/members_tab.dart';
import 'screens/cards_tab.dart';
import 'screens/visitors_tab.dart';
import 'screens/transactions_tab.dart';
import 'screens/settings_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.loadCustomConfigs();

  if (AppConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      debugPrint("PWA/Flutter: Supabase terhubung dengan sukses.");
    } catch (e) {
      debugPrint("PWA/Flutter: Gagal menginisialisasi database Supabase: $e");
    }
  }

  runApp(const PerpusApp());
}

class PerpusApp extends StatelessWidget {
  const PerpusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PerpusApp Premium - Sistem Sirkulasi Sekolah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E8A5F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E8A5F),
          primary: const Color(0xFF1E8A5F),
          secondary: const Color(0xFF2EBD82),
          surfaceContainerHighest: const Color(0xFFF1F5F9),
        ),
        fontFamily: 'Inter',
      ),
      home: const LoginScreen(),
    );
  }
}

class MainLayoutScreen extends StatefulWidget {
  final String schoolName;
  final String operatorName;

  const MainLayoutScreen({
    Key? key,
    required this.schoolName,
    required this.operatorName,
  }) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  String _activeTab = 'dashboard';

  // ID aplikasi dan Lembaga yang bisa diset ulang fleksibel di pengaturan
  late String _schoolName;
  late String _operatorName;
  late String _appName;

  // Database States
  List<Book> _books = [];
  List<Member> _members = [];
  List<Transaction> _transactions = [];
  List<Visitor> _visitors = [];

  @override
  void initState() {
    super.initState();
    _schoolName = widget.schoolName;
    _operatorName = widget.operatorName;
    _appName = "Aira Perpus";
    _loadInitialMockData();
    _checkSupabaseStatus();
  }

  void _checkSupabaseStatus() {
    if (!AppConfig.isConfigured) {
      debugPrint(
          "Info: Supabase belum terkonfigurasi di config.json. Berjalan dalam mode mandiri/offline.");
    } else {
      debugPrint("Konektivitas Supabase Aktif untuk: ${AppConfig.supabaseUrl}");
      _fetchSupabaseData();
    }
  }

  Future<void> _fetchSupabaseData() async {
    bool hasAnySuccess = false;
    List<String> failedTables = [];

    // 1. Ambil data buku
    try {
      final booksRes = await Supabase.instance.client.from('books').select();
      if (booksRes.isNotEmpty) {
        setState(() {
          _books = (booksRes as List).map((x) => Book.fromJson(x)).toList();
        });
      }
      hasAnySuccess = true;
    } catch (e) {
      failedTables.add('books');
      debugPrint("Info: Gagal mengambil tabel 'books': $e");
    }

    // 2. Ambil data anggota
    try {
      final membersRes =
          await Supabase.instance.client.from('members').select();
      if (membersRes.isNotEmpty) {
        setState(() {
          _members =
              (membersRes as List).map((x) => Member.fromJson(x)).toList();
        });
      }
      hasAnySuccess = true;
    } catch (e) {
      failedTables.add('members');
      debugPrint("Info: Gagal mengambil tabel 'members': $e");
    }

    // 3. Ambil data transaksi harian
    try {
      final txRes =
          await Supabase.instance.client.from('transactions').select();
      if (txRes.isNotEmpty) {
        setState(() {
          _transactions =
              (txRes as List).map((x) => Transaction.fromJson(x)).toList();
        });
      }
      hasAnySuccess = true;
    } catch (e) {
      failedTables.add('transactions');
      debugPrint("Info: Gagal mengambil tabel 'transactions': $e");
    }

    // 4. Ambil log pengunjung
    try {
      final visitorsRes =
          await Supabase.instance.client.from('visitors').select();
      if (visitorsRes.isNotEmpty) {
        setState(() {
          _visitors =
              (visitorsRes as List).map((x) => Visitor.fromJson(x)).toList();
        });
      }
      hasAnySuccess = true;
    } catch (e) {
      failedTables.add('visitors');
      debugPrint("Info: Gagal mengambil tabel 'visitors': $e");
    }

    if (hasAnySuccess) {
      if (failedTables.isNotEmpty) {
        _triggerSnackBar(
          "Koneksi aktif! Harap buat tabel-tabel di Supabase Anda: ${failedTables.join(', ')}",
          isError: true,
        );
      } else {
        _triggerSnackBar("Sinkronisasi semua tabel Supabase berhasil!");
      }
    } else if (failedTables.isNotEmpty) {
      _triggerSnackBar(
        "Koneksi aktif! Tetapi tabel database belum dibuat. Silakan eksekusi file 'supabase_schema.sql' di SQL Editor Supabase Anda.",
        isError: true,
      );
    }
  }

  void _loadInitialMockData() {
    setState(() {
      _books = [
        Book(
            id: 1,
            title: 'Matematika Kelas VII',
            author: 'Kemdikbud',
            category: 'Pelajaran',
            isbn: '9786022829843',
            totalStock: 50,
            available: 45),
        Book(
            id: 2,
            title: 'Bahasa Indonesia Kelas VIII',
            author: 'Kemdikbud',
            category: 'Pelajaran',
            isbn: '9786022829850',
            totalStock: 40,
            available: 38),
        Book(
            id: 3,
            title: 'Laskar Pelangi',
            author: 'Andrea Hirata',
            category: 'Novel',
            isbn: '9793062797',
            totalStock: 10,
            available: 8),
        Book(
            id: 4,
            title: 'Bumi Manusia',
            author: 'Pramoedya Ananta Toer',
            category: 'Novel',
            isbn: '9799731232',
            totalStock: 5,
            available: 5),
        Book(
            id: 5,
            title: 'IPA Terpadu Kelas IX',
            author: 'Kemdikbud',
            category: 'Pelajaran',
            isbn: '9786022829867',
            totalStock: 45,
            available: 45),
      ];

      _members = [
        Member(id: 1, name: 'Budi Santoso', nis: '1001', memberClass: 'VII-A'),
        Member(id: 2, name: 'Siti Aminah', nis: '1002', memberClass: 'VII-B'),
        Member(id: 3, name: 'Agus Pratama', nis: '1003', memberClass: 'VIII-A'),
        Member(id: 4, name: 'Dewi Lestari', nis: '1004', memberClass: 'IX-C'),
      ];

      _transactions = [
        Transaction(
            id: 1,
            bookId: 1,
            memberId: 1,
            borrowDate: '2026-06-01',
            returnDate: '2026-06-08',
            status: 'returned'),
        Transaction(
            id: 2,
            bookId: 3,
            memberId: 2,
            borrowDate: '2026-06-05',
            returnDate: null,
            status: 'borrowed'),
        Transaction(
            id: 3,
            bookId: 2,
            memberId: 3,
            borrowDate: '2026-06-09',
            returnDate: null,
            status: 'borrowed'),
      ];

      _visitors = [
        Visitor(
            id: '1',
            nis: '1001',
            name: 'Budi Santoso',
            classRoom: 'VII-A',
            timestamp: DateTime.now()
                .subtract(const Duration(minutes: 45))
                .toIso8601String(),
            method: 'camera'),
        Visitor(
            id: '2',
            nis: '1002',
            name: 'Siti Aminah',
            classRoom: 'VII-B',
            timestamp: DateTime.now()
                .subtract(const Duration(minutes: 20))
                .toIso8601String(),
            method: 'barcode'),
      ];
    });
  }

  void _triggerSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade800 : const Color(0xFF1E8A5F),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- ACTIONS FOR BOOKS ---
  void _addBook(Book book) {
    setState(() {
      _books.add(book);
    });
    if (AppConfig.isConfigured) {
      _syncToSupabase("books", book.toJson());
    }
    _triggerSnackBar('Buku "${book.title}" berhasil ditambahkan!');
  }

  void _editBook(Book src) {
    setState(() {
      final idx = _books.indexWhere((b) => b.id == src.id);
      if (idx != -1) {
        _books[idx] = src;
      }
    });
    if (AppConfig.isConfigured) {
      _updateSupabase("books", src.id, src.toJson());
    }
    _triggerSnackBar('Data buku berhasil disimpan!');
  }

  void _deleteBook(int id) {
    try {
      final book = _books.firstWhere((b) => b.id == id);
      bool isBorrowed =
          _transactions.any((t) => t.bookId == id && t.status == 'borrowed');
      if (isBorrowed) {
        _triggerSnackBar('Gagal hapus! Buku ini sedang dipinjam siswa.',
            isError: true);
        return;
      }
      setState(() {
        _books.removeWhere((b) => b.id == id);
      });
      if (AppConfig.isConfigured) {
        _deleteFromSupabase("books", id);
      }
      _triggerSnackBar('Buku "${book.title}" dihapus.');
    } catch (e) {
      _triggerSnackBar('Buku tidak ditemukan!', isError: true);
    }
  }

  // --- ACTIONS FOR MEMBERS ---
  void _addMember(Member member) {
    setState(() {
      _members.add(member);
    });
    if (AppConfig.isConfigured) {
      _syncToSupabase("members", member.toJson());
    }
    _triggerSnackBar('Anggota "${member.name}" berhasil terdaftar!');
  }

  void _editMember(Member src) {
    setState(() {
      final idx = _members.indexWhere((m) => m.id == src.id);
      if (idx != -1) {
        _members[idx] = src;
      }
    });
    if (AppConfig.isConfigured) {
      _updateSupabase("members", src.id, src.toJson());
    }
    _triggerSnackBar('Data siswa berhasil diupdate!');
  }

  void _deleteMember(int id) {
    bool hasActive =
        _transactions.any((t) => t.memberId == id && t.status == 'borrowed');
    if (hasActive) {
      _triggerSnackBar('Gagal hapus! Anggota masih memiliki pinjaman aktif.',
          isError: true);
      return;
    }
    setState(() {
      _members.removeWhere((m) => m.id == id);
    });
    if (AppConfig.isConfigured) {
      _deleteFromSupabase("members", id);
    }
    _triggerSnackBar('Anggota berhasil dihapus.');
  }

  // --- ACTIONS FOR CIRCULATION ---
  void _processBorrow(int bookId, int memberId) {
    try {
      final book = _books.firstWhere((b) => b.id == bookId);
      if (book.available <= 0) {
        _triggerSnackBar('Stok buku habis!', isError: true);
        return;
      }

      final newTx = Transaction(
        id: DateTime.now().millisecondsSinceEpoch,
        bookId: bookId,
        memberId: memberId,
        borrowDate: DateTime.now().toIso8601String().split('T')[0],
        status: 'borrowed',
      );

      setState(() {
        book.available -= 1;
        _transactions.insert(0, newTx);
      });

      if (AppConfig.isConfigured) {
        _syncToSupabase("transactions", newTx.toJson());
        _updateSupabase("books", book.id, book.toJson());
      }

      _triggerSnackBar('Peminjaman buku "${book.title}" berhasil dicatat!');
    } catch (e) {
      _triggerSnackBar('Buku tidak ditemukan!', isError: true);
    }
  }

  void _processReturn(int transactionId) {
    setState(() {
      final txIdx = _transactions.indexWhere((t) => t.id == transactionId);
      if (txIdx != -1) {
        _transactions[txIdx].status = 'returned';
        _transactions[txIdx].returnDate =
            DateTime.now().toIso8601String().split('T')[0];

        final book =
            _books.firstWhere((b) => b.id == _transactions[txIdx].bookId);
        book.available += 1;

        if (AppConfig.isConfigured) {
          _updateSupabase(
              "transactions", transactionId, _transactions[txIdx].toJson());
          _updateSupabase("books", book.id, book.toJson());
        }

        _triggerSnackBar('Buku "${book.title}" berhasil dikembalikan!');
      }
    });
  }

  // --- ACTIONS FOR VISITORS ---
  void _registerVisitor(String nis, String method) {
    try {
      final student = _members.firstWhere((m) => m.nis == nis);
      setState(() {
        _visitors.insert(
          0,
          Visitor(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nis: student.nis,
            name: student.name,
            classRoom: student.memberClass,
            timestamp: DateTime.now().toIso8601String(),
            method: method,
          ),
        );
      });
      _triggerSnackBar(
          'Selamat datang, ${student.name}! Kehadiran Anda berhasil tercatat.');
    } catch (e) {
      _triggerSnackBar(
          'NIS atau kartu "$nis" tidak terdaftar di database perpustakaan!',
          isError: true);
    }
  }

  void _deleteVisitor(String id) {
    setState(() {
      _visitors.removeWhere((item) => item.id == id);
    });
    _triggerSnackBar('Log presensi berhasil dihapus.');
  }

  void _clearVisitors() {
    setState(() {
      _visitors.clear();
    });
    _triggerSnackBar('Sirkulasi daftar pengunjung hari ini dikosongkan.');
  }

  // --- SUPABASE SINKRONISASI CODES (METODE INTEGRASI REAL) ---
  void _syncToSupabase(String table, Map<String, dynamic> data) async {
    debugPrint("[Supabase] Menambahkan data ke $table: ${jsonEncode(data)}");
    if (!AppConfig.isConfigured) return;
    try {
      await Supabase.instance.client.from(table).insert(data);
      debugPrint("[Supabase] Berhasil mengirim data ke tabel $table.");
    } catch (e) {
      debugPrint("[Supabase Error] Gagal insert ke tabel $table: $e");
    }
  }

  void _updateSupabase(
      String table, dynamic id, Map<String, dynamic> data) async {
    debugPrint("[Supabase] Memperbarui data di $table id $id");
    if (!AppConfig.isConfigured) return;
    try {
      await Supabase.instance.client.from(table).update(data).eq('id', id);
      debugPrint("[Supabase] Berhasil memperbarui database $table.");
    } catch (e) {
      debugPrint("[Supabase Error] Gagal update di tabel $table: $e");
    }
  }

  void _deleteFromSupabase(String table, dynamic id) async {
    debugPrint("[Supabase] Menghapus data dari $table id $id");
    if (!AppConfig.isConfigured) return;
    try {
      await Supabase.instance.client.from(table).delete().eq('id', id);
      debugPrint("[Supabase] Berhasil menghapus data di database $table.");
    } catch (e) {
      debugPrint("[Supabase Error] Gagal menghapus di tabel $table: $e");
    }
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Operator'),
        content: const Text(
            'Apakah Anda ingin keluar dari akun operator perpustakaan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(_schoolName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFF1E8A5F),
              foregroundColor: Colors.white,
            ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(isDrawer: true)),
      body: Row(
        children: [
          // Sidebar Panel for Navigation
          if (isDesktop) _buildSidebar(),

          // Main Dynamic Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildSelectedTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 80,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    color: Color(0xFF1E8A5F), size: 28),
                const SizedBox(width: 12),
                Text(
                  _appName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E8A5F),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSidebarNavItem(
              'Dashboard', Icons.dashboard_outlined, 'dashboard', isDrawer),
          _buildSidebarNavItem(
              'Koleksi Buku', Icons.auto_stories_outlined, 'books', isDrawer),
          _buildSidebarNavItem(
              'Data Siswa', Icons.people_outline, 'members', isDrawer),
          _buildSidebarNavItem(
              'Cetak Kartu Siswa', Icons.badge_outlined, 'cards', isDrawer),
          _buildSidebarNavItem(
              'Presensi Masuk', Icons.how_to_reg_rounded, 'visitors', isDrawer),
          _buildSidebarNavItem('Peminjaman (Scan)', Icons.swap_horiz_outlined,
              'transactions', isDrawer),
          _buildSidebarNavItem(
              'Pengaturan', Icons.settings_outlined, 'settings', isDrawer),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E8A5F).withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0xFF1E8A5F).withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppConfig.isConfigured
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_off_rounded,
                        color: AppConfig.isConfigured
                            ? const Color(0xFF1E8A5F)
                            : Colors.amber.shade800,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConfig.isConfigured
                            ? 'Database Supabase'
                            : 'Database Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConfig.isConfigured
                              ? const Color(0xFF1E8A5F)
                              : Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConfig.isConfigured
                        ? 'Tersambung real-time dengan postgresql gratis Anda.'
                        : 'Menyimpan offline di komputer lokal Anda.',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade600, height: 1.4),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(
      String title, IconData icon, String tabId, bool isDrawer) {
    final bool isActive = _activeTab == tabId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = tabId;
          });
          if (isDrawer) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1E8A5F).withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isActive
                      ? const Color(0xFF1E8A5F)
                      : const Color(0xFF64748B),
                  size: 20),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: isActive
                      ? const Color(0xFF1E8A5F)
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _schoolName.toUpperCase(),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E8A5F),
                    letterSpacing: 1),
              ),
              Row(
                children: [
                  const Text(
                    'Operator: ',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  Text(
                    _operatorName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _showLogoutConfirmDialog,
            icon: const Icon(Icons.logout, size: 14),
            label:
                const Text('Keluar Operator', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              elevation: 0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_activeTab) {
      case 'dashboard':
        return DashboardTab(
          books: _books,
          members: _members,
          transactions: _transactions,
          appName: _appName,
          schoolName: _schoolName,
          onNavigateTab: (tab) {
            setState(() {
              _activeTab = tab;
            });
          },
        );
      case 'books':
        return BooksTab(
          books: _books,
          onAddBook: _addBook,
          onEditBook: _editBook,
          onDeleteBook: _deleteBook,
          triggerSnackBar: _triggerSnackBar,
        );
      case 'members':
        return MembersTab(
          members: _members,
          onAddMember: _addMember,
          onEditMember: _editMember,
          onDeleteMember: _deleteMember,
          triggerSnackBar: _triggerSnackBar,
        );
      case 'cards':
        return CardsTab(
          members: _members,
          schoolName: _schoolName,
          triggerSnackBar: _triggerSnackBar,
        );
      case 'visitors':
        return VisitorsTab(
          visitors: _visitors,
          members: _members,
          onRegisterVisitor: _registerVisitor,
          onDeleteVisitor: _deleteVisitor,
          onClearVisitors: _clearVisitors,
          triggerSnackBar: _triggerSnackBar,
        );
      case 'transactions':
        return TransactionsTab(
          transactions: _transactions,
          books: _books,
          members: _members,
          onProcessBorrow: _processBorrow,
          onProcessReturn: _processReturn,
          triggerSnackBar: _triggerSnackBar,
        );
      case 'settings':
        return SettingsTab(
          appName: _appName,
          schoolName: _schoolName,
          operatorName: _operatorName,
          onSave: (appName, schoolName, operatorName) {
            setState(() {
              _appName = appName;
              _schoolName = schoolName;
              _operatorName = operatorName;
            });
            _triggerSnackBar('Branding identitas berhasil diperbarui!');
          },
        );
      default:
        return const Center(child: Text("Halaman tidak ditemukan."));
    }
  }
}
