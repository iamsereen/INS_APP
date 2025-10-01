import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ins_application/Plan.dart';
import 'TableCX1020.dart';
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
  final ttfBold = await _loadFont('assets/fonts/Sarabun-Bold.ttf');
  final pdf = pw.Document();
  final summary = calculateSummaryTable(plan: plan, userData: UserData());


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
          height: 1.6 * PdfPageFormat.cm,
          alignment: pw.Alignment.center,
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(header,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 10)),
        );
      }).toList(),
    ),
  ];
  int endAge = plan.endage;
  int untilyear = plan.untilyear;
  final formatter = NumberFormat('#,##0'); // แสดงเลขเต็มพร้อม comma
  final double? premium = UserData().Amount;

  while (currentAge <= endAge) {
    // ในลูป while
    final bool hasPremiumThisYear = currentYear <= untilyear;
    final String premiumText = hasPremiumThisYear
    ? formatter.format(calculatedPremium) 
    : '';
    String refundValue = '';
    if (currentAge == endAge) {
      // แถวสุดท้ายแสดงค่า summary.totalReceived
      refundValue = formatter.format(summary.totalReceived);
    }
    String accumulatedValue =
        currentYear <= accumulatedPremiums.length ? accumulatedPremiums[currentYear - 1].toStringAsFixed(0) : '';
    String surrenderValue =
        currentYear <= surrenderValues.length ? surrenderValues[currentYear - 1].toStringAsFixed(0) : '';
    

    tableRows.add(
      pw.TableRow(
        children: [
          pw.Text('$currentYear', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font, fontSize: 8,)),
          pw.Text('$currentAge', style: pw.TextStyle(font: font, fontSize: 8,)),
          pw.Container(
            alignment: pw.Alignment.centerRight, // ชิดซ้าย
            child: pw.Text(premiumText, style: pw.TextStyle(font: font, fontSize: 8)
            ),
          ),
          pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font, fontSize: 8,)),
          pw.Container(
            alignment: pw.Alignment.centerRight, // ชิดซ้าย
            child: pw.Text(refundValue, style: pw.TextStyle(font: ttfBold, fontSize: 8)
            ),
          ),
          pw.Container(
            alignment: pw.Alignment.centerRight, // ชิดซ้าย
            child: pw.Text(
              accumulatedValue.isNotEmpty ? formatter.format(double.parse(accumulatedValue)) : '',
              textAlign: pw.TextAlign.center, 
              style: pw.TextStyle(font: font, fontSize: 8,),
            ),
          ),
          pw.Container(
            alignment: pw.Alignment.centerRight, // ชิดซ้าย
            child: pw.Text(
              surrenderValue.isNotEmpty ? formatter.format(double.parse(surrenderValue)) : '',
              textAlign: pw.TextAlign.center, 
              style: pw.TextStyle(font: font, fontSize: 8,),
            ),
          ),
          pw.Container(
            alignment: pw.Alignment.centerRight, // ชิดซ้าย
            child: pw.Text(
              premium != null ? formatter.format(premium) : '',
              textAlign: pw.TextAlign.center, 
              style: pw.TextStyle(font: font, fontSize: 8,),
            ),
          ),
        ].map((e) => pw.Container(
          height: 0.5 * PdfPageFormat.cm,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(right: 4),
          child: e,
        )).toList(),
      ),
    );
    currentYear++;
    currentAge++;
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
      marginLeft: 1 * PdfPageFormat.cm,
      marginRight: 0.8 * PdfPageFormat.cm,
      marginTop: 0.5 * PdfPageFormat.cm,
      marginBottom: 3 * PdfPageFormat.cm,
    ),
      build: (pw.Context context) {
        return [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:[
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FixedColumnWidth(1)
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        height: 0.8 * PdfPageFormat.cm,
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          insuranceCode,
                          style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      //for (int i = 1; i < 8; i++) pw.SizedBox(),
                    ],
                  ),
                  // แถวที่ 2: ข้อมูลเพศและอายุเริ่มต้น
                  pw.TableRow(
                  children: [
                    pw.Container(
                      height: 0.8 * PdfPageFormat.cm,
                      alignment: pw.Alignment.centerLeft,
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Row(
                        children: [ // ✅ เว้นระยะห่าง
                        pw.SizedBox(width: 25),
                          pw.Text(
                            gender == 'male' ? 'ชาย' : gender == 'female' ? 'หญิง' : '-',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(width: 35),
                          pw.Text(
                            startAge.toString(),
                            style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(width: 40),
                          pw.Text(
                            'ทุนประกัน',
                            style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Text(
                            UserData().Amount != null 
                                ? formatter.format(UserData().Amount) 
                                : '-',
                            style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Text(
                            'บาท',
                            style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(width: 30),
                          pw.Text(
                            'เงินออมรวม',
                            style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Text(
                            UserData().accumulatedPremiums.isNotEmpty 
                                ? formatter.format(UserData().accumulatedPremiums.last) 
                                : '-',
                            style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Text(
                            'บาท',
                            style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
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
                  0: pw.FixedColumnWidth(1 * PdfPageFormat.cm),
                  1: pw.FixedColumnWidth(1 * PdfPageFormat.cm),
                  2: pw.FixedColumnWidth(2.8 * PdfPageFormat.cm),
                  3: pw.FixedColumnWidth(2.6 * PdfPageFormat.cm),
                  4: pw.FixedColumnWidth(2.8 * PdfPageFormat.cm),
                  5: pw.FixedColumnWidth(3 * PdfPageFormat.cm),
                  6: pw.FixedColumnWidth(3 * PdfPageFormat.cm),
                  7: pw.FixedColumnWidth(3 * PdfPageFormat.cm),     
            },
            children: [
              ... tableRows,
              pw.TableRow(
              children: List.generate(
                8, // จำนวนคอลัมน์เท่ากับตาราง
                (index) {
                  if (index == 2) {
                    // ค่าสุดท้ายของ surrenderValues
                    final lastSurrender = surrenderValues.isNotEmpty
                        ? formatter.format(surrenderValues.last)
                        : '';
                    return pw.Container(
                      height: 0.5 * PdfPageFormat.cm,
                      padding: const pw.EdgeInsets.only(right: 4),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        lastSurrender,
                        style: pw.TextStyle(font: ttfBold, fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                    );
                  } else if (index == 4) {
                    return pw.Container(
                    height: 0.5 * PdfPageFormat.cm,
                    alignment: pw.Alignment.centerRight,
                    padding: const pw.EdgeInsets.only(right: 4),
                    child: pw.Text(
                      formatter.format(summary.totalReceived),
                      style: pw.TextStyle(font: ttfBold, fontSize: 8, fontWeight: pw.FontWeight.bold),
                    ),
                  );
                  } else {
                    return pw.Container(
                      height: 0.5 * PdfPageFormat.cm,
                      child: pw.Text(''),
                    );
                  }
                }
              ),
            ),
            ]
          ),
          pw.SizedBox(height: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:[
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FixedColumnWidth(13.2 * PdfPageFormat.cm),
                  1: pw.FixedColumnWidth(6 * PdfPageFormat.cm),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'รวมรับผลประโยชน์ตลอดสัญญา',
                          style: pw.TextStyle(font: font, fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          formatter.format(summary.totalReceived),
                          style: pw.TextStyle(font: font, fontSize: 8),
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
                          style: pw.TextStyle(font: font, fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          summary.taxBenefit != null ? formatter.format(summary.taxBenefit!) : '-',
                          style: pw.TextStyle(font: font, fontSize: 8),
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
                          style: pw.TextStyle(font: font, fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          formatter.format(summary.moreThanPaid),
                          style: pw.TextStyle(font: font, fontSize: 8),
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
                          style: pw.TextStyle(font: font, fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '${summary.roi.toStringAsFixed(2)}%',
                          style: pw.TextStyle(font: font, fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                ]
              )
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: 
              pw.Text(
                "**เอกสารนี้เป็นเพียงเอกสารแสดงข้อมูลเบื้องต้น เกี่ยวกับแบบประกันภัยและลักษณะผลิตภัณฑ์ประกันภัยสำหรับใช้ในการอธิบาย\nแก่ผู้ที่สนใจผลิตภัณฑ์ของ Chubb life เท่านั้น",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
          ),
          pw.SizedBox(height: 10),
          if (insuranceCode == "CX10" || insuranceCode == "CX20")
          buildCriticalIllnessTables(
            font: font,
            ttfBold: ttfBold,
            criticalIllnessGroup1: criticalIllnessGroup1,
            criticalIllnessGroup2: criticalIllnessGroup2,
            criticalIllnessChild: criticalIllnessChild,
          ), 
          ];
      },
    ),
  );
  return pdf.save();
}


pw.Widget buildCriticalIllnessTables({
  required pw.Font font,
  required pw.Font ttfBold,
  required List<String> criticalIllnessGroup1,
  required List<String> criticalIllnessGroup2,
  required List<String> criticalIllnessChild,
}) {
  int maxRowsfor2 = 25;
  int maxRowsfor3 = 8;

  // ฟังก์ชันสร้างตาราง multi-column สำหรับกลุ่ม 2
  pw.Widget buildMultiColumnGroup2(List<String> items) {
    int totalItems = items.length;
    int totalColumns = (totalItems / maxRowsfor2).ceil();

    List<pw.TableRow> tableRows = [];

    // แถวหัวตาราง
    tableRows.add(
      pw.TableRow(
        children: [
          for (int c = 0; c < totalColumns; c++)
            if (c == 0)
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              alignment: pw.Alignment.center,
              child: pw.Text(
                "โรคร้ายแรงกลุ่มที่ 2 ที่ได้รับความคุ้มครองกรณีเจ็บป่วยด้วยโรคร้ายแรง ดังต่อไปนี้",
                style: pw.TextStyle(font: ttfBold, fontSize: 8),
              ),
            )
          else
            pw.Container(), 
        ],
      ),
    );

    // สร้างแถวข้อมูล
    for (int rowIndex = 0; rowIndex < maxRowsfor2; rowIndex++) {
      List<pw.Widget> rowCells = [];
      for (int colIndex = 0; colIndex < totalColumns; colIndex++) {
        int itemIndex = colIndex * maxRowsfor2 + rowIndex;
        if (itemIndex < totalItems) {
          rowCells.add(
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 28, top: 4, bottom: 4, right: 4),
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                '${itemIndex + 1}. ${items[itemIndex]}',
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
            ),
          );
        } else {
          rowCells.add(pw.Container()); // ว่างถ้าไม่มีข้อมูล
        }
      }
      tableRows.add(pw.TableRow(children: rowCells));
    }

    return pw.Table(
      columnWidths: Map.fromIterable(
        List.generate(totalColumns, (i) => i),
        value: (_) => const pw.FlexColumnWidth(),
      ),
      children: tableRows,
    );
  }

  pw.Widget buildMultiColumnChild(List<String> items) {
    int totalItems = items.length;
    int totalColumns = (totalItems / maxRowsfor3).ceil();

    List<pw.TableRow> tableRows = [];

    // แถวหัวตารางแสดงเฉพาะคอลัมน์แรก
    tableRows.add(
      pw.TableRow(
        children: [
          for (int c = 0; c < totalColumns; c++)
            if (c == 0)
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "โรคร้ายแรง 15 โรค สำหรับผู้เอาประกันภัยที่มีอายุต่ำกว่า 16 ปี",
                  style: pw.TextStyle(font: ttfBold, fontSize: 8),
                ),
              )
            else
              pw.Container(),
        ],
      ),
    );

    // สร้างแถวข้อมูล
    for (int rowIndex = 0; rowIndex < maxRowsfor3; rowIndex++) {
      List<pw.Widget> rowCells = [];
      for (int colIndex = 0; colIndex < totalColumns; colIndex++) {
        int itemIndex = colIndex * maxRowsfor3 + rowIndex;
        if (itemIndex < totalItems) {
          rowCells.add(
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 28, top: 4, bottom: 4, right: 4),
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                '${itemIndex + 1}. ${items[itemIndex]}',
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
            ),
          );
        } else {
          rowCells.add(pw.Container());
        }
      }
      tableRows.add(pw.TableRow(children: rowCells));
    }

    return pw.Table(
      columnWidths: Map.fromIterable(
        List.generate(totalColumns, (i) => i),
        value: (_) => const pw.FlexColumnWidth(),
      ),
      children: tableRows,
    );
  }


  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.white),
        columnWidths: {
          0: pw.FixedColumnWidth(4.8 * PdfPageFormat.cm),
          1: pw.FlexColumnWidth(),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColors.grey200,
                child: pw.Text('ความคุ้มครองโรคร้ายแรง\nสำหรับเด็ก 0-16',
                    style: pw.TextStyle(font: ttfBold, fontSize: 8)),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColor.fromInt(0xFF0582ca),
                child: pw.Text(
                  'กรณีผู้เอาประกันภัยอายุน้อยกว่า 16 ปี ตรวจพบโรคร้ายแรง 1 ใน 15 โรค รับผลประโยชน์ 100% \n(สูงสุด 1 ครั้ง ต่ออายุกรมธรรม์)',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.white,),
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),

      // ตารางการยกเว้นเบี้ย
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.white,),
        columnWidths: {
          0: pw.FixedColumnWidth(4.8 * PdfPageFormat.cm),
          1: pw.FlexColumnWidth(),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColors.grey200,
                child: pw.Text('การยกเว้นการชำระเบี้ยประกันภัย',
                    style: pw.TextStyle(font: ttfBold, fontSize: 8)),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColor.fromInt(0xFF0582ca),
                child: pw.Text(
                  'กรณีผู้เอาประกันภัยตรวจพบว่าเป็นโรคร้ายแรงกลุ่มที่ 2 เป็นครั้งแรก บริษัทจะยกเว้นการชำระเบี้ยประกันภัยของกรมธรรม์หลัก',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.white,),
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),

      // ตารางค่าใช้จ่ายการรักษา
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.white),
        columnWidths: {
          0: pw.FixedColumnWidth(4.8 * PdfPageFormat.cm),
          1: pw.FlexColumnWidth(),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColors.grey200,
                child: pw.Text('ค่าใช้จ่ายจากการรักษาพยาบาล\nและการฟื้นฟู',
                    style: pw.TextStyle(font: ttfBold, fontSize: 8)),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColor.fromInt(0xFF0582ca),
                child: pw.Text(
                  'กรณีผู้เอาประกันภัยได้รับผลประโยชน์คุ้มครองโรคร้ายแรงกลุ่มที่ 2 ไปแล้ว รับผลประโยชน์ต่อเนื่องค่ารักษาพยาบาลที่เกี่ยวข้องกับโรคร้ายแรง \nกลุ่มที่ 2 สูงสุด 10% ตลอดอายุกรมธรรม์',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.white,),
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      /// ตาราง ความคุ้มครองโรคร้ายแรงกลุ่ม 1 และ 2
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.white),
        columnWidths: {
          0: pw.FixedColumnWidth(4.8 * PdfPageFormat.cm),
          1: pw.FlexColumnWidth(),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColors.grey200,
                child: pw.Text('ความคุ้มครองโรคร้ายแรง',
                    style: pw.TextStyle(font: ttfBold, fontSize: 8)),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColor.fromInt(0xFF72ddf7),
                child: pw.Text(
                  'กรณีเจ็บป่วยด้วยโรคร้ายแรงกลุ่มที่ 1 ** รับผลประโยชน์ 25% ต่อครั้ง (สูงสุด 4 ครั้ง ตลอดอายุกรมธรรม์) \nกรณีเจ็บป่วยด้วยโรคร้ายแรงกลุ่มที่ 2 *** รับผลประโยชน์ 100% ต่อครั้ง (สูงสุด 1 ครั้ง ตลอดอายุกรมธรรม์)',
                  style: pw.TextStyle(font: font, fontSize: 8),
                ),
              ),
            ],
          )
        ],
      ),
      pw.SizedBox(height: 10),
      /// ตาราง ความคุ้มครองชีวิต
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.white),
        columnWidths: {
          0: pw.FixedColumnWidth(4.8 * PdfPageFormat.cm),
          1: pw.FlexColumnWidth(),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColors.grey200,
                child: pw.Text('ความคุ้มครองชีวิต',
                    style: pw.TextStyle(font: ttfBold, fontSize: 8)),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                color: PdfColor.fromInt(0xFF72ddf7),
                child: pw.Text(
                  'รับผลประโยชน์กรณีเสียชีวิต 105% หรือ เบี้ยประกันภัยสะสมในส่วนที่คุ้มครองชีวิตที่บริษัทได้ชำระจริง\n แล้วแต่จำนวนใดจะมากกว่า หักด้วยผลประโยชน์ความคุ้มครองโรคร้ายแรงกลุ่มที่1 และ 2 \nที่ได้จ่ายให้ผู้รับผลประโยชน์ไปแล้ว',
                  style: pw.TextStyle(font: font, fontSize: 8),
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      // ตารางโรคร้ายแรงกลุ่ม 1
      pw.Table(
        columnWidths: {
          0: pw.FlexColumnWidth(),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "โรคร้ายแรงกลุ่มที่ 1 ที่ได้รับความคุ้มครองกรณีเจ็บป่วยด้วยโรคร้ายแรง ดังต่อไปนี้",
                  style: pw.TextStyle(font: ttfBold, fontSize: 8),
                ),
              ),
            ],
          ),
          ...List.generate(criticalIllnessGroup1.length, (index) {
            return pw.TableRow(
              children: [
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.only(left: 28, top: 4, bottom: 4, right: 4),
                  child: pw.Text(
                    '${index + 1}. ${criticalIllnessGroup1[index]}',
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      pw.SizedBox(height: 10),

      // ตารางโรคร้ายแรงกลุ่ม 2 (multi-column)
      buildMultiColumnGroup2(criticalIllnessGroup2),
      pw.SizedBox(height: 10),
      buildMultiColumnChild(criticalIllnessChild),
      pw.SizedBox(height: 5),
      pw.Center(
        child: 
          pw.Text(
            "หมายเหตุ : มีระยะเวลาให้คุ้มครอง 90 วันนับตั้งแต่วันที่เริ่มมีผลคุ้มครองตามกรมธรรม์",
            style: pw.TextStyle(font: ttfBold, fontSize: 8),
          ),
      ),
    ],
  );
}


