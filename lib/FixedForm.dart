import 'package:flutter/material.dart';
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
  final TextEditingController _langController = TextEditingController();
  final TextEditingController _hecController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _hbController = TextEditingController();
  final TextEditingController _dd50Controller = TextEditingController();
  final TextEditingController _aiController = TextEditingController();
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _adbController = TextEditingController();
  final TextEditingController premiumAmountController = TextEditingController();
  List<Map<String, dynamic>> _dynamicFields = [];
  String? _selectedGender;
  int? _selectedNumber;
  String? selectedKind;
  String? selectedOpt;
  String selectedCategory = '';
  String inputValue = '';
  String? selectedOption1;
  String? selectedOption2;
  String? selectedPercent;


  // Dropdown
  String selectedValue = 'Value';

  @override
  bool get wantKeepAlive => true; // ให้แท็บนี้รักษาสถานะไว้

  void _clearAllFields() {
    _plateController.clear();
    _ageController.clear();
    _yearController.clear();
    _langController.clear();
    _hecController.clear();
    _taxController.clear();
    _hbController.clear();
    _dd50Controller.clear();
    _aiController.clear();
    _addController.clear();
    _adbController.clear();
    premiumAmountController.clear();
    for (var field in _dynamicFields) {
      field['controller'].clear();
    }
  }

  /*void _exportData() async {
    final pdfData = await generatePDF(
      dynamicFields: _dynamicFields.map((field) => {
        'label' : (field['label'] ?? '').toString(),
        'value': field['controller'].text.toString(),
      }).toList(), 
      gender: _selectedGender, 
      age: _ageController.text, 
      careerStep: _selectedNumber, 
      cascading1: selectedKind, 
      cascading2: selectedOpt, 
      dropdown1: selectedOption1, 
      dropdown2: selectedOption2, 
      percent: selectedPercent?.toString(),
      );
      await Printing.layoutPdf(onLayout: (format) async => pdfData);
  }*/

  Future<void> _handleAddField() async {
  final result = await showAddFieldDialog(context);
  if (result != null) {
    setState(() {
      _dynamicFields.add(result);
    });
  }
}

void _onDropdownChange(String country, String city) {
    setState(() {
      selectedKind = country;
      selectedOpt = city;
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
                    value: _selectedGender == 'ชาย', 
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedGender = value! ? 'ชาย' : null;
                      });
                    }
                  ),
                  const Text('ชาย'),
                  const SizedBox(width: 10),
                  Checkbox(
                    value: _selectedGender == 'หญิง', 
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedGender = value! ? 'หญิง' : null;
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
      
          CascadingDropdown(onSelectionChanged: _onDropdownChange),
      
          const SizedBox(height: 16),
          // Dropdown
          SelectableDoubleDropdown(
            options: ['เบี้ยประกัน', 'ทุนประกัน'], 
            controller: premiumAmountController,
          ),
      
          const SizedBox(height: 16),
      
          PercentDropdown(),
        
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
                    final int startAge = int.tryParse(_ageController.text) ?? 0;
                    final String taxPercent = selectedPercent ?? '0';

                    final htmlContent = generateInsuranceHtml(
                      startAge: startAge, 
                      selectedTaxPercent: taxPercent
                    );

                    final outputDir = await getTemporaryDirectory();
                    final pdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
                      htmlContent, 
                      outputDir.path, 
                      "insurance_summary"
                    );
                    await OpenFile.open(pdfFile.path);
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
    _langController.dispose();
    _hecController.dispose();
    _taxController.dispose();
    _hbController.dispose();
    _dd50Controller.dispose();
    _aiController.dispose();
    _addController.dispose();
    _adbController.dispose();
    premiumAmountController.dispose();
    for (var field in _dynamicFields) {
      field['controller'].dispose();
    }
    super.dispose();
  }
}
