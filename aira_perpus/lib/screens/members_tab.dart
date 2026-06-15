import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/member.dart';
import '../widgets/library_card.dart';
import '../utils/excel_helper.dart';

class MembersTab extends StatefulWidget {
  final List<Member> members;
  final String schoolName;
  final Function(Member) onAddMember;
  final Function(Member) onEditMember;
  final Function(int) onDeleteMember;
  final Function(String message, {bool isError}) triggerSnackBar;

  const MembersTab({
    Key? key,
    required this.members,
    required this.schoolName,
    required this.onAddMember,
    required this.onEditMember,
    required this.onDeleteMember,
    required this.triggerSnackBar,
  }) : super(key: key);

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  String _searchQuery = "";

  // Helper function to pick and parse Excel for member imports
  void _importSiswaExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Crucial for Flutter Web
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final parsed = ExcelHelper.parseMembersExcel(bytes);

        if (parsed.isEmpty) {
          widget.triggerSnackBar(
              "Berkas terbaca kosong atau format tidak sesuai!",
              isError: true);
          return;
        }

        int countSuccess = 0;
        final existingNises = widget.members.map((m) => m.nis).toSet();

        for (var newMember in parsed) {
          if (!existingNises.contains(newMember.nis)) {
            widget.onAddMember(newMember);
            existingNises.add(newMember.nis);
            countSuccess++;
          }
        }

        widget.triggerSnackBar(
            "Berhasil mengimpor $countSuccess siswa baru dari Excel!");
      } else {
        widget.triggerSnackBar("Pemilihan berkas dibatalkan.");
      }
    } catch (e) {
      widget.triggerSnackBar("Gagal mengimpor berkas Excel: $e", isError: true);
    }
  }

  void _downloadExcelTemplate() async {
    try {
      await ExcelHelper.downloadStudentImportTemplate();
      widget.triggerSnackBar("Template Excel berhasil diunduh!");
    } catch (e) {
      widget.triggerSnackBar("Gagal mengunduh template: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.members.where((m) {
      final query = _searchQuery.toLowerCase();
      return m.name.toLowerCase().contains(query) || m.nis.contains(query);
    }).toList();

    final bool isDesktop = MediaQuery.of(context).size.width > 950;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header & Actions Wrap
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Database Profil Anggota (Siswa)',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
                SizedBox(height: 2),
                Text(
                  'Kelola kartu akses perpus, impor biodata dari Excel, atau sunting profil kelas.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Button 1: Download Template Excel
                OutlinedButton.icon(
                  onPressed: _downloadExcelTemplate,
                  icon: const Icon(Icons.file_download_outlined, size: 15),
                  label: const Text('Format Excel Template',
                      style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E8A5F),
                    side: const BorderSide(color: Color(0xFF1E8A5F)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
                // Button 2: Import Excel
                ElevatedButton.icon(
                  onPressed: _importSiswaExcel,
                  icon: const Icon(Icons.file_upload_rounded,
                      size: 15, color: Colors.white),
                  label: const Text('Impor Siswa (Excel)',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
                // Button 3: Registrasi Manual
                ElevatedButton.icon(
                  onPressed: () => _showMemberFormDialog(),
                  icon: const Icon(Icons.person_add_alt_1_rounded,
                      size: 15, color: Colors.white),
                  label: const Text('Registrasi Manual',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8A5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),

        // Search Bar
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan nama atau NIS kartu siswa...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('Nomor NIS / ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Nama Lengkap Siswa',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Kelas',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Aksi sirkulasi',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.map((m) {
                return DataRow(cells: [
                  DataCell(Text(m.nis,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold))),
                  DataCell(Text(m.name,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(m.memberClass)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.qr_code_2_rounded,
                              color: Color(0xFF1E8A5F), size: 18),
                          tooltip: 'Lihat Kartu',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  contentPadding: EdgeInsets.zero,
                                  content: Center(
                                    child: LibraryCard(
                                      member: m,
                                      schoolName: widget.schoolName,
                                    ),
                                  ),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    ElevatedButton.icon(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Tutup'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black87,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.blue, size: 18),
                          onPressed: () => _showMemberFormDialog(member: m),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 18),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: Text(
                                      'Apakah Anda yakin ingin menghapus siswa "${m.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        widget.onDeleteMember(m.id);
                                      },
                                      child: const Text('Hapus',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        )
      ],
    );
  }

  void _showMemberFormDialog({Member? member}) {
    final isEdit = member != null;
    String initialNis = "";
    if (isEdit) {
      initialNis = member.nis;
    } else {
      // Generate a unique 6-digit code
      final existingNises = widget.members.map((m) => m.nis).toSet();
      final rand = math.Random();
      String generatedNis;
      do {
        generatedNis = (100000 + rand.nextInt(900000)).toString();
      } while (existingNises.contains(generatedNis));
      initialNis = generatedNis;
    }

    final nameCtrl = TextEditingController(text: isEdit ? member.name : '');
    final nisCtrl = TextEditingController(text: initialNis);
    final classCtrl =
        TextEditingController(text: isEdit ? member.memberClass : 'VII-A');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                  isEdit ? 'Sunting Data Siswa' : 'Registrasi Anggota Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nama Lengkap *',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nisCtrl,
                            decoration: const InputDecoration(
                              labelText: 'NIS / ID Kartu Anggota *',
                              helperText: 'Isilah dengan angka unik.',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        if (!isEdit) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Acak ID Baru',
                            icon: const Icon(Icons.refresh,
                                color: Color(0xFF1E8A5F)),
                            onPressed: () {
                              final existingNises =
                                  widget.members.map((m) => m.nis).toSet();
                              final rand = math.Random();
                              String generatedNis;
                              do {
                                generatedNis =
                                    (100000 + rand.nextInt(900000)).toString();
                              } while (existingNises.contains(generatedNis));
                              setDialogState(() {
                                nisCtrl.text = generatedNis;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: classCtrl.text,
                      decoration: const InputDecoration(
                          labelText: 'Kelas *', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'VII-A', child: Text('VII-A')),
                        DropdownMenuItem(value: 'VII-B', child: Text('VII-B')),
                        DropdownMenuItem(
                            value: 'VIII-A', child: Text('VIII-A')),
                        DropdownMenuItem(
                            value: 'VIII-B', child: Text('VIII-B')),
                        DropdownMenuItem(value: 'IX-A', child: Text('IX-A')),
                        DropdownMenuItem(value: 'IX-B', child: Text('IX-B')),
                        DropdownMenuItem(value: 'IX-C', child: Text('IX-C')),
                      ],
                      onChanged: (val) {
                        if (val != null) classCtrl.text = val;
                      },
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8A5F),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty ||
                        nisCtrl.text.trim().isEmpty) {
                      widget.triggerSnackBar('Harap isi Nama dan NIS!',
                          isError: true);
                      return;
                    }
                    if (isEdit) {
                      widget.onEditMember(Member(
                        id: member.id,
                        name: nameCtrl.text.trim(),
                        nis: nisCtrl.text.trim(),
                        memberClass: classCtrl.text,
                      ));
                    } else {
                      // Custom BigInt-compatible timestamp ID (to prevent Pgrest out-of-range integer errors)
                      final randSeed =
                          (100 + (DateTime.now().millisecond % 900));
                      final uniqueId =
                          DateTime.now().millisecondsSinceEpoch + randSeed;

                      widget.onAddMember(Member(
                        id: uniqueId,
                        name: nameCtrl.text.trim(),
                        nis: nisCtrl.text.trim(),
                        memberClass: classCtrl.text,
                      ));
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
