import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:ins_application/user_data.dart';

class InsurancePlan {
  final String code;
  final int minIns;
  final List<Discount> discounts;
  final Coverage coverage;
  final List<Rate> rates;
  final int endage;
  final int untilyear;

  InsurancePlan({
    required this.code,
    required this.minIns,
    required this.discounts,
    required this.coverage,
    required this.rates,
    required this.endage,
    required this.untilyear
  });

  factory InsurancePlan.fromJson(String code, Map<String, dynamic> json) {
    return InsurancePlan(
      code: code,
      minIns: json['minIns'] ?? 0,
      endage: json['endage'] ?? 0,
      untilyear: json['untilyear'] ?? 0,
      discounts: (json['discounts'] as List? ?? [])
          .map((e) => Discount.fromJson(e))
          .toList(),
      coverage: Coverage.fromJson(json['coverage'] ?? {}),
      rates: (json['rates'] as List? ?? [])
          .map((e) => Rate.fromJson(e))
          .toList(),
    );
  }
}

final Map<String, String> codeToFile = {
  "20LPB": "20LPB",
  "20SLPA": "20SLPA",
  "5SLC": "5SLC",
  "10SLC": "10SLC"
};

Future<List<InsurancePlan>> loadProducts([String filename = "20LPB"]) async {
  final String response = await rootBundle.loadString('assets/json/$filename.json');
  final Map<String, dynamic> data = json.decode(response)['products'];

  List<InsurancePlan> plans = [];
  data.forEach((code, value) {
    plans.add(InsurancePlan.fromJson(code, value));
  });

  return plans;
}


class Discount {
  final int min;
  final int? max;
  final double discount;

  Discount({required this.min, this.max, required this.discount});

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      min: json['min'] ?? 0,
      max: json['max'],
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Coverage {
  final double percentage;

  Coverage({required this.percentage});

  factory Coverage.fromJson(Map<String, dynamic> json) {
    return Coverage(
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Rate {
  final int age;
  final double male;
  final double female;

  Rate({required this.age, required this.male, required this.female});

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      age: json['age'] ?? 0,
      male: (json['male'] as num?)?.toDouble() ?? 0.0,
      female: (json['female'] as num?)?.toDouble() ?? 0.0,
    );
  }
}


Future<InsurancePlan> showPlanByCode(String code, String fileName) async {
  final plans = await loadProducts(fileName);
  final plan = plans.firstWhere(
    (p) => p.code == code,
    orElse: () => throw Exception("ไม่พบรหัสประกัน $code"),
  );

  print("รหัส: ${plan.code}");
  print("อายุสิ้นสุด: ${plan.endage}");
  print("ขั้นต่ำ: ${plan.minIns}");
  print("ความคุ้มครอง: ${plan.coverage.percentage}%");
  

  print("ส่วนลด:");
  for (var d in plan.discounts) {
    print(" - min: ${d.min}, max: ${d.max}, discount: ${d.discount}");
  }

  print("อัตราเบี้ย:");
  for (var r in plan.rates) {
    print(" - อายุ: ${r.age}, ชาย: ${r.male}, หญิง: ${r.female}");
  }
  return plan;
}

double getRateForAgeGender({
  required InsurancePlan plan,
  required int age,
  required String gender, // "male" หรือ "female"
}) {
  try {
    Rate rate = plan.rates.firstWhere((r) => r.age == age);
    double value = (gender.toLowerCase() == 'male')
        ? rate.male
        : rate.female;

    print('อายุ: $age, เพศ: $gender, เรทเบี้ย: $value');
    return value;
  } catch (e) {
    print('ไม่พบข้อมูลเรทสำหรับอายุ $age ในรหัส ${plan.code}');
    return 0.0;
  }
}

// หา discount ตามเงินทุน
double getDiscountForPremium(InsurancePlan plan, double premiumAmount) {
  for (var d in plan.discounts) {
    int min = d.min;
    int? max = d.max;
    double discount = d.discount;

    if (premiumAmount >= min && (max == null || premiumAmount <= max)) {
      return discount;
    }
  }
  return 0.0;
}


// object สำหรับเก็บค่าที่แมพแล้ว
class MappedInsuranceData {
  final double premiumAmount; // เงินทุน
  final double rate;          // เรทเบี้ย
  final double discount;      // ส่วนลด
  final double minIns;        // ขั้นต่ำเงินทุน


  MappedInsuranceData({
    required this.premiumAmount,
    required this.rate,
    required this.discount,
    required this.minIns,
  });
}

// คำนวณค่าเบี้ย
double calculatePremium(MappedInsuranceData data) {
  if (data.premiumAmount < data.minIns) {
    print("เงินทุนต่ำกว่าขั้นต่ำ ${data.minIns} บาท");
    return 0.0;
  }

  double premium = (data.rate - data.discount) * data.premiumAmount / 1000;
  print("ค่าเบี้ยประกัน = $premium บาท");
  return premium;
}

// ฟังก์ชันหลักสำหรับแมพข้อมูลและคำนวณ
void computeInsurancePremium({
  required InsurancePlan plan,
  required UserData userData,
}) {
  if (userData.premiumAmount == null ||
      userData.age == null ||
      userData.gender == null) {
    print("กรุณากรอกเงินทุน, อายุ, เพศ ให้ครบ");
    return;
  }

  double rate = getRateForAgeGender(
    plan: plan,
    age: userData.age!,
    gender: userData.gender!,
  );

  double discount = getDiscountForPremium(plan, userData.premiumAmount!);

  double minIns = plan.minIns as double;

  MappedInsuranceData data = MappedInsuranceData(
    premiumAmount: userData.premiumAmount!,
    rate: rate,
    discount: discount,
    minIns: minIns,
  );

  calculatePremium(data);
}

List<double> computeAccumulatedPremium({
  required InsurancePlan plan,
  required UserData userData,
  required double annualPremium, // ค่าเบี้ยรวมต่อปี
}) {
  // ถ้า age เป็น null ให้คืน list ว่าง
  if (userData.age == null) {
    return [];
  }

  int currentAge = userData.age!;
  int untilYear = plan.untilyear; // จำนวนปีที่ต้องคำนวณจาก json
  double accumulated = 0.0;
  List<double> accumulatedList = [];

  for (int year = 1; year <= untilYear; year++) {
    accumulated += annualPremium;
    accumulatedList.add(accumulated);
    print('ปีที่ $year (อายุ ${currentAge + year}) = ${accumulated.toStringAsFixed(0)}');
  }

  return accumulatedList;
}


Future<Map<String, dynamic>> loadJsonMapForPolicy(String filename) async {
  final String response = await rootBundle.loadString('assets/json/$filename.json');
  final Map<String, dynamic> data = json.decode(response);
  return data; // คืนเป็น Map<String, dynamic> ดิบ
}


List<double> getAllPolicyData({
  required Map<String, dynamic> jsonData,
  required String gender,
  required int age,
  required String productCode,
  required int endAge,
}) {
  final productData = jsonData['products'][productCode];
  if (productData == null) {
    print('ไม่พบรหัสประกัน $productCode');
    return [];
  }

  final List<dynamic>? genderList = productData[gender];
  if (genderList == null || genderList.isEmpty) {
    print('ไม่พบข้อมูลเพศ $gender ในรหัส $productCode');
    return [];
  }

  final Map<String, dynamic>? ageData = genderList.firstWhere(
    (element) => element['age'] == age,
    orElse: () => null,
  );

  if (ageData == null) {
    print('ไม่พบข้อมูลอายุ $age สำหรับเพศ $gender ในรหัส $productCode');
    return [];
  }

  List<dynamic> rowData = ageData['data'] ?? [];
  List<double> fullData = rowData.map((e) => (e as num?)?.toDouble() ?? 0.0).toList();

  // คำนวณจำนวนปีที่เหลือ
  int remainingYears = endAge - age;
  if (remainingYears <= 0) remainingYears = 1; // อย่างน้อยเก็บค่า 1 ค่า

  // ตัดช่วง data ให้เท่ากับ remainingYears
  // กระจายค่าเท่ากันจาก fullData
  List<double> results = [];
  int step = (fullData.length / remainingYears).ceil();
  for (int i = 0; i < remainingYears; i++) {
    int idx = i * step;
    if (idx >= fullData.length) idx = fullData.length - 1;
    results.add(fullData[idx]);
  }

  print('เพศ: $gender, อายุ: $age, endAge: $endAge -> data: $results');

  return results;
}


class SurrenderValueCalculator {
  final List<double> dataValues;
  final double insuredAmount; // ใช้ทุนประกันจริง ไม่ใช่เบี้ย

  SurrenderValueCalculator({
    required this.dataValues,
    required this.insuredAmount,
  });

  List<double> calculate() {
    List<double> results = dataValues.map((value) {
      if (value == 0) return 0.0;
      return value * insuredAmount / 1000; // ใช้ทุนประกันจริง
    }).toList();

    // แสดงผลลัพธ์ในล็อก
    print('--- มูลค่าเวนคืน ---');
    for (int i = 0; i < results.length; i++) {
      print('dataValues[$i]: ${dataValues[i]} -> SurrenderValue: ${results[i]}');
    }
    print('------------------');
    UserData().updateSurrenderValues(results);
    print('UserData.surrenderValues: ${UserData().surrenderValues}');

    return results;
  }
}








