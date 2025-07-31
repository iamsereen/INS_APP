import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Functions.dart';

class MainFormTab extends StatefulWidget {
  const MainFormTab({Key? key}) : super(key: key);

  @override
  State<MainFormTab> createState() => _MainFormTabState();
}

class _MainFormTabState extends State<MainFormTab> with AutomaticKeepAliveClientMixin {
  final List<Map<String, dynamic>> fields = [];


  @override
  bool get wantKeepAlive => true;

  void _handleAddField() async {
  final result = await showAddFieldDialog(context);
  if (result != null) {
    setState(() {
      fields.add(result);
    });
  }
}


  void _deleteField(int index) {
    setState(() {
      // ต้อง dispose controller ก่อนลบ เพื่อป้องกัน Memory Leak
      fields[index]['controller'].dispose();
      fields.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ปุ่มเพิ่มช่อง
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _handleAddField,
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มช่อง'),
            ),
          ),
    
          const SizedBox(height: 12),
    
          // แสดงฟอร์ม
          Expanded(
            child: ListView.builder(
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: field['controller'],
                          keyboardType: field['type'] == 'ตัวเลข'
                              ? TextInputType.number
                              : TextInputType.text,
                          decoration: InputDecoration(
                            labelText: field['label'],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton( // ปุ่มลบ
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteField(index), // เรียกฟังก์ชันลบ
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
        ],
      ),
    );
  }
  @override
  void dispose() {
    for (var field in fields) {
      field['controller'].dispose();
    }
    super.dispose();
  }
}
