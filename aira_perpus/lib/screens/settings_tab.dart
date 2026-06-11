import 'package:flutter/material.dart';

class SettingsTab extends StatefulWidget {
  final String appName;
  final String schoolName;
  final String operatorName;
  final Function(String appName, String schoolName, String operatorName) onSave;

  const SettingsTab({
    Key? key,
    required this.appName,
    required this.schoolName,
    required this.operatorName,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Rebranding & Kustomisasi Identitas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kelola nama APK resmi dan informasi lembaga penerbit untuk seluruh antarmuka sistem.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 18),
        Card(
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
                    Icon(Icons.palette_outlined, color: Color(0xFF1E8A5F), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Formulir Rebranding Identitas Aplikasi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
                    labelText: 'Nama Lengkap Sekolah / Lembaga',
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
                  label: const Text('Simpan & Terapkan Perubahan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
