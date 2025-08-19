// lib/user_data.dart
import 'package:flutter/material.dart';
import 'package:ins_application/Functions.dart';
import 'package:ins_application/Plan.dart';

class UserData {
  static final UserData _instance = UserData._internal();

  factory UserData() {
    return _instance;
  }

  UserData._internal();

  String? gender;
  int? age;
  InsuranceData? selectedInsurance;
  double? premiumAmount;
  InsurancePlan? selectedProduct;
  String? selectedCode;
  InsurancePlan? selectedPlan;
  final TextEditingController premiumController = TextEditingController();
  
  void updatePremium(double value) {
    premiumAmount = value;
    premiumController.text = value.toStringAsFixed(2);
  }

  void updateData({String? newGender, int? newAge, InsuranceData? newInsurance, double? newPremiumAmount, InsurancePlan? newProduct,InsurancePlan? newPlan,
    String? newCode,}) {
    if (newGender != null) gender = newGender;
    if (newAge != null) age = newAge;
    if (newPlan != null) selectedPlan = newPlan;
    if (newCode != null) selectedCode = newCode;
    if (newProduct != null) selectedProduct = newProduct;
    if (newPremiumAmount != null) premiumAmount = newPremiumAmount;
  }
}

class InsuranceData {
  final String kind;
  final String name;
  final double premium;
  final double faceAmount;

  InsuranceData({
    required this.kind,
    required this.name,
    required this.premium,
    required this.faceAmount,
  });

  factory InsuranceData.fromJson(String kind, Map<String, dynamic> json) {
    return InsuranceData(
      kind: kind,
      name: json['name'],
      premium: json['premium'].toDouble(),
      faceAmount: json['faceAmount'].toDouble(),
    );
  }
}