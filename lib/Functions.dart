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
  String? selectedOption;
  final UserData _userData = UserData();
  String? _errorText;
  double? calculatedPremium;
  final TextEditingController _ShowratesController = TextEditingController();
  final TextEditingController _ShowmodeController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // ตั้งค่าเริ่มต้นของดรอปดาวน์และข้อความโหมด
  if (widget.options.length >= 2) {
    selectedOption = widget.options[0];
  } else if (widget.options.length == 1) {
    selectedOption = widget.options[0];
  }

  // อัปเดตข้อความโหมดเริ่มต้น
  _ShowmodeController.text =
      selectedOption == "ทุนประกัน" ? "เบี้ยประกัน" : "ทุนประกัน";

  widget.controller.addListener(_updatePremiumAmount);
}


  void _updatePremiumAmount() async {
  final double? inputamount = double.tryParse(widget.controller.text);
  //_userData.updateData(newPremiumAmount: inputamount);
  final InsurancePlan? plan = _userData.selectedPlan;
  final user = UserData();
  //user.updateData(newPremiumAmount: inputamount);

  if (inputamount == null || plan == null) {
    setState(() {
      _ShowratesController.text = '-';
      _errorText = null;
      //calculatedPremium = null;
    });
    return;
  }

  if (selectedOption == "ทุนประกัน" && inputamount < plan.minIns) {
      setState(() {
        _errorText = "ขั้นต่ำคือ ${plan.minIns} บาท";
        _ShowratesController.text = '-';
        calculatedPremium = null;
      });
      return;
    } else {
      _errorText = null;
}
  
  // คำนวณ Rate และ Discount
  final rate = getRateForAgeGender(
    plan: plan,
    age: _userData.age ?? 0,
    gender: _userData.gender ?? 'male',
  );

  final discount = getDiscountForPremium(plan, inputamount);

  double?  money; // เงินทุนประกัน
  double? rateValue; // เบี้ยประกัน

  if (selectedOption == "ทุนประกัน") {
      money = inputamount;
      rateValue = ((rate - discount) * money / 1000).abs();
    } else if (selectedOption == "เบี้ยประกัน") {
      rateValue = inputamount;
      final firstResult = ((rateValue * 1000) / rate).abs();
      //print('คำนวณรอบแรก (ยังไม่หักส่วนลด): $firstResult');

      final discount = await getDiscountForPremium(plan, firstResult);
      //print('ส่วนลดที่ได้จาก JSON: $discount');

      money = ((rateValue * 1000) / (rate - discount)).abs();
      //print('ทุนประกันที่คำนวณได้ (หลังหักส่วนลด): $money');

    _userData.updateData(newPremiumAmount: rateValue);
    _userData.Amount = money;
    _userData.updatePremium(rateValue);
    }
  
  _userData.Amount = money; // เงินทุนประกัน
  _userData.updatePremium(rateValue ?? 0); // เบี้ยประกัน


  // อัปเดตเบี้ยใน TextField
  UserData().premiumController.text =
  rateValue != null ? rateValue.toStringAsFixed(0) : '-';


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

  /* Log ข้อมูล dataValues
  print('--- dataValues ---');
  print(dataValues);*/

  final surrenderCalculator = SurrenderValueCalculator(
    dataValues: user.dataValues,
    insuredAmount: money ?? 0, // ใช้ทุนประกันที่ผู้ใช้ใส่
  );
  List<double> surrenderValues = surrenderCalculator.calculate();
  UserData().updateAccumulatedPremiums(surrenderValues);

  // คำนวณเบี้ยสะสมตามปีกรมธรรม์
  List<double> accumulated =
    computeAccumulatedPremium(plan: plan, userData: _userData, annualPremium: rateValue ?? 0);
    _userData.updateAccumulatedPremiums(accumulated);

  // อัปเดต UI
  setState(() {
  UserData().premiumController.text =
      selectedOption == "ทุนประกัน"
          ? (rateValue?.toStringAsFixed(2) ?? '')
          : (money?.toStringAsFixed(0) ?? '');
  });

  /* Log รายละเอียดการคำนวณเบี้ย
  print('--- คำนวณเบี้ยประกัน ---');
  print('รหัสประกัน: ${plan.code}');
  print('เงินทุน: $money');
  print('อายุ: ${_userData.age}');
  print('เพศ: ${_userData.gender}');
  print('Rate: $rate');
  print('Discount: $discount');
  print('endage: ${plan.endage}');
  print('ค่าเบี้ยรวม: $money');
  print('-----------------------');*/

  }

  void updateDropdown(String? value) {
  setState(() {
    selectedOption = value;

    // รีเซ็ตช่องกรอกค่าและผลลัพธ์
    widget.controller.clear();
    UserData().premiumController.clear();

    // อัปเดตข้อความโหมดตรงข้าม
    _ShowmodeController.text =
        selectedOption == "ทุนประกัน" ? "เบี้ยประกัน" : "ทุนประกัน";
  });
}


  @override
  void dispose() {
    // อย่าลืมลบ Listener เมื่อ State ถูกทำลาย
    widget.controller.removeListener(_updatePremiumAmount);
    _ShowratesController.dispose();
    _ShowmodeController.dispose();
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
                value: selectedOption,
                items: widget.options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: updateDropdown,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 212,
              child: TextField(
                controller: widget.controller, 
                decoration: InputDecoration(
                  labelText: 'ระบุค่า',
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
              flex: 1,
              child: TextField(
                controller: _ShowmodeController,
                readOnly: true,
              ),
            ),
            const SizedBox(width: 8),
            // โชว์ค่าเบี้ย
            Expanded(
              child: TextField(
                controller: UserData().premiumController,
                readOnly: true,
                decoration: InputDecoration(
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


// two dropdowns
/*class DropdownController with ChangeNotifier {
  // ค่าเลือกของ dropdown แรก
  String? selectedCategory;

  // ค่าเลือกของ dropdown ที่สอง
  String? selectedID;

  // category -> items
  final Map<String, List<String>> options = {
    'ตลอดชีพ': ['20LPB', '20SLPA', 'CX10', 'CX20', '5SLC', '10SLC', '12TXM', '24TXN', 'WXN10', 'WXN15'],
    'สะสมทรัพย์': ['15SPN', '7SM'],
    'บำนาญ': ['AR60N', 'AR65', 'AR5N', '15HA', 'HA55', 'AS10', 'AS60'],
  };

  // list ของ dropdown แรก
  List<String> get categories => options.keys.toList();

  // list ของ dropdown ที่สอง (ขึ้นกับ category ที่เลือก)
  List<String> get items {
    if (selectedCategory == null) return [];
    return options[selectedCategory] ?? [];
  }

  // เปลี่ยนค่า dropdown แรก
  void setCategory(String value) {
    selectedCategory = value;
    selectedID = null; // reset dropdown ที่สอง
    notifyListeners();
  }

  // เปลี่ยนค่า dropdown ที่สอง
  void setItem(String value) {
    selectedID = value;
    notifyListeners();
  }
}*/