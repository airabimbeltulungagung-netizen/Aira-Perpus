import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../main.dart'; // import MainLayoutScreen from main.dart

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final queryParams = Uri.base.queryParameters;
      if (queryParams.containsKey('scanner')) {
        final sessionId = queryParams['scanner']!;
        if (sessionId.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Bypass Login berhasil! Menghubungkan Satelit HP..."),
              backgroundColor: Color(0xFF1E8A5F),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainLayoutScreen(
                schoolName: "PEMINDAI SATELIT HP",
                operatorName: "Satelit-HP-$sessionId",
                initialActiveTab: 'remote_scanner',
                initialMobileMode: true,
                initialSessionId: sessionId,
              ),
            ),
          );
        }
      }
    });
  }

  // PENTING: Mencegah Memory Leak (Aplikasi Ngelag)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Akun Mitra/Sekolah Demo (Offline Fallback)
  final List<Map<String, String>> _registeredSchoolAccounts = [
    {
      'email': 'smpn3@sutojayan.sch.id',
      'password': 'smpn3sutojayan',
      'school_name': 'SMPN 03 SUTOJAYAN',
      'operator': 'Admin Perpus Kelompok A'
    },
    {
      'email': 'demo@perpusapp.com',
      'password': 'demopassword',
      'school_name': 'SMP NEGERI DEMO INDRALOKA',
      'operator': 'Operator Percobaan Resmi'
    },
  ];

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("Harap masukkan email & kata sandi lisensi sekolah!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 1. Cek mode offline (Demo)
    Map<String, String>? matchedAccount;
    for (var acc in _registeredSchoolAccounts) {
      if (acc['email'] == email && acc['password'] == password) {
        matchedAccount = acc;
        break;
      }
    }

    if (matchedAccount != null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Akses Berhasil! Berlisensi untuk ${matchedAccount['school_name']}"),
          backgroundColor: const Color(0xFF1E8A5F),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainLayoutScreen(
            schoolName: matchedAccount!['school_name']!,
            operatorName: matchedAccount['operator']!,
          ),
        ),
      );
      return;
    }

    // 2. Cek ke Server Master Supabase Anda
    if (AppConfig.isConfigured) {
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = response.user;
        if (user != null) {
          final schoolName = user.userMetadata?['school_name'] ??
              user.userMetadata?['school'] ??
              "SISTEM LAYANAN PERPUSTAKAAN";
          final operatorName = user.userMetadata?['operator'] ??
              user.email?.split('@').first.toUpperCase() ??
              "Operator Perpustakaan";

          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Akses Berhasil! Menyelaraskan data dengan server cloud perpustakaan."),
              backgroundColor: Color(0xFF1E8A5F),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainLayoutScreen(
                schoolName: schoolName,
                operatorName: operatorName,
              ),
            ),
          );
          return;
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        debugPrint("[Auth Error]: $e");
        _showErrorSnackBar(
            "Gagal login: Kombinasi sandi keliru atau lisensi tidak valid.");
        return;
      }
    }

    // 3. Gabungan gagal
    setState(() {
      _isLoading = false;
    });

    _showErrorSnackBar(
        "Gagal login: Periksa lisensi akun Anda atau koneksi internet.");
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful Header Logo
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E8A5F).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF1E8A5F),
                  size: 52,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aira Perpus Premium',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Sistem Sirkulasi & Database Perpustakaan Terpusat',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),

              // Login form container card
              Container(
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Masuk Operator',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Silakan masuk menggunakan kredensial lisensi sekolah yang diberikan oleh Developer.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 24),

                    // Email Field
                    const Text(
                      'EMAIL RESMI OPERATOR SEKOLAH',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'admin@nama-sekolah.sch.id',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Password Field
                    const Text(
                      'KATA SANDI LISENSI',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF1E8A5F)))
                        : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E8A5F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            child: const Text('Autentikasi Lisensi Masuk',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              // Developer branding & info
              Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Text('Mode Demo / Untuk Uji Coba:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.amber)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email: smpn3@sutojayan.sch.id\nSandi: smpn3sutojayan',
                        style: TextStyle(
                            fontSize: 12, fontFamily: 'monospace', height: 1.4),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '© 2026 Aira Hub Edu. Hubungi Developer (Mahendra) untuk pendaftaran lisensi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      ),
    );
  }
}
