import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/result.dart';

class ExcelService {
  Future<List<Result>> importFromExcel() async {
    final results = <Result>[];

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        final bytes = result.files.first.bytes!;
        final excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          final sheet = excel.tables[table]!;

          // Skip header row
          for (var row = 1; row < sheet.maxRows; row++) {
            try {
              final studentName = sheet
                  .cell(
                      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
                  .value
                  .toString();
              final studentId = sheet
                  .cell(
                      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
                  .value
                  .toString();
              final className = sheet
                  .cell(
                      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
                  .value
                  .toString();
              final examType = sheet
                  .cell(
                      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
                  .value
                  .toString();
              final semester = sheet
                  .cell(
                      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
                  .value
                  .toString();

              final subjects = <SubjectResult>[];
              var currentColumn = 5;

              // Read subject results (assuming 5 subjects)
              for (var i = 0; i < 5; i++) {
                final subject = sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: currentColumn, rowIndex: row))
                    .value
                    .toString();
                final marks = int.parse(sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: currentColumn + 1, rowIndex: row))
                    .value
                    .toString());
                final total = int.parse(sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: currentColumn + 2, rowIndex: row))
                    .value
                    .toString());
                final remarks = sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: currentColumn + 3, rowIndex: row))
                    .value
                    .toString();

                final percentage = (marks / total) * 100;
                final grade = _calculateGrade(percentage);

                subjects.add(SubjectResult(
                  subject: subject,
                  marksObtained: marks,
                  totalMarks: total,
                  grade: grade,
                  remarks: remarks,
                ));

                currentColumn += 4;
              }

              // Calculate overall percentage
              final totalObtained = subjects.fold<int>(
                  0, (sum, subject) => sum + subject.marksObtained);
              final totalMarks = subjects.fold<int>(
                  0, (sum, subject) => sum + subject.totalMarks);
              final percentage = (totalObtained / totalMarks) * 100;

              results.add(Result(
                studentId: studentId,
                studentName: studentName,
                className: className,
                examType: examType,
                semester: semester,
                subjects: subjects,
                percentage: percentage,
                overallGrade: _calculateGrade(percentage),
                rank: 0, // Will be calculated later
                examDate: DateTime.now(),
                declaredDate: DateTime.now(),
              ));
            } catch (e) {
              print('Error processing row $row: $e');
              continue;
            }
          }
        }
      }
    } catch (e) {
      print('Error importing Excel: $e');
      rethrow;
    }

    return results;
  }

  Future<void> exportToExcel(List<Result> results) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Results'];

      // Add headers
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Student Name' as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Student ID' as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Class' as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Exam Type' as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'Semester' as CellValue?;

      var currentColumn = 5;
      for (var i = 0; i < 5; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: currentColumn, rowIndex: 0))
            .value = 'Subject ${i + 1}' as CellValue?;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: currentColumn + 1, rowIndex: 0))
            .value = 'Marks' as CellValue?;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: currentColumn + 2, rowIndex: 0))
            .value = 'Total' as CellValue?;
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: currentColumn + 3, rowIndex: 0))
            .value = 'Remarks' as CellValue?;
        currentColumn += 4;
      }

      // Add data
      for (var row = 0; row < results.length; row++) {
        final result = results[row];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 1))
            .value = result.studentName as CellValue?;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row + 1))
            .value = result.studentId as CellValue?;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row + 1))
            .value = result.className as CellValue?;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row + 1))
            .value = result.examType as CellValue?;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row + 1))
            .value = result.semester as CellValue?;

        currentColumn = 5;
        for (var subject in result.subjects) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: currentColumn, rowIndex: row + 1))
              .value = subject.subject as CellValue?;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: currentColumn + 1, rowIndex: row + 1))
              .value = subject.marksObtained as CellValue?;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: currentColumn + 2, rowIndex: row + 1))
              .value = subject.totalMarks as CellValue?;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: currentColumn + 3, rowIndex: row + 1))
              .value = subject.remarks as CellValue?;
          currentColumn += 4;
        }
      }

      final bytes = excel.save();
      if (bytes != null) {
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Results',
          fileName: 'results.xlsx',
        );

        if (path != null) {
          // Save the file
          // Implementation depends on platform
        }
      }
    } catch (e) {
      print('Error exporting Excel: $e');
      rethrow;
    }
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    return 'F';
  }
}
