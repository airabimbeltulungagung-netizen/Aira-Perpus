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

  // Akun Mitra/Sekolah yang didaftarkan khusus oleh Developer (Anda)
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

    // 1. Cek apakah cocok dengan akun lisensi demo bawan secara offline
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

      // Arahkan ke Dashboard utama dengan membawa data Sekolah terkait
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

    // 2. Jika tidak cocok offline, cek ke Supabase Auth (jika terkonfigurasi)
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
              "INSTITUSI MANDIRI (SUPABASE)";
          final operatorName = user.userMetadata?['operator'] ??
              user.email?.split('@').first.toUpperCase() ??
              "Operator Mitra";

          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Akses Berhasil! Terhubung secara online ke database Supabase Anda"),
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
        debugPrint("[Supabase Auth Error]: $e");
        _showErrorSnackBar(
            "Gagal masuk via Supabase: Kombinasi sandi keliru atau akun belum terdaftar.");
        return;
      }
    }

    // 3. Gabungan gagal
    setState(() {
      _isLoading = false;
    });

    if (!AppConfig.isConfigured) {
      _showErrorSnackBar(
          "Koneksi Supabase belum aktif! Akun ini tidak terdaftar secara offline, dan 'my_perpus_app/lib/config.dart' Anda masih berisi URL/Key placeholder.");
    } else {
      _showErrorSnackBar(
          "Gagal login: Email/Sandi salah atau akun belum terverifikasi di Supabase.");
    }
  }

  void _showSignUpDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final opCtrl = TextEditingController();
    final schoolCtrl = TextEditingController();
    bool isRegLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.person_add_alt_1_rounded,
                      color: Color(0xFF1E8A5F)),
                  SizedBox(width: 10),
                  Text('Daftar Operator Baru'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Daftarkan institusi sekolah ke database Supabase Anda yang sedang aktif.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Operator *',
                        hintText: 'perpus@darussalam.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Kata Sandi Baru *',
                        hintText: 'Minimal 6 karakter',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: opCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Operator *',
                        hintText: 'Ahmad Fauzi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: schoolCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Sekolah / Institusi *',
                        hintText: 'SMPN 03 Sutojayan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Catatan: Pastikan opsi "Confirm Email" pada dashboard Supabase Anda (Auth -> Providers -> Email) telah Dinonaktifkan (Disabled) agar akun langsung aktif tanpa verifikasi email.',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                isRegLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF1E8A5F))),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E8A5F),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final email = emailCtrl.text.trim();
                          final pass = passCtrl.text;
                          final op = opCtrl.text.trim();
                          final sch = schoolCtrl.text.trim();

                          if (email.isEmpty ||
                              pass.isEmpty ||
                              op.isEmpty ||
                              sch.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Harap lengkapi seluruh kolom formulir!")),
                            );
                            return;
                          }

                          setDialogState(() {
                            isRegLoading = true;
                          });

                          try {
                            final res =
                                await Supabase.instance.client.auth.signUp(
                              email: email,
                              password: pass,
                              data: {
                                'operator': op,
                                'school_name': sch,
                              },
                            );

                            if (res.user != null) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Pendaftaran sukses! Silakan coba login menggunakan akun baru ini."),
                                  backgroundColor: Color(0xFF1E8A5F),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Gagal mendaftar: $e"),
                                  backgroundColor: Colors.red.shade800),
                            );
                          } finally {
                            setDialogState(() {
                              isRegLoading = false;
                            });
                          }
                        },
                        child: const Text('Daftar Akun'),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDatabaseSettingsDialog() {
    final urlCtrl = TextEditingController(
        text: AppConfig.supabaseUrl == AppConfig.defaultSupabaseUrl
            ? ""
            : AppConfig.supabaseUrl);
    final keyCtrl = TextEditingController(
        text: AppConfig.supabaseAnonKey == AppConfig.defaultSupabaseAnonKey
            ? ""
            : AppConfig.supabaseAnonKey);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.cloud_sync_rounded, color: Color(0xFF1E8A5F)),
                  SizedBox(width: 10),
                  Text('Koneksi Supabase Anda'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sambungkan PerpusApp dengan backend PostgreSQL database Supabase Anda sendiri secara instan.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Supabase URL *',
                        hintText: 'https://xxx.supabase.co',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: keyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Supabase Anon Key *',
                        hintText: 'Masukkan Public Anon Key',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (AppConfig.isConfigured) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E8A5F).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Terkoneksi:',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E8A5F)),
                            ),
                            Text(
                              AppConfig.supabaseUrl,
                              style: const TextStyle(
                                  fontSize: 10, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Saat ini menggunakan Database Offline (Demo Mode).',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (AppConfig.supabaseUrl != AppConfig.defaultSupabaseUrl)
                  TextButton(
                    onPressed: () async {
                      await AppConfig.clearCustomConfigs();
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Konfigurasi database di-reset kembali ke Mode Offline.')),
                        );
                        setState(() {});
                      }
                    },
                    child: const Text('Reset Offline',
                        style: TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                isSaving
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF1E8A5F))),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E8A5F),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final url = urlCtrl.text.trim();
                          final key = keyCtrl.text.trim();

                          if (url.isEmpty || key.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Harap isi kedua kolom URL & Anon Key!")),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await AppConfig.saveCustomConfigs(url, key);
                            await Supabase.initialize(
                              url: url,
                              anonKey: key,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Koneksi Supabase Baru sukses disimpan dan diaktifkan secara instan!"),
                                  backgroundColor: Color(0xFF1E8A5F),
                                ),
                              );
                              setState(() {});
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Format URL atau Key salah: $e"),
                                  backgroundColor: Colors.red.shade800),
                            );
                          } finally {
                            setDialogState(() {
                              isSaving = false;
                            });
                          }
                        },
                        child: const Text('Simpan & Connect'),
                      ),
              ],
            );
          },
        );
      },
    );
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
                'PerpusApp Premium',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Sistem Sirkulasi & Database Perpustakaan Sekolah',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Masuk Operator',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B)),
                        ),
                        IconButton(
                          icon: Icon(
                            AppConfig.isConfigured
                                ? Icons.cloud_done
                                : Icons.cloud_off_rounded,
                            color: AppConfig.isConfigured
                                ? const Color(0xFF1E8A5F)
                                : const Color(0xFF64748B),
                            size: 20,
                          ),
                          tooltip: 'Pengaturan Koneksi Supabase',
                          onPressed: _showDatabaseSettingsDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gunakan akun khusus sekolah yang telah dibuatkan khusus oleh Developer.',
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
                    if (AppConfig.isConfigured) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _showSignUpDialog,
                        child: const Text(
                          'Belum Terdaftar? Daftarkan Operator Baru',
                          style: TextStyle(
                            color: Color(0xFF1E8A5F),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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
                'Hubungi Developer (Mahendra) untuk mendaftarkan lisensi baru bagi sekolah klien Anda.',
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
