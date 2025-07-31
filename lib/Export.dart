String generateInsuranceHtml({
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
}
