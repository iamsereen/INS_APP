/*String generateInsuranceHtml({
  required int startAge,
  required String selectedTaxPercent,
}) {
  int currentYear = 1;
  int currentAge = startAge;

  final rows = StringBuffer();

  while (currentAge <= 90) {
    rows.writeln('''
      <tr>
        <td>$currentYear</td>
        <td>$currentAge</td>
        <td></td>
        <td>$selectedTaxPercent%</td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    ''');
    currentYear++;
    currentAge++;
  }

  return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <style>
      body {
        font-family: Arial, sans-serif;
        font-size: 12px;
        padding: 16px;
      }
      h2 {
        text-align: center;
      }
      table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
      }
      th, td {
        border: 1px solid #333;
        padding: 8px;
        text-align: center;
      }
      th {
        background-color: #f2f2f2;
      }
    </style>
  </head>
  <body>
    <h2>ตารางข้อมูลประกันชีวิต</h2>
    <table>
      <thead>
        <tr>
          <th>สิ้นปีที่</th>
          <th>อายุ</th>
          <th>เบี้ยประกัน</th>
          <th>ภาษี</th>
          <th>เงินคืน</th>
          <th>เบี้ยสะสม</th>
          <th>มูลค่าเวนคืน</th>
          <th>ความคุ้มครอง</th>
        </tr>
      </thead>
      <tbody>
        ${rows.toString()}
      </tbody>
    </table>
  </body>
</html>
''';
}*/

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

Future<pw.Font> _loadFont(String path) async {
  final fontData = await rootBundle.load(path);
  return pw.Font.ttf(fontData);
}

Future<Uint8List> generateInsurancePdfWeb({
  required int startAge,
  required String selectedTaxPercent,
}) async {
  final font = await _loadFont('assets/fonts/Sarabun-Regular.ttf');
  final pdf = pw.Document();
  int currentYear = 1;
  int currentAge = startAge;

  final headers = [
    'สิ้นปีที่',
    'อายุ',
    'เบี้ยประกัน',
    'ภาษี',
    'เงินคืน',
    'เบี้ยสะสม',
    'มูลค่าเวนคืน',
    'ความคุ้มครอง',
  ];

  final data = <List<String>>[];

  while (currentAge <= 90) {
    data.add([
      '$currentYear',
      '$currentAge',
      '',
      '$selectedTaxPercent%',
      '',
      '',
      '',
      '',
    ]);
    currentYear++;
    currentAge++;
  }

   pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.DefaultTextStyle(
          style: pw.TextStyle(font: font, fontSize: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ตารางข้อมูลประกันชีวิต',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
                headerStyle: pw.TextStyle(font: font),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.center,
                border: pw.TableBorder.all(),
                cellPadding: const pw.EdgeInsets.all(4),
              ),
            ],
          ),
        );
      },
    ),
  );
  return pdf.save();
}


