import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/visitor.dart';

class VisitorsTab extends StatefulWidget {
  final List<Visitor> visitors;
  final List<Member> members;
  final Function(String nis, String method) onRegisterVisitor;
  final Function(String id) onDeleteVisitor;
  final Function() onClearVisitors;
  final Function(String message, {bool isError}) triggerSnackBar;

  const VisitorsTab({
    Key? key,
    required this.visitors,
    required this.members,
    required this.onRegisterVisitor,
    required this.onDeleteVisitor,
    required this.onClearVisitors,
    required this.triggerSnackBar,
  }) : super(key: key);

  @override
  State<VisitorsTab> createState() => _VisitorsTabState();
}

class _VisitorsTabState extends State<VisitorsTab> {
  String _visitorSearchQuery = "";
  bool _cameraActive = false;
  final TextEditingController _visitorNisCtrl = TextEditingController();
  String? _selectedMemberForVisitor;

  @override
  void dispose() {
    _visitorNisCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.visitors.where((v) {
      final query = _visitorSearchQuery.toLowerCase();
      return v.name.toLowerCase().contains(query) ||
          v.nis.contains(query) ||
          v.classRoom.toLowerCase().contains(query);
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Controllers
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Presensi Pintu Masuk',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E8A5F)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Siswa wajib melakukan scan kartu anggota di depan kamera / scanner sebelum masuk.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // Webcam simulation block
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2FBF0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF2EBD82).withOpacity(0.2)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.qr_code_scanner,
                                        color: Color(0xFF1E8A5F), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _cameraActive
                                          ? 'Kamera Pemindai Aktif'
                                          : 'Kamera Non-aktif',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E8A5F)),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _cameraActive,
                                  activeColor: const Color(0xFF1E8A5F),
                                  onChanged: (val) {
                                    setState(() {
                                      _cameraActive = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_cameraActive)
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.videocam,
                                                color: Colors.white70,
                                                size: 40),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Posisikan Barcode Kartu di Sini',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11),
                                            ),
                                            const SizedBox(height: 12),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children:
                                                    widget.members.map((m) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4.0),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        widget
                                                            .onRegisterVisitor(
                                                                m.nis,
                                                                'camera');
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF1E8A5F),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        minimumSize: Size.zero,
                                                      ),
                                                      child: Text(
                                                        'Scan ${m.name.split(' ')[0]}',
                                                        style: const TextStyle(
                                                            fontSize: 9,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Green scan indicator line
                                    const Positioned(
                                      left: 20,
                                      right: 20,
                                      top: 80,
                                      child: Divider(
                                          color: Colors.greenAccent,
                                          thickness: 2),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Webcam Pemindai Chromebook Non-aktif',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black54),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Manual simulation text field
                      const Text(
                        'Simulasi Hardware Scanner (Ketik NIS & Enter)',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _visitorNisCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Ketik NIS siswa...',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  widget.onRegisterVisitor(
                                      val.trim(), 'barcode');
                                  _visitorNisCtrl.clear();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_visitorNisCtrl.text.trim().isNotEmpty) {
                                widget.onRegisterVisitor(
                                    _visitorNisCtrl.text.trim(), 'barcode');
                                _visitorNisCtrl.clear();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E8A5F),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Masuk'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Manual Selector
                      const Text(
                        'Kehadiran Manual Tanpa Barcode (Pilih Nama)',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedMemberForVisitor,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('-- Pilih Siswa --'),
                              items: widget.members.map((m) {
                                return DropdownMenuItem(
                                  value: m.nis,
                                  child: Text('${m.name} (${m.memberClass})'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedMemberForVisitor = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_selectedMemberForVisitor != null) {
                                widget.onRegisterVisitor(
                                    _selectedMemberForVisitor!, 'manual');
                              }
                            },
                            child: const Text('Hadir'),
                          ),
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

        // Right Column: Visitor Log list
        Expanded(
          flex: 7,
          child: Card(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daftar Pengunjung Hari Ini',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total kehadiran hari ini: ${widget.visitors.length} siswa',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (widget.visitors.isNotEmpty)
                        TextButton(
                          onPressed: widget.onClearVisitors,
                          child: const Text('Kosongkan Log',
                              style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search field
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        _visitorSearchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama / NIS / kelas...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Attendance List Table
                  filtered.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child:
                                Text('Belum ada log kehadiran untuk hari ini.'),
                          ),
                        )
                      : Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (ctx, idx) {
                              final v = filtered[idx];
                              final timeStr = v.timestamp.contains('T')
                                  ? v.timestamp.split('T')[1].substring(0, 8)
                                  : v.timestamp;

                              Color methodColor = Colors.grey;
                              String methodLabel = 'Manual';
                              if (v.method == 'camera') {
                                methodColor = Colors.green;
                                methodLabel = 'Kamera';
                              } else if (v.method == 'barcode') {
                                methodColor = Colors.blue;
                                methodLabel = 'Scan';
                              }

                              return ListTile(
                                leading: Text(
                                  timeStr,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                title: Text(
                                  v.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                subtitle: Text(
                                  'NIS: ${v.nis} | Kelas: ${v.classRoom}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Chip(
                                      label: Text(
                                        methodLabel,
                                        style: const TextStyle(
                                            fontSize: 8,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: methodColor,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red, size: 16),
                                      onPressed: () {
                                        widget.onDeleteVisitor(v.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
