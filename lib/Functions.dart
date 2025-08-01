import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;



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
  final Function(String, String) onSelectionChanged;

  const CascadingDropdown({Key? key, required this.onSelectionChanged})
      : super(key: key);

  @override
  State<CascadingDropdown> createState() => _CascadingDropdownState();
}

class _CascadingDropdownState extends State<CascadingDropdown> {
  final Map<String, List<String>> dataMap = {
    'ตลอดชีพ': ['20LPB', '20SLPA', 'CX20', 'CX10', '5SLC', '10SLC', '12TXM', '24TXN', 'WXN10', 'WXN15'],
    'สะสมทรัพย์': ['15SPN', '7SM', '0'],
    'บำนาญ': ['CX20', 'AR60N', 'AR65', '15HA', 'HA55', 'AS10', 'AS60', '0'],
  };

  String? selectedKind;
  String? selectedOpt;

  @override
  void initState() {
  super.initState();
  if (dataMap.isNotEmpty) {
    selectedKind = dataMap.keys.first;
  }
}

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: selectedKind,
            items: dataMap.keys.map((Kind) {
              return DropdownMenuItem(
                value: Kind,
                child: Text(Kind),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedKind = value;
                selectedOpt = null;
              });
              if (value != null && selectedOpt != null) {
                widget.onSelectionChanged(value, selectedOpt!);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'ประเภท',
              border: OutlineInputBorder(),
            ),
            value: selectedOpt,
            items: (selectedKind != null
                    ? dataMap[selectedKind]!
                    : <String>[])
                .map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedOpt = value;
              });
              if (selectedKind != null && value != null) {
                widget.onSelectionChanged(selectedKind!, value);
              }
            },
          ),
        ),
      ],
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
  String? selectedOption1;
  String? selectedOption2;

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
                decoration: const InputDecoration(
                  labelText: 'ระบุค่าเพิ่มเติม',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ✅ Dropdown 2
        DropdownButtonFormField<String>(
          value: selectedOption2,
          items: widget.options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
          onChanged: updateDropdown2,
        ),
      ],
    );
  }
}

class PercentDropdown extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final String? initialValue;

  const PercentDropdown({
    Key? key,
    required this.onChanged,
    this.initialValue,
  }) : super(key: key);

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



