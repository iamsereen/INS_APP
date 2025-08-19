import 'dart:convert'; // สำหรับ json.decode
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ins_application/Plan.dart';

/*class InsuranceService {
  static Future<Map<String, InsurancePlan>> loadProducts() async {
    final jsonString = await rootBundle.loadString('assets/json/20LPB.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final products = <String, InsurancePlan>{};

    (jsonData['products'] as Map<String, dynamic>).forEach((code, data) {
      products[code] = InsurancePlan.fromJson(code, data);
    });

    return products;
  }

}*/




