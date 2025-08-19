import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ins_application/Plan.dart';
import 'package:ins_application/user_data.dart';
import 'Functions.dart';
import 'package:printing/printing.dart';
import 'Export.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FixedFormTab extends StatefulWidget {
  const FixedFormTab({Key? key}) : super(key: key);

  @override
  State<FixedFormTab> createState() => _FixedFormTabState();
}

// ใช้ AutomaticKeepAliveClientMixin เพื่อรักษาสถานะของแท็บนี้
class _FixedFormTabState extends State<FixedFormTab> with AutomaticKeepAliveClientMixin {
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _calculatedPremiumController = TextEditingController();
  final TextEditingController premiumAmountController = TextEditingController();
  List<Map<String, dynamic>> _dynamicFields = [];
  final UserData _userData = UserData();
  List<InsurancePlan> products = [];
  String? gender;
  int? _selectedNumber;
  String? selectedKind;
  String? selectedOpt;
  String selectedCategory = '';
  String inputValue = '';
  String? selectedOption1;
  String? selectedOption2;
  String? selectedPercent;
  double? sumAssured;
  int? age;
  double calculatedPremium = 0.0;
  bool _isLoading = false;


  // Dropdown
  String selectedValue = 'Value';
  Map<String, dynamic> currentPlanData = {};

  @override
  bool get wantKeepAlive => true; // ให้แท็บนี้รักษาสถานะไว้


  void _clearAllFields() {
    _plateController.clear();
    _ageController.clear();
    _yearController.clear();
    premiumAmountController.clear();
    _calculatedPremiumController.clear();
    for (var field in _dynamicFields) {
      field['controller'].clear();
    }
  }

  Future<void> _handleAddField() async {
  final result = await showAddFieldDialog(context);
  if (result != null) {
    setState(() {
      _dynamicFields.add(result);
    });
  }
}

void _updateUserData() {
    _userData.updateData(
      newGender: gender,
      newAge: int.tryParse(_ageController.text),
    );
  }

void _handlePercentChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedPercent = newValue;
      });
    }
}

@override
void initState() {
  super.initState();
  loadProducts().then((data) {
    setState(() {
      products = data;
    });
  });
}

  @override
  Widget build(BuildContext context) {
    super.build(context); // ต้องเรียก super.build(context) เสมอ

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _handleAddField,
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มข้อมูล'),
            ),
          ),
          const SizedBox(height: 16),
          ..._dynamicFields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: field['controller'],
                  decoration: InputDecoration(
                    labelText: field['label'],
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _dynamicFields.remove(field);
                          field['controller'].dispose();
                        });
                      },
                    ),
                  ),
                ),
              );
            }).toList(),

          // Row 1
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('เพศ'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Checkbox(
                    value: gender == 'male', 
                    onChanged: (bool? value) {
                      setState(() {
                        gender = value! ? 'male' : null;
                        _updateUserData(); 
                      });
                    }
                  ),
                  const Text('ชาย'),
                  const SizedBox(width: 10),
                  Checkbox(
                    value: gender == 'female', 
                    onChanged: (bool? value) {
                      setState(() {
                        gender = value! ? 'female' : null;
                        _updateUserData();
                         
                      });
                    }
                  ),
                  const Text('หญิง'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                  labelText: 'อายุ',
                  border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _updateUserData(); 
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int> (
                  decoration: const InputDecoration(
                    labelText: 'ขั้นอาชีพ',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedNumber,
                  items: List.generate(5, (index) {
                    int value = index +1;
                    return DropdownMenuItem(
                      value: value, child: Text(value.toString()));
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedNumber = value;
                    });
                  },
                )
              ),
            ],
          ), 
          const SizedBox(height: 16),
      
          CascadingDropdown(
            onSelectionChanged: (code, plan) {
              print("เลือก: $code");
            },
          ),
      
          const SizedBox(height: 16),
          SelectableDoubleDropdown(
              options: const ['เบี้ยประกัน', 'ทุนประกัน'],
              controller: premiumAmountController, 
            ),
      
          const SizedBox(height: 16),
      
          PercentDropdown(
            onChanged: _handlePercentChanged,
            initialValue: selectedPercent,
          ),
        
          const SizedBox(height: 32),
        
          // ปุ่มล่าง
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _clearAllFields,
                  child: const Text(
                    'CLEAR',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final int startAge = _userData.age ?? 0;
                    final String taxPercent = selectedPercent ?? '0';
                    final String gender = _userData.gender ?? '';
                    

                    final pdfBytes = await generateInsurancePdfWeb(
                      startAge: startAge, 
                      selectedTaxPercent: taxPercent, 
                      insuranceType: selectedOpt!, 
                      gender: gender,
                      calculatePremium: double.tryParse(_calculatedPremiumController.text) ?? 0.0,
                    );
                    await Printing.layoutPdf(
                      onLayout: (format) async => pdfBytes,
                      name: 'insurance_summary.pdf',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('EXPORT'),
                ),
              ),
            ],
          ),
        ],
          ),
      ),
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _ageController.dispose();
    _yearController.dispose();
    _calculatedPremiumController.dispose();
    for (var field in _dynamicFields) {
      field['controller'].dispose();
    }
    super.dispose();
  }
}
