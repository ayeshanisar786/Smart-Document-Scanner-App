import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class PdfService {
  // Create PDF from single image
  Future<File> createPdfFromImage(File imageFile, String documentId) async {
    final pdf = pw.Document();

    // Read image
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Convert to PDF image
    final pdfImage = pw.MemoryImage(imageBytes);

    // Add page with image
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    // Save PDF
    final tempDir = await getTemporaryDirectory();
    final pdfFile = File('${tempDir.path}/$documentId.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile;
  }

  // Create PDF from multiple images
  Future<File> createPdfFromImages(
    List<File> imageFiles,
    String documentId,
  ) async {
    final pdf = pw.Document();

    for (final imageFile in imageFiles) {
      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    final tempDir = await getTemporaryDirectory();
    final pdfFile = File('${tempDir.path}/$documentId.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile;
  }

  // Create PDF with text overlay (for OCR text)
  Future<File> createPdfWithText(
    File imageFile,
    String documentId, {
    String? ocrText,
  }) async {
    final pdf = pw.Document();
    final imageBytes = await imageFile.readAsBytes();
    final pdfImage = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Stack(
            children: [
              pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              ),
              if (ocrText != null && ocrText.isNotEmpty)
                pw.Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Text(
                      ocrText,
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final pdfFile = File('${tempDir.path}/$documentId.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile;
  }

  // Get PDF page count
  Future<int> getPageCount(File pdfFile) async {
    // This is a simplified version
    // In a real app, you'd use a PDF parsing library
    return 1;
  }

  // Get PDF file size
  Future<int> getFileSize(File pdfFile) async {
    return await pdfFile.length();
  }
}
