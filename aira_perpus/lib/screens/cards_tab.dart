import 'package:flutter/material.dart';
import '../models/member.dart';
import '../widgets/library_card.dart';
import '../utils/card_generator.dart';

class CardsTab extends StatefulWidget {
  final List<Member> members;
  final String schoolName;
  final Function(String message, {bool isError}) triggerSnackBar;

  const CardsTab({
    Key? key,
    required this.members,
    required this.schoolName,
    required this.triggerSnackBar,
  }) : super(key: key);

  @override
  State<CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  String _cardClassFilter = "";
  String _cardSearchFilter = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.members.where((m) {
      final matchesSearch = _cardSearchFilter.isEmpty ||
          m.name.toLowerCase().contains(_cardSearchFilter.toLowerCase()) ||
          m.nis.contains(_cardSearchFilter);
      final matchesClass =
          _cardClassFilter.isEmpty || m.memberClass == _cardClassFilter;
      return matchesSearch && matchesClass;
    }).toList();

    final List<String> uniqueClasses =
        widget.members.map((m) => m.memberClass).toSet().toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Template Kartu Anggota',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cetak kartu resmi perpustakaan sekolah berlisensi ${widget.schoolName.toUpperCase()}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    if (filtered.isEmpty) {
                      widget.triggerSnackBar(
                          'Daftar siswa kosong! Tidak ada kartu untuk diekspor.',
                          isError: true);
                      return;
                    }
                    widget.triggerSnackBar(
                        'Sedang menyiapkan template Word (.doc) untuk ${filtered.length} siswa...',
                        isError: false);
                    try {
                      await CardGenerator.downloadWord(
                          filtered, widget.schoolName, "Aira Perpus");
                      widget.triggerSnackBar('Template Word berhasil diunduh!');
                    } catch (e) {
                      widget.triggerSnackBar('Gagal mengunduh berkas Word: $e',
                          isError: true);
                    }
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text('Template .DOCX'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (filtered.isEmpty) {
                      widget.triggerSnackBar(
                          'Daftar siswa kosong! Tidak ada kartu untuk diekspor.',
                          isError: true);
                      return;
                    }
                    widget.triggerSnackBar(
                        'Sedang membuat berkas PDF untuk ${filtered.length} siswa...',
                        isError: false);
                    try {
                      await CardGenerator.downloadPDF(
                          filtered, widget.schoolName, "Aira Perpus");
                      widget.triggerSnackBar('Berkas PDF berhasil diunduh!');
                    } catch (e) {
                      widget.triggerSnackBar('Gagal mengunduh berkas PDF: $e',
                          isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8A5F),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: const Text('Cetak PDF'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Controls bar
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _cardSearchFilter = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari siswa berdasarkan nama / NIS...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _cardClassFilter.isEmpty ? null : _cardClassFilter,
                  hint: const Text('Pilih Kelas (Semua)'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Semua Kelas')),
                    ...uniqueClasses
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _cardClassFilter = val ?? "";
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cards grid
        filtered.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('Tidak ada siswa sesuai kriteria pencarian.'),
                ),
              )
            : Wrap(
                spacing: 16,
                runSpacing: 16,
                children: filtered
                    .map((member) => LibraryCard(
                        member: member, schoolName: widget.schoolName))
                    .toList(),
              ),
      ],
    );
  }
}
