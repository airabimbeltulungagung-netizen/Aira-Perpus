import 'package:flutter/material.dart';
import '../models/member.dart';

class MembersTab extends StatefulWidget {
  final List<Member> members;
  final Function(Member) onAddMember;
  final Function(Member) onEditMember;
  final Function(int) onDeleteMember;
  final Function(String message, {bool isError}) triggerSnackBar;

  const MembersTab({
    Key? key,
    required this.members,
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

  @override
  Widget build(BuildContext context) {
    final filtered = widget.members.where((m) {
      final query = _searchQuery.toLowerCase();
      return m.name.toLowerCase().contains(query) || m.nis.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Database Profil Anggota (Siswa)',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            ElevatedButton.icon(
              onPressed: () => _showMemberFormDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Registrasi Siswa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8A5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
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
                    label: Text('Aksi',
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
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.blue, size: 18),
                          onPressed: () => _showMemberFormDialog(member: m),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 18),
                          onPressed: () => widget.onDeleteMember(m.id),
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
    final nameCtrl = TextEditingController(text: isEdit ? member.name : '');
    final nisCtrl = TextEditingController(text: isEdit ? member.nis : '');
    final classCtrl =
        TextEditingController(text: isEdit ? member.memberClass : 'VII-A');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(isEdit ? 'Sunting Data Siswa' : 'Registrasi Anggota Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Nama Lengkap *')),
                const SizedBox(height: 8),
                TextField(
                    controller: nisCtrl,
                    decoration:
                        const InputDecoration(labelText: 'NIS / ID Kartu *')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: classCtrl.text,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  items: const [
                    DropdownMenuItem(value: 'VII-A', child: Text('VII-A')),
                    DropdownMenuItem(value: 'VII-B', child: Text('VII-B')),
                    DropdownMenuItem(value: 'VIII-A', child: Text('VIII-A')),
                    DropdownMenuItem(value: 'VIII-B', child: Text('VIII-B')),
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
                if (nameCtrl.text.isEmpty || nisCtrl.text.isEmpty) {
                  widget.triggerSnackBar('Harap isi Nama dan NIS!',
                      isError: true);
                  return;
                }
                if (isEdit) {
                  widget.onEditMember(Member(
                    id: member.id,
                    name: nameCtrl.text,
                    nis: nisCtrl.text,
                    memberClass: classCtrl.text,
                  ));
                } else {
                  widget.onAddMember(Member(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: nameCtrl.text,
                    nis: nisCtrl.text,
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
  }
}
