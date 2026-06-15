import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/member.dart';
import '../models/visitor.dart';
import '../utils/sound_utils.dart';

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
  MobileScannerController? _scannerController;

  void _toggleCamera(bool val) {
    setState(() {
      _cameraActive = val;
      if (_cameraActive) {
        _scannerController = MobileScannerController(
          facing: CameraFacing.front,
        );
      } else {
        _scannerController?.dispose();
        _scannerController = null;
      }
    });
  }

  @override
  void dispose() {
    _visitorNisCtrl.dispose();
    _scannerController?.dispose();
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
                                  onChanged: _toggleCamera,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_cameraActive)
                              Container(
                                height: 260,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: MobileScanner(
                                          controller: _scannerController,
                                          onDetect: (capture) {
                                            final List<Barcode> barcodes =
                                                capture.barcodes;
                                            for (final barcode in barcodes) {
                                              final String? code =
                                                  barcode.rawValue;
                                              if (code != null &&
                                                  code.isNotEmpty) {
                                                SoundUtils.playBeep();
                                                widget.onRegisterVisitor(
                                                    code, 'camera');
                                                break;
                                              }
                                            }
                                          },
                                          errorBuilder:
                                              (context, error, child) {
                                            return Center(
                                              child: Text(
                                                'Kamera Error: ${error.errorCode.name}',
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      // Laser scanning line
                                      Center(
                                        child: Container(
                                          width: double.infinity,
                                          height: 2,
                                          color: Colors.greenAccent,
                                        ),
                                      ),
                                      // Simulating quick-test simulation buttons overlay at bottom of camera view
                                      Positioned(
                                        bottom: 12,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Ujicoba Scan Cepat (Kamera Emulator)',
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children:
                                                        widget.members.map((m) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    4.0),
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
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        4),
                                                            minimumSize:
                                                                Size.zero,
                                                          ),
                                                          child: Text(
                                                            m.name
                                                                .split(' ')[0],
                                                            style:
                                                                const TextStyle(
                                                                    fontSize: 9,
                                                                    color: Colors
                                                                        .white),
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
                                      ),
                                    ],
                                  ),
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

                      // Manual physical scanner input
                      const Text(
                        'Input Scanner Fisik (Arahkan Barcode atau Ketik NIS & Enter)',
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
                                  SoundUtils.playBeep();
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
                                SoundUtils.playBeep();
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
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  title: const Text('Konfirmasi Kosongkan Log'),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus seluruh log daftar kunjungan pengunjung hari ini?'),
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
                                        widget.onClearVisitors();
                                      },
                                      child: const Text('Kosongkan',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext ctx) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Konfirmasi Hapus'),
                                              content: Text(
                                                  'Apakah Anda yakin ingin menghapus log kehadiran "${v.name}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: const Text('Batal'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                    widget
                                                        .onDeleteVisitor(v.id);
                                                  },
                                                  child: const Text('Hapus',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
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
