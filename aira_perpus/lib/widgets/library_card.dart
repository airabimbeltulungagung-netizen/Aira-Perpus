import 'package:flutter/material.dart';
import '../models/member.dart';

class LibraryCard extends StatelessWidget {
  final Member member;
  final String schoolName;

  const LibraryCard({
    Key? key,
    required this.member,
    required this.schoolName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Premium gradient background: deep emerald forest to sleek dark jade
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF022C22), // Very dark teal
            Color(0xFF0F766E), // Deep teal
            Color(0xFF047857), // Forest emerald
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        border: Border.all(
          color: const Color(0xFFFBBF24).withOpacity(0.4), // Soft Gold border
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF022C22).withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Elegant Watermark pattern in the background
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.local_library_rounded,
                size: 140,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: -20,
            top: -20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.auto_stories,
                size: 110,
                color: Colors.white,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // School mini shield/icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFEAB308), width: 1),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Color(0xFFFBBF24), // Gold
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KARTU PINTAR PERPUSTAKAAN DIGITAL',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF34D399), // Emerald Accent
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            schoolName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // VIP Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFFBBF24), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star_rounded,
                              color: Color(0xFFFBBF24), size: 10),
                          SizedBox(width: 2),
                          Text(
                            'SMART ACCESS',
                            style: TextStyle(
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFBBF24).withOpacity(0.5),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Card Body: Photo + Gold Smart Chip + Student Details
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo column
                      Column(
                        children: [
                          // Squircle/Circular photo with glowing gold frame
                          Container(
                            width: 54,
                            height: 66,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFFBBF24), width: 1.5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF34D399),
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // RFID Chip Graphic
                          Container(
                            width: 26,
                            height: 18,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                  color: const Color(0xFFD97706), width: 0.5),
                            ),
                            child: CustomPaint(
                              painter: _ChipLinesPainter(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Details column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'NAMA LENGKAP ANGGOTA',
                              style: TextStyle(
                                fontSize: 6.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8), // Muted grey
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  )
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ID BARCODE / NIS',
                                        style: TextStyle(
                                          fontSize: 6.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF94A3B8),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        member.nis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                          color: Color(0xFFFBBF24), // Gold glow
                                        ),
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
                                        fontSize: 6.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      member.memberClass,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF34D399),
                                      ),
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
                ),

                const SizedBox(height: 6),

                // High Contrast Scan Barcode Area at Bottom
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildBarcodeLines(),
                            const SizedBox(height: 1),
                            Text(
                              '* ${member.nis} *',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.black87,
                                fontFamily: 'monospace',
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Modern logo watermark sticker at bottom-right
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF047857),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeLines() {
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(42, (idx) {
          final isLine = idx % 2 == 0;
          if (!isLine) return const SizedBox(width: 2);
          final widths = [1.0, 1.2, 2.2, 3.0, 1.0, 1.8];
          final double hWidth = widths[idx % widths.length];
          return Container(
            width: hWidth,
            color: Colors.black,
          );
        }),
      ),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB45309).withOpacity(0.4)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Draw simulation lines for the microchip dividers
    canvas.drawLine(Offset(w * 0.33, 0), Offset(w * 0.33, h), paint);
    canvas.drawLine(Offset(w * 0.66, 0), Offset(w * 0.66, h), paint);
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), paint);

    // Inner small center square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.25, h * 0.25, w * 0.75, h * 0.75),
        const Radius.circular(1.5),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
