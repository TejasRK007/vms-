import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PDFService {
  /// Generate a user ID card PDF with QR code
  static Future<Uint8List> generateUserIdCard({
    required String userId,
    required String name,
    required String email,
    required String role,
    String? department,
    String? photoUrl,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  'VISITOR MANAGEMENT SYSTEM',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'USER ID CARD',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),

                // User Photo (placeholder)
                pw.Center(
                  child: pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                      borderRadius: pw.BorderRadius.circular(40),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: pw.TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 15),

                // User Details
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Name', name),
                        _buildDetailRow('Email', email),
                        _buildDetailRow('Role', role.toUpperCase()),
                        if (department != null && department.isNotEmpty)
                          _buildDetailRow('Department', department),
                        _buildDetailRow('User ID', userId),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // QR Code
                pw.Text(
                  'SCAN QR CODE FOR DETAILS',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: userId,
                    width: 100,
                    height: 100,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  userId.substring(0, 8).toUpperCase(),
                  style: pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),

                // Footer
                pw.Text(
                  'Generated on ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generate a visitor ID card PDF with QR code and photo
  static Future<Uint8List> generateVisitorIdCard({
    required String visitorId,
    required String name,
    required String contact,
    required String email,
    required String purpose,
    required String hostName,
    String? photoUrl,
    String? qrCode,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  'VISITOR MANAGEMENT SYSTEM',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'VISITOR ID CARD',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),

                // Visitor Photo
                pw.Center(
                  child: pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                      borderRadius: pw.BorderRadius.circular(40),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'V',
                        style: pw.TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 15),

                // Visitor Details
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Name', name),
                        _buildDetailRow('Contact', contact),
                        _buildDetailRow('Email', email),
                        _buildDetailRow('Purpose', purpose),
                        _buildDetailRow('Host', hostName),
                        _buildDetailRow('Visitor ID', visitorId),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // QR Code
                pw.Text(
                  'SCAN QR CODE FOR ENTRY',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrCode ?? visitorId,
                    width: 100,
                    height: 100,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  (qrCode ?? visitorId).substring(0, 8).toUpperCase(),
                  style: pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),

                // Footer
                pw.Text(
                  'Generated on ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Helper method to build detail rows
  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Save PDF to file
  static Future<String> savePdfToFile(
      Uint8List pdfData, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(pdfData);
    return file.path;
  }
}
