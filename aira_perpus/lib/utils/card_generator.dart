import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/member.dart';
import 'file_saver.dart';

class CardGenerator {
  /// Generates a grid of student library cards in an elegant A4 PDF format and triggers a download
  static Future<void> downloadPDF(
      List<Member> members, String schoolName, String appName) async {
    final pdf = pw.Document();

    // Group members by 6 per page (3 rows, 2 columns)
    final int cardsPerPage = 6;
    for (int pageIndex = 0;
        pageIndex < (members.length / cardsPerPage).ceil();
        pageIndex++) {
      final int start = pageIndex * cardsPerPage;
      final int end = (start + cardsPerPage < members.length)
          ? start + cardsPerPage
          : members.length;
      final List<Member> pageMembers = members.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'DAFTAR KARTU ANGGOTA PERPUSTAKAAN - HALAMAN ${pageIndex + 1}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        schoolName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF1E8A5F),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Expanded(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: _buildPageRows(pageMembers, schoolName, appName),
                  ),
                ),
                pw.Footer(
                  title: pw.Text(
                    'Dicetak secara otomatis dari $appName pada ${DateTime.now().toIso8601String().split('T')[0]}',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey500),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final bytes = await pdf.save();
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final sanitizedSchool =
        schoolName.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(' ', '_');
    final filename = "Kartu_Anggota_Perpus_${sanitizedSchool}_$dateStr.pdf";
    await FileSaverUtils.saveAndDownload(filename, bytes);
  }

  /// Builds the 3 rows of 2 cards each for the PDF page
  static List<pw.Widget> _buildPageRows(
      List<Member> pageMembers, String schoolName, String appName) {
    final List<pw.Widget> rows = [];

    for (int i = 0; i < pageMembers.length; i += 2) {
      final Member left = pageMembers[i];
      final Member? right =
          (i + 1 < pageMembers.length) ? pageMembers[i + 1] : null;

      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 15),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(child: _buildCardWidget(left, schoolName, appName)),
              pw.SizedBox(width: 15),
              pw.Expanded(
                child: right != null
                    ? _buildCardWidget(right, schoolName, appName)
                    : pw.Container(),
              ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  /// Single Library Card PDF widget matching the premium APK design
  static pw.Widget _buildCardWidget(
      Member student, String schoolName, String appName) {
    return pw.Container(
      height: 180,
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(15)),
        color: PdfColor.fromInt(0xFF1E8A5F), // Vibrant green matching APK theme
        border: pw.Border.all(
          color:
              PdfColor(251 / 255, 191 / 255, 36 / 255, 0.4), // Soft Gold border
          width: 2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Header Row
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, right: 10, top: 10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // School mini shield icon
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  decoration: pw.BoxDecoration(
                    color: PdfColor(1, 1, 1, 0.15),
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(
                        color: PdfColor.fromInt(0xFFEAB308), width: 0.8),
                  ),
                  child: pw.Container(
                    width: 10,
                    height: 10,
                    alignment: pw.Alignment.center,
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFFBBF24), // Gold dot
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'KARTU PINTAR PERPUSTAKAAN DIGITAL',
                        style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF34D399), // Emerald Accent
                          letterSpacing: 0.5,
                        ),
                      ),
                      pw.Text(
                        schoolName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                // SMART ACCESS Badge
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1.5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor(234 / 255, 179 / 255, 8 / 255, 0.2),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(
                        color: PdfColor.fromInt(0xFFFBBF24), width: 0.6),
                  ),
                  child: pw.Text(
                    'SMART ACCESS',
                    style: pw.TextStyle(
                      fontSize: 5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFFFBBF24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 4),
          // Gradient divider-like gold line
          pw.Container(
            height: 1,
            margin: const pw.EdgeInsets.symmetric(horizontal: 10),
            color: PdfColor(251 / 255, 191 / 255, 36 / 255, 0.3),
          ),
          pw.SizedBox(height: 6),

          // Card Body: Photo + Smart Chip + Student Details
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Photo & RFID Chip Column
                  pw.Column(
                    children: [
                      // Photo box with glowing gold frame
                      pw.Container(
                        width: 46,
                        height: 56,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFF0F172A),
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(6)),
                          border: pw.Border.all(
                              color: PdfColor.fromInt(0xFFFBBF24), width: 1.5),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'FOTO\n2x3',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 6,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF34D399),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      // Gold Smart Chip simulator
                      pw.Container(
                        width: 22,
                        height: 14,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFFBBF24),
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(2)),
                          border: pw.Border.all(
                              color: PdfColor.fromInt(0xFFD97706), width: 0.5),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          children: [
                            pw.Container(
                                height: 0.5,
                                color: PdfColor.fromInt(0xFFD97706)),
                            pw.Container(
                                height: 0.5,
                                color: PdfColor.fromInt(0xFFD97706)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 10),

                  // Member details column
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'NAMA LENGKAP ANGGOTA',
                          style: pw.TextStyle(
                            fontSize: 5.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(
                                0xFF94A3B8), // Muted label grey
                          ),
                        ),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          student.name.toUpperCase(),
                          maxLines: 1,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'ID BARCODE / NIS',
                                    style: pw.TextStyle(
                                      fontSize: 5.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromInt(0xFF94A3B8),
                                    ),
                                  ),
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    student.nis,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromInt(
                                          0xFFFBBF24), // Gold text
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'KELAS',
                                  style: pw.TextStyle(
                                    fontSize: 5.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromInt(0xFF94A3B8),
                                  ),
                                ),
                                pw.SizedBox(height: 1),
                                pw.Text(
                                  student.memberClass,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromInt(
                                        0xFF34D399), // Emerald class
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Diterbit oleh $appName',
                          style: pw.TextStyle(
                            fontSize: 6,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColor.fromInt(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Scan barcode white area
          pw.Container(
            margin: const pw.EdgeInsets.only(left: 10, right: 10, bottom: 8),
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: const pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      // Simulated barcodes using code128
                      pw.Container(
                        height: 20,
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.code128(),
                          data: student.nis,
                          drawText: false,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        '* ${student.nis} *',
                        style: pw.TextStyle(
                          fontSize: 7,
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 6),
                // Green Watermark sticker log
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF047857),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Container(
                    width: 6,
                    height: 6,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Generates a fully styled MS Word compatible Microsoft Word layout and triggers HTML-wrapped .doc download
  static Future<void> downloadWord(
      List<Member> members, String schoolName, String appName) async {
    final buffer = StringBuffer();

    // MS Word Header tags specifying portrait print view & borders
    buffer.write(
        '''<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40">
<head>
<meta charset="utf-8">
<title>Template Kartu Anggota Perpustakaan</title>
<!--[if gte mso 9]>
<xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>100</w:Zoom>
  <w:DoNotOptimizeForBrowser/>
 </w:WordDocument>
</xml>
<![endif]-->
<style>
  @page {
    size: 21.0cm 29.7cm; /* A4 size */
    margin: 1.5cm 1.5cm 1.5cm 1.5cm;
  }
  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    color: #ffffff;
    background-color: #f3f4f6;
  }
  h1 {
    font-size: 16pt;
    font-weight: bold;
    color: #022C22;
    text-align: center;
    margin-bottom: 20px;
    border-bottom: 2.5px solid #EAB308;
    padding-bottom: 5px;
  }
  table.card-grid {
    width: 100%;
    border-collapse: collapse;
  }
  td.card-cell {
    width: 48%;
    border: 2px solid rgba(251, 191, 36, 0.5); /* Gold border matching APK */
    padding: 14px;
    vertical-align: top;
    background-color: #1e8a5f; /* Vibrant green matching APK theme */
    border-radius: 15px;
    -webkit-border-radius: 15px;
  }
  td.spacer-col {
    width: 4%;
  }
  tr.spacer-row td {
    height: 18px;
    font-size: 1px;
    line-height: 1px;
  }
  .card-header-table {
    width: 100%;
    margin-bottom: 8px;
    border-bottom: 1px solid rgba(251, 191, 36, 0.3);
    padding-bottom: 6px;
  }
  .card-header-sub {
    font-size: 7.0pt;
    font-weight: 900;
    color: #34D399; /* Emerald Accent */
    letter-spacing: 0.8px;
    text-transform: uppercase;
  }
  .card-header-main {
    font-size: 10.5pt;
    font-weight: bold;
    color: #ffffff;
    margin-top: 1px;
    text-transform: uppercase;
  }
  .smart-access-badge {
    background-color: rgba(234, 179, 8, 0.2);
    border: 0.8px solid #FBBF24;
    color: #FBBF24;
    font-size: 5.5pt;
    font-weight: bold;
    padding: 2px 4px;
    border-radius: 6px;
    text-align: center;
    white-space: nowrap;
  }
  .info-label {
    font-size: 6.5pt;
    color: #94A3B8; /* Muted grey */
    text-transform: uppercase;
    font-weight: bold;
    margin-top: 4px;
    letter-spacing: 0.3px;
  }
  .info-value-name {
    font-size: 11.5pt;
    font-weight: 900;
    color: #ffffff;
  }
  .info-value-id {
    font-size: 9.5pt;
    font-weight: bold;
    color: #FBBF24; /* Gold */
    font-family: monospace;
  }
  .info-value-class {
    font-size: 9.5pt;
    font-weight: bold;
    color: #34D399; /* Emerald */
  }
  .photo-box {
    border: 1.5px solid #FBBF24; /* Gold Frame */
    width: 58px;
    height: 70px;
    text-align: center;
    vertical-align: middle;
    font-size: 6.5pt;
    color: #34D399;
    font-weight: bold;
    background-color: #0F172A;
    border-radius: 6px;
  }
  .chip-box {
    background-color: #FBBF24;
    border: 0.5px solid #D97706;
    width: 24px;
    height: 15px;
    margin: 4px auto 0 auto;
    border-radius: 2px;
  }
  .barcode-area {
    background-color: #ffffff;
    border-radius: 8px;
    padding: 4px;
    margin-top: 8px;
    text-align: center;
  }
  .barcode-sim {
    font-family: 'Courier New', Courier, monospace;
    font-size: 11pt;
    letter-spacing: 2px;
    font-weight: bold;
    color: #000000;
    line-height: 14px;
  }
  .barcode-text {
    font-size: 7.5pt;
    text-align: center;
    color: #000000;
    font-family: monospace;
    font-weight: bold;
    letter-spacing: 1.5px;
  }
  .card-footer {
    font-size: 6.5pt;
    font-style: italic;
    color: #94A3B8;
    margin-top: 5px;
  }
</style>
</head>
<body>
''');

    buffer.write(
        '<h1>CETAK TEMPLATE KARTU PERPUSTAKAAN - ${schoolName.toUpperCase()}</h1>');
    buffer.write('<table class="card-grid">');

    // Load elements systematically into groups of two columns
    for (int i = 0; i < members.length; i += 2) {
      final Member left = members[i];
      final Member? right = (i + 1 < members.length) ? members[i + 1] : null;

      buffer.write('<tr>');
      // Left Card
      buffer.write('<td class="card-cell">');
      _writeSingleCardHtml(buffer, left, schoolName, appName);
      buffer.write('</td>');

      // Spacer Column
      buffer.write('<td class="spacer-col"></td>');

      // Right Card
      buffer.write('<td class="card-cell">');
      if (right != null) {
        _writeSingleCardHtml(buffer, right, schoolName, appName);
      } else {
        buffer.write('&nbsp;');
      }
      buffer.write('</td>');
      buffer.write('</tr>');

      // Spacer Row
      buffer.write('<tr class="spacer-row"><td colspan="3">&nbsp;</td></tr>');
    }

    buffer.write('</table>');
    buffer.write('</body></html>');

    final bytes = utf8.encode(buffer.toString());
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final sanitizedSchool =
        schoolName.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(' ', '_');
    final filename = "Template_Kartu_Siswa_${sanitizedSchool}_$dateStr.doc";
    await FileSaverUtils.saveAndDownload(filename, bytes);
  }

  static void _writeSingleCardHtml(
      StringBuffer buffer, Member student, String schoolName, String appName) {
    buffer.write('''
<table class="card-header-table" style="border:0; width:100%;">
  <tr>
    <td style="vertical-align:top; border:0; padding:0; background:none;">
      <div class="card-header-sub">KARTU PINTAR PERPUSTAKAAN DIGITAL</div>
      <div class="card-header-main">${schoolName.toUpperCase()}</div>
    </td>
    <td style="vertical-align:top; text-align:right; width:90px; border:0; padding:0; background:none;">
      <span class="smart-access-badge">SMART ACCESS</span>
    </td>
  </tr>
</table>

<table style="width:100%; border:0;">
  <tr>
    <td style="width:70%; vertical-align:top; border:0; padding:0; background:none;">
      <div class="info-label">NAMA LENGKAP ANGGOTA</div>
      <div class="info-value-name">${student.name.toUpperCase()}</div>
      
      <table style="width:100%; border:0; margin-top:4px;">
        <tr>
          <td style="width:60%; border:0; padding:0; background:none; vertical-align:top;">
            <div class="info-label">ID BARCODE / NIS</div>
            <div class="info-value-id">${student.nis}</div>
          </td>
          <td style="border:0; padding:0; background:none; vertical-align:top;">
            <div class="info-label">KELAS</div>
            <div class="info-value-class">${student.memberClass}</div>
          </td>
        </tr>
      </table>
      
      <div class="card-footer">Diterbitkan oleh $appName</div>
    </td>
    <td style="width:30%; vertical-align:top; text-align:center; border:0; padding:0; background:none;">
      <table style="margin:0 auto; border:0; padding:0; background:none;">
        <tr>
          <td class="photo-box" style="background-color:#0F172A; text-align:center;">
            FOTO<br>2X3
          </td>
        </tr>
      </table>
      <div class="chip-box"></div>
    </td>
  </tr>
</table>

<div class="barcode-area">
  <div class="barcode-sim">|||||||||||||||||||||||||||||||||||</div>
  <div class="barcode-text">* ${student.nis} *</div>
</div>
''');
  }
}
