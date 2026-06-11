import 'package:flutter/material.dart';
import '../models/member.dart';

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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Unduh Template Microsoft Word'),
                        content: Text(
                            'Sistem sedang mengemas ${filtered.length} berkas identitas ke dalam template tabel MS Word (.docx).\n\nSekolah dapat langsung mencetak masal lembaran ini, menempelkan pas foto fisik siswa, lalu melaminasi untuk hasil terbaik.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK, Unduh Berkas'),
                          )
                        ],
                      ),
                    );
                    widget.triggerSnackBar(
                        'Template DOCX berhasil diunduh ke komputer!');
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text('Template .DOCX'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.triggerSnackBar(
                        'Membuka dialog cetak sistem (Ctrl+P)...');
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
                children:
                    filtered.map((member) => _buildCardWidget(member)).toList(),
              ),
      ],
    );
  }

  Widget _buildCardWidget(Member m) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF1E8A5F),
            width: 1.5,
            style: BorderStyle.solid),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.school, color: Color(0xFF1E8A5F), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KARTU ANGGOTA PERPUSTAKAAN',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E8A5F),
                          letterSpacing: 0.5),
                    ),
                    Text(
                      widget.schoolName.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFF1E8A5F).withOpacity(0.2)),
          const SizedBox(height: 12),

          // Body photo + text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo box
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face_retouching_natural,
                        color: Colors.grey, size: 20),
                    SizedBox(height: 4),
                    Text(
                      'PAS FOTO\n2 X 3',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Student details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NAMA LENGKAP',
                      style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      m.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NIS / NO INDUK',
                                style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              Text(
                                m.nis,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'KELAS',
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            Text(
                              m.memberClass,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E8A5F)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barcode generator (pure Flutter widget design)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildMockBarcodeStrip(),
                const SizedBox(height: 2),
                Text(
                  '* ${m.nis} *',
                  style: const TextStyle(
                      fontSize: 8,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockBarcodeStrip() {
    return SizedBox(
      height: 26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(34, (idx) {
          final isLine = idx % 2 == 0;
          if (!isLine) return const SizedBox(width: 2);
          final widths = [1.0, 1.5, 2.5, 3.0, 1.0, 2.0];
          final double hWidth = widths[idx % widths.length];
          return Container(
            width: hWidth,
            color: Colors.black87,
          );
        }),
      ),
    );
  }
}
