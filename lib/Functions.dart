import 'package:flutter/material.dart';
import 'package:ins_application/Plan.dart';
import 'package:ins_application/user_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, FilteringTextInputFormatter, TextInputFormatter;
import 'dart:convert';
import 'package:intl/intl.dart';



Future<Map<String, dynamic>?> showAddFieldDialog(BuildContext context) async {
  String fieldLabel = '';
  String selectedType = 'ข้อความ';

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('เพิ่มช่องข้อมูล'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'ชื่อช่อง'),
              onChanged: (value) => fieldLabel = value,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: ['ข้อความ', 'ตัวเลข'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedType = value;
                }
              },
              decoration: const InputDecoration(labelText: 'ประเภท'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (fieldLabel.trim().isEmpty) {
                return;
              }
              Navigator.pop(context, {
                'label': fieldLabel.trim(),
                'type': selectedType,
                'controller': TextEditingController(),
              });
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      );
    },
  );
}

class CascadingDropdown extends StatefulWidget {
  final Function(String code, String fileName) onSelectionChanged;

  const CascadingDropdown({Key? key, required this.onSelectionChanged})
      : super(key: key);

  @override
  State<CascadingDropdown> createState() => _CascadingDropdownState();
}

class _CascadingDropdownState extends State<CascadingDropdown> {
  List<String> codes = [];
  String? selectedCode;
  InsurancePlan? selectedPlan;
  final UserData _userData = UserData();

  @override
  void initState() {
    super.initState();
    _loadAllCodes();
  }

  Future<void> _loadAllCodes() async {
    List<String> allCodes = [];
    for (var entry in codeToFile.entries) {
      final plans = await loadProducts(entry.value);
      allCodes.addAll(plans.map((p) => p.code));
    }
    setState(() {
      codes = allCodes;
      if (codes.isNotEmpty) {
        selectedCode = codes.first;
        _updateSelectedPlan(selectedCode!);
      }
    });
  }

  Future<void> _updateSelectedPlan(String code) async {
    final fileName = codeToFile[code] ?? "20LPB";
    final plans = await loadProducts(fileName);
    final plan = plans.firstWhere((p) => p.code == code, orElse: () => plans.first);

    setState(() {
      selectedPlan = plan;
      selectedCode = code;
    });

    widget.onSelectionChanged(code, fileName);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'รหัสประกัน',
        border: OutlineInputBorder(),
      ),
      value: selectedCode,
      items: codes
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              ))
          .toList(),
      onChanged: (value) async {
        if (value == null) return;

        final fileName = codeToFile[value] ?? "20LPB";
        final plans = await loadProducts(fileName);

        // ใช้ plans จากไฟล์ที่โหลด ไม่ใช่ widget.products
        final newPlan = plans.firstWhere(
          (p) => p.code == value,
          orElse: () => plans.first,
        );

        setState(() {
          selectedCode = value;
          selectedPlan = newPlan;
        });

        widget.onSelectionChanged(value, fileName);
        showPlanByCode(value, fileName);

        // อัปเดต Singleton
        final userData = UserData();
        userData.updateData(
          newCode: value,
          newPlan: newPlan,
        );
      },
    );
  }
}

/*class CascadingDropdown extends StatefulWidget {
  final Function(String) onSelectionChanged;
  final List<InsurancePlan> products;

  const CascadingDropdown({
    Key? key,
    required this.onSelectionChanged,
    required this.products,
  }) : super(key: key);

  @override
  State<CascadingDropdown> createState() => _CascadingDropdownState();
}

class _CascadingDropdownState extends State<CascadingDropdown> {
  String? selectedKind;
  String? selectedCode;
  final UserData _userData = UserData();
  List<InsurancePlan> currentPlans = [];
  InsurancePlan? selectedPlan;


  @override
  void initState() {
    super.initState();
    if (widget.products.isNotEmpty) {
      selectedCode = currentPlans.first.code;
      currentPlans = widget.products;
      selectedPlan = currentPlans.first;
      // ส่งค่าเริ่มต้นกลับไปยัง parent
      widget.onSelectionChanged(selectedCode!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'รหัสประกัน',
        border: OutlineInputBorder(),
      ),
      value: selectedCode,
      items: currentPlans
          .map((plan) => DropdownMenuItem(
                value: plan.code,
                child: Text(plan.code),
              ))
          .toList(),
      onChanged: (value) async {
        if (value == null) return;
        final fileName = codeToFile[value] ?? "20LPB";
        try {
          final plans = await loadProducts(fileName);
          final newplan = plans.firstWhere((p) => p.code == value, orElse: () => plans.first);

          setState(() {
          currentPlans = plans;
          selectedCode = value;
          selectedPlan = newplan;
          _userData.selectedPlan = newplan;
        });
          
          widget.onSelectionChanged(value);
          showPlanByCode(value, fileName);
        } catch (e) {
          print("ไม่สามารถโหลดไฟล์ JSON: $fileName, error: $e");
        }
      },
    );
  }
}*/


class SelectableDoubleDropdown extends StatefulWidget {
  final List<String> options;
  final TextEditingController controller;

  const SelectableDoubleDropdown({
    super.key,
    required this.options,
    required this.controller, 
  });

  @override
  State<SelectableDoubleDropdown> createState() => _SelectableDoubleDropdownState();
}

class _SelectableDoubleDropdownState extends State<SelectableDoubleDropdown> {
  String? selectedOption1;
  String? selectedOption2;
  final UserData _userData = UserData();
  String? _errorText;
  double? calculatedPremium;
  final TextEditingController _ShowratesController = TextEditingController();


  @override
  void initState() {
    super.initState();

    // ✅ เริ่มต้น: เอาตัวแรกใส่ dropdown1, ตัวถัดไปใส่ dropdown2
    if (widget.options.length >= 2) {
      selectedOption1 = widget.options[0];
      selectedOption2 = widget.options[1];
    } else if (widget.options.length == 1) {
      selectedOption1 = widget.options[0];
      selectedOption2 = null;
    }
    widget.controller.addListener(_updatePremiumAmount);
    widget.controller.addListener(() {
    // อ่านค่าที่ผู้ใช้กรอก
    double? enteredAmount = double.tryParse(widget.controller.text);

    // เก็บลง UserData
    UserData().Amount = enteredAmount;

    // ไม่คำนวณ anything ที่นี่
    print('ทุนประกันที่ผู้ใช้กรอก: $enteredAmount');
  });
  }


  void _updatePremiumAmount() async {
  final double? amount = double.tryParse(widget.controller.text);
  _userData.updateData(newPremiumAmount: amount);
  final InsurancePlan? plan = _userData.selectedPlan;
  final user = UserData();
  user.updateData(newPremiumAmount: amount);

  if (amount == null || plan == null) {
    setState(() {
      _ShowratesController.text = '-';
      _errorText = null;
      calculatedPremium = null;
    });
    return;
  }

  if (amount < plan.minIns) {
    setState(() {
      _errorText = "ขั้นต่ำคือ ${plan.minIns} บาท";
      _ShowratesController.text = '-';
    });
    return;
  } else {
    setState(() {
      _errorText = null;
    });
  }
  
  // คำนวณ Rate และ Discount
  final rate = getRateForAgeGender(
    plan: plan,
    age: _userData.age ?? 0,
    gender: _userData.gender ?? 'male',
  );

  final discount = getDiscountForPremium(plan, amount);
  final premium = (rate - discount) * amount / 1000;
  UserData().updatePremium(premium);

  // โหลด JSON ของแผนประกัน
  Map<String, dynamic> jsonData = await loadJsonMapForPolicy(plan.code);
  List<double> dataValues = getAllPolicyData(
    jsonData: jsonData,
    gender: _userData.gender ?? 'female',
    age: _userData.age ?? 0,
    productCode: plan.code,
    endAge: plan.endage,
  );
  user.updateDataValues(dataValues);

  // Log ข้อมูล dataValues
  print('--- dataValues ---');
  print(dataValues);

  final surrenderCalculator = SurrenderValueCalculator(
    dataValues: user.dataValues,
    insuredAmount: amount, // ใช้ทุนประกันที่ผู้ใช้ใส่
  );
  List<double> surrenderValues = surrenderCalculator.calculate();
  
  UserData().updateAccumulatedPremiums(
    computeAccumulatedPremium(
      plan: plan,
      userData: _userData,
      annualPremium: premium,
    ),
  );


  // อัปเดต UI
  setState(() {
    calculatedPremium = premium;
    _ShowratesController.text = premium.toStringAsFixed(2);
  });

  // Log รายละเอียดการคำนวณเบี้ย
  print('--- คำนวณเบี้ยประกัน ---');
  print('รหัสประกัน: ${plan.code}');
  print('เงินทุน: $amount');
  print('อายุ: ${_userData.age}');
  print('เพศ: ${_userData.gender}');
  print('Rate: $rate');
  print('Discount: $discount');
  print('endage: ${plan.endage}');
  print('ค่าเบี้ยรวม: $premium');
  print('-----------------------');

  // คำนวณเบี้ยสะสมตามปีกรมธรรม์
  computeAccumulatedPremium(
    plan: plan,
    userData: _userData,
    annualPremium: premium,
  );
}



  void updateDropdown1(String? value) {
    setState(() {
      if (value == selectedOption2) {
        selectedOption2 = selectedOption1;
      }
      selectedOption1 = value;
    });
  }

  void updateDropdown2(String? value) {
    setState(() {
      if (value == selectedOption1) {
        selectedOption1 = selectedOption2;
      }
      selectedOption2 = value;
    });
  }

  @override
  void dispose() {
    // อย่าลืมลบ Listener เมื่อ State ถูกทำลาย
    widget.controller.removeListener(_updatePremiumAmount);
    _ShowratesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
    Column(
      children: [
        // ✅ Dropdown 1
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedOption1,
                items: widget.options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: updateDropdown1,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 212,
              child: TextField(
                controller: widget.controller, 
                decoration: InputDecoration(
                  labelText: 'ระบุค่าเพิ่มเติม',
                  border: OutlineInputBorder(),
                  errorText: _errorText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedOption2,
                items: widget.options
                    .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                    .toList(),
                onChanged: (value) {
                  updateDropdown2(value); // เปลี่ยนค่า dropdown
                  
                },
              ),
            ),
            const SizedBox(width: 8),
            // ถ้าอยากโชว์ค่าเบี้ยใน UI ให้ใช้ Text widget แทน
            Expanded(
              child: TextField(
                controller: UserData().premiumController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'ค่าเบี้ย',
                  border: OutlineInputBorder(),
                ),
              ),
            )

          ],
        ),

        
      ],
    );
  }
}

class PercentDropdown extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final String? initialValue;

  const PercentDropdown({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<PercentDropdown> createState() => _PercentDropdownState();
}

class _PercentDropdownState extends State<PercentDropdown> {
  String? selectedPercent;
  
  @override
  void initState() {
    super.initState();
    selectedPercent = widget.initialValue;
  }
  
  final List<String> percentOptions = List.generate(
    8,
    (index) => '${index * 5}%',
  );

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'ภาษี',
        border: OutlineInputBorder(),
      ),
      value: selectedPercent,
      items: percentOptions
          .map((percent) =>
              DropdownMenuItem(value: percent, child: Text(percent)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedPercent = value;
        });
        widget.onChanged(value);
      },
    );
  }
}



