import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/result.dart';

class PDFService {
  Future<void> generateResultCard(Result result) async {
    final pdf = pw.Document();

    final schoolLogo = await _loadSchoolLogo();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(schoolLogo),
              pw.SizedBox(height: 20),
              _buildStudentInfo(result),
              pw.SizedBox(height: 20),
              _buildSubjectsTable(result),
              pw.SizedBox(height: 20),
              _buildOverallPerformance(result),
              pw.SizedBox(height: 20),
              _buildRemarks(result),
              pw.SizedBox(height: 40),
              _buildSignatures(),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${result.studentName}_result.pdf',
    );
  }

  Future<pw.ImageProvider> _loadSchoolLogo() async {
    // Load and return school logo
    // Implementation depends on how you store the logo
    return pw.MemoryImage(
        (await rootBundle.load('assets/school_logo.png')).buffer.asUint8List());
  }

  pw.Widget _buildHeader(pw.ImageProvider logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(logo, width: 60, height: 60),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'School Name',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text('School Address'),
            pw.Text('Contact Information'),
          ],
        ),
        pw.SizedBox(width: 60),
      ],
    );
  }

  pw.Widget _buildStudentInfo(Result result) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      child: pw.Column(
        children: [
          _buildInfoRow('Student Name:', result.studentName),
          _buildInfoRow('Student ID:', result.studentId),
          _buildInfoRow('Class:', result.className),
          _buildInfoRow('Exam Type:', result.examType),
          _buildInfoRow('Semester:', result.semester),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Text(value),
      ],
    );
  }

  pw.Widget _buildSubjectsTable(Result result) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Subject'),
            _buildTableHeader('Marks Obtained'),
            _buildTableHeader('Total Marks'),
            _buildTableHeader('Percentage'),
            _buildTableHeader('Grade'),
            _buildTableHeader('Remarks'),
          ],
        ),
        ...result.subjects.map((subject) {
          final percentage = (subject.marksObtained / subject.totalMarks) * 100;
          return pw.TableRow(
            children: [
              _buildTableCell(subject.subject),
              _buildTableCell(subject.marksObtained.toString()),
              _buildTableCell(subject.totalMarks.toString()),
              _buildTableCell('${percentage.toStringAsFixed(1)}%'),
              _buildTableCell(subject.grade),
              _buildTableCell(subject.remarks),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text),
    );
  }

  pw.Widget _buildOverallPerformance(Result result) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildPerformanceBox(
              'Total Percentage', '${result.percentage.toStringAsFixed(1)}%'),
          _buildPerformanceBox('Overall Grade', result.overallGrade),
          _buildPerformanceBox('Rank', result.rank.toString()),
        ],
      ),
    );
  }

  pw.Widget _buildPerformanceBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  pw.Widget _buildRemarks(Result result) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Remarks:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(_generateRemarks(result)),
        ],
      ),
    );
  }

  String _generateRemarks(Result result) {
    if (result.percentage >= 90) {
      return 'Outstanding performance! Keep up the excellent work.';
    } else if (result.percentage >= 80) {
      return 'Very good performance. Continue to maintain this standard.';
    } else if (result.percentage >= 70) {
      return 'Good performance with room for improvement.';
    } else if (result.percentage >= 60) {
      return 'Satisfactory performance. Need to work harder.';
    } else if (result.percentage >= 50) {
      return 'Pass. Significant improvement required.';
    } else {
      return 'Failed. Must seek additional help and guidance.';
    }
  }

  pw.Widget _buildSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildSignatureLine('Class Teacher'),
        _buildSignatureLine('Principal'),
        _buildSignatureLine('Parent'),
      ],
    );
  }

  pw.Widget _buildSignatureLine(String title) {
    return pw.Column(
      children: [
        pw.Container(
          width: 150,
          height: 1,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 5),
        pw.Text(title),
      ],
    );
  }
}
