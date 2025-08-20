import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ins_application/Plan.dart';
import 'package:ins_application/user_data.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

Future<pw.Font> _loadFont(String path) async {
final fontData = await rootBundle.load(path);
return pw.Font.ttf(fontData);
}

Future<Uint8List> generateInsurancePdfWeb({
  required int startAge,
  required String gender,
  required InsurancePlan plan,
  required String insuranceCode,
  required double insuredAmount,
  required double calculatedPremium,
  required List<double> dataValues,
  required List<double> surrenderValues,
  //required String selectedTaxPercent,
  required String insuranceType,
  required List<double> accumulatedPremiums,
  //required String gender, required String insuranceCode,
}) async {
  final font = await _loadFont('assets/fonts/Sarabun-Regular.ttf');
  final pdf = pw.Document();

  int currentYear = 1;
  int currentAge = startAge;
  
  currentAge++;

  final headers = [
    'สิ้นปีกธ.',
    'อายุ',
    'เบี้ยประกัน',
    'ภาษี',
    'เงินคืน',
    'เบี้ยสะสม',
    'มูลค่าเวนคืน',
    'ความคุ้มครอง',
  ];

  final tableRows = <pw.TableRow>[
    // แถวแรก: Header
    pw.TableRow(
      children: headers.map((header) {
        return pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(4),
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          child: pw.Text(header,
              style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
        );
      }).toList(),
    ),
  ];
  int endAge = plan.endage;
  int untilyear = plan.untilyear;
  final formatter = NumberFormat('#,##0'); // แสดงเลขเต็มพร้อม comma
  final double? premium = UserData().Amount;

  while (currentAge <= endAge) {
    //String premiumText = currentAge <= untilyear ? calculatedPremium.toStringAsFixed(0) : '';
    String refundValue =
        currentYear <= dataValues.length ? dataValues[currentYear - 1].toStringAsFixed(0) : '';
    String accumulatedValue =
        currentYear <= accumulatedPremiums.length ? accumulatedPremiums[currentYear - 1].toStringAsFixed(0) : '';
    String surrenderValue =
        currentYear <= surrenderValues.length ? surrenderValues[currentYear - 1].toStringAsFixed(0) : '';
    

    tableRows.add(
      pw.TableRow(
        children: [
          pw.Text('$currentYear', style: pw.TextStyle(font: font)),
          pw.Text('$currentAge', style: pw.TextStyle(font: font)),
          pw.Container(
            alignment: pw.Alignment.centerLeft, // ชิดซ้าย
            child: pw.Text(
              calculatedPremium != null ? formatter.format(calculatedPremium) : '',
              style: pw.TextStyle(font: font),
            ),
          ),
          pw.Text('', style: pw.TextStyle(font: font)),
          pw.Text('', style: pw.TextStyle(font: font)), //เงินคืน
          pw.Container(
            alignment: pw.Alignment.centerRight, // ชิดซ้าย
            child: pw.Text(
              accumulatedValue.isNotEmpty ? formatter.format(double.parse(accumulatedValue)) : '',
              style: pw.TextStyle(font: font),
            ),
          ),
          pw.Container(
            alignment: pw.Alignment.centerRight, // ชิดซ้าย
            child: pw.Text(
              surrenderValue.isNotEmpty ? formatter.format(double.parse(surrenderValue)) : '',
              style: pw.TextStyle(font: font),
            ),
          ),
          pw.Container(
            alignment: pw.Alignment.centerRight, // ชิดซ้าย
            child: pw.Text(
              premium != null ? formatter.format(premium) : '',
              style: pw.TextStyle(font: font),
            ),
          ),
        ].map((e) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(4),
          child: e,
        )).toList(),
      ),
    );
    currentYear++;
    currentAge++;
  }

  tableRows.add(
    pw.TableRow(
      children: List.generate(
        headers.length,
        (index) => pw.Container(
          height: 20, 
          child: pw.Text(''),
        ),
      ).toList(),
    ),
  );


  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:[
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FixedColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'ประเภทประกัน: $insuranceCode',
                          style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      for (int i = 1; i < 8; i++) pw.SizedBox(),
                    ],
                  ),
                  // แถวที่ 2: ข้อมูลเพศและอายุเริ่มต้น
                  pw.TableRow(
                    children: [
                        pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'เพศ: $gender, '
                          'อายุ: $startAge,'
                          'ทุนประกัน: ${UserData().Amount != null ? formatter.format(UserData().Amount) : '-'}, '
                          'เงินออมรวม: ${UserData().accumulatedPremiums.isNotEmpty ? formatter.format(UserData().accumulatedPremiums.last) : '-'}',
                          style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      for (int i = 1; i < 8; i++) pw.SizedBox(),
                    ],
                  ),
                ]
              )
            ],
          ),
          
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(1), // สิ้นปีกธ.
              1: const pw.FlexColumnWidth(1), // อายุ
              2: const pw.FlexColumnWidth(2), // เบี้ยประกัน
              3: const pw.FlexColumnWidth(2), // เงินคืน ภาษี
              4: const pw.FlexColumnWidth(2), // เบี้ยสะสม
              5: const pw.FlexColumnWidth(2), // มูลค่าเวนคืน
              6: const pw.FlexColumnWidth(2),
            },
            children: tableRows,
          ),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:[
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FixedColumnWidth(5),
                  1: pw.FixedColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'รวมรับผลประโยชน์ตลอดสัญญา',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  // แถวที่ 2: ข้อมูลเพศและอายุเริ่มต้น
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'ผลประโยชน์ด้านภาษี',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'รับคืนผลประโยชน์มากกว่าเบี้ยที่ส่ง (ไม่รวมภาษี)',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'อัตราผลตอบแทน',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ]
              )
            ],
          ),
        ];
      },
    ),
  );
  return pdf.save();
}