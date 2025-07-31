import 'package:flutter/material.dart';
import 'AddData.dart';
import 'FixedForm.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> _tabTitles = ['MODULE 1'];
  List<Widget> _tabContents = [const Placeholder()];

  @override
  void initState() {
    super.initState();
    //_tabsHeaders.add('Module');
    _tabContents[0] = (const FixedFormTab());

    // สร้าง TabController เริ่มต้นใน initState ทันที
    _tabController = TabController(length: _tabTitles.length + 1, vsync: this);
    _tabController.addListener((){
      if (_tabController.index == _tabTitles.length) {
        _tabController.index = 0;
        _showAddTabDialog();
      }
    }
    ); // เพิ่ม listener ใหม่
  }

  // ฟังก์ชันสำหรับแสดง Dialog เพื่อให้ผู้ใช้ตั้งชื่อแท็บใหม่
  void _showAddTabDialog() {
    TextEditingController tabNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ตั้งชื่อแท็บใหม่'),
          content: TextField(
            controller: tabNameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'ชื่อแท็บ'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                String newTabname = tabNameController.text.trim();
                if (newTabname.isNotEmpty) {
                  setState(() {
                    _tabTitles.add(newTabname);
                    _tabContents.add(const MainFormTab());
                    _tabController = TabController(
                      length: _tabTitles.length +1,
                      vsync: this,
                    );
                    _tabController.addListener(() {
                      if (_tabController.index == _tabTitles.length) {
                        _tabController.index = 0;
                        _showAddTabDialog();
                      }
                    });
                    Future.delayed(Duration.zero, () {
                      _tabController.index = _tabTitles.length -1;
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        );
      },
    );
  }

  /* ฟังก์ชันสำหรับเพิ่มแท็บใหม่
  void _addDynamicTab(String tabName) {
      final String finalTabName = tabName.isEmpty ? 'แท็บที่ ${_nextTabIndex++}' : tabName;

      setState(() {
      _tabsHeaders.add(finalTabName);
      _tabsContent.add(MainFormTab(key: ValueKey(finalTabName)));

      _tabController.dispose();
      _tabController = TabController(length: _tabsHeaders.length, vsync: this);

    });
    
  }*/

  // ฟังก์ชันสำหรับแสดง Dialog เพื่อเปลี่ยนชื่อแท็บ
  void _showRenameTabDialog(int tabIndex) {
    TextEditingController renameController = TextEditingController(text: _tabTitles[tabIndex]); // ใช้ TextEditingController สำหรับ TextField

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เปลี่ยนชื่อแท็บ'),
          content: TextField(
            autofocus: true,
            controller: renameController, // กำหนด controller
            decoration: const InputDecoration(labelText: 'Rename'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                String newName = renameController.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    _tabTitles[tabIndex] = newName;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('เปลี่ยนชื่อ'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับลบแท็บ
  void _deleteTab(int index) {
    if (index == 0) return;

    setState(() {
      // ลบเนื้อหาแท็บ และชื่อแท็บ
      _tabContents.removeAt(index);
      _tabTitles.removeAt(index);
      _tabController = TabController(length: _tabTitles.length +1, vsync: this);

      _tabController.addListener(() {
        if (_tabController.index == _tabTitles.length) {
          _tabController.index = 0;
          _showAddTabDialog();
        }
      }); // เพิ่ม listener ใหม่
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'COMPANY\'S NAME',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // ทำให้ TabBar เลื่อนได้ถ้ามีหลายแท็บ
          tabs: [
            for (int i = 0; i < _tabTitles.length; i++)
            Tab(
              child: Row(
                children: [
                  Text(_tabTitles[i]),
                  const SizedBox(width: 4,),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18,),
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameTabDialog(i);
                      } else if (value == 'delete') {
                        _deleteTab(i);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'rename', child: Text('เปลี่ยนชื่อ')),
                      const PopupMenuItem(value: 'delete', child: Text('ลบ')),// เพิ่มเมนูลบ   
                    ],
                  )
                ],
              ),
            ),
            /*..._tabTitles.map((title) => Tab(text: title,)),*/
            const Tab(icon: Icon(Icons.add),),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ..._tabContents, // เนื้อหาของแท็บ Module และแท็บที่ผู้ใช้สร้าง
          const SizedBox.shrink(), // เนื้อหาสำหรับแท็บเพิ่มแท็บ (สุดท้าย)
        ],
      ),
    );
  }
}

  
  /*@override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabDataList.length, vsync: this);
  }

  void _showRenameTabDialog(int index) {
    _tabNameController.text = tabs[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เปลี่ยนชื่อแท็บ'),
          content: TextField(
            controller: _tabNameController,
            decoration: const InputDecoration(
              hintText: 'ใส่ชื่อแท็บใหม่',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _tabNameController.clear();
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_tabNameController.text.trim().isNotEmpty) {
                  setState(() {
                    tabs[index] = _tabNameController.text.trim();
                  });
                  Navigator.of(context).pop();
                  _tabNameController.clear();
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }


  void _deleteTab(int index) {
    if (_tabDataList.length <= 2) return; // ไม่ให้ลบถ้ามีแค่ 2 แท็บ
    
    setState(() {
      _tabDataList.removeAt(index);
      if (selectedTab >= _tabDataList.length) {
        selectedTab = _tabDataList.length - 1;
      } else if (selectedTab > index) {
        selectedTab--;
      }
    });
  }
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
    setState(() {
      selectedValue = 'Value';
    });
  }

  


  /*void _addNewTab(String tabname) {
    setState(() {
      _tabs.add(Tab(text: tabname));
      _tabViews.add(Center(child: Text('Content of $tabname'),));

      _tabController.dispose();
      _tabController = TabController(length: _tabs.length, vsync: this);
    });
  }*/

  void _showAddtabDialog() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Tab'),
        content: TextField(
          controller: _tabNameController,
          decoration: const InputDecoration(
            hintText: 'Enter tab name',
            border: OutlineInputBorder(),
            ),
            autofocus: true,
        ),
          actions: [
            TextButton(
              child: Text("ยกเลิก"),
              onPressed: () {
                Navigator.of(context).pop();
                _tabNameController.clear();
              },
            ),
            ElevatedButton(
              child: Text ("เพิ่ม"),
              onPressed: () {
                if (_tabNameController.text.trim().isNotEmpty) {
                  setState(() {
                    _tabDataList.add(_tabNameController.text.trim());
                    selectedTab = _tabDataList.length - 1; // เลือกแท็บใหม่ที่เพิ่ม
                  });
                  Navigator.of(context).pop();
                  _tabNameController.clear();
                }
              }, 
              
            )
          ],
        );
      }
    );
  }

  

  void _exportData() {
    // Implement export functionality here
    print('Export data...');
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
    _tabNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("COMPANY'S NAME"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _tabDataList
                      .map((tab) => Tab(child: _buildTab(tab)))
                      .toList(),
                  labelColor: Colors.orange,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.orange),
                onPressed: _showAddtabDialog,
              ),
            ],
          ),
        )
      ),
      body: 
      /*TabBarView(
        controller: _tabController,
        children: _tabViews,
      ),*/
      Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < _tabDataList.length; i++)
                          GestureDetector(
                            onTap: () => setState(() => selectedTab = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTab == i
                                        ? Colors.orange
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _tabDataList[i],
                                    style: TextStyle(
                                      color: selectedTab == i
                                          ? Colors.orange
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deleteTab(i);
                                      } else if (value == 'rename') {
                                        _showRenameTabDialog(i);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'rename',
                                        child: Text('เปลี่ยนชื่อ'),
                                      ),
                                      if (_tabDataList.length > 2) // ไม่ให้ลบถ้ามีแค่ 2 แท็บ
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('ลบแท็บ'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      _showAddTabDialog();
                    },
                  ),
                ),
              ],
            ),
          ),
          // Form Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Add Data Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text('เพิ่มข้อมูล'),
                      ],
                    ),
                  ),
                  
                  // First Row - Three columns
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('เพศ', _plateController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('อายุ', _ageController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('ยันอายิฟ', _yearController),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Dropdown Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ปานกลม',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedValue,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: ['Value', 'Option 1', 'Option 2']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Second Row - Three columns
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('ภาษี', _langController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('HEC', _hecController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('เมียประกัน', _taxController),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Third Row - Two columns
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('HB', _hbController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('DD50', _dd50Controller),
                      ),
                      const Expanded(child: SizedBox()), // Empty space for alignment
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Fourth Row - Three columns
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('AI', _aiController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('ADD', _addController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('ADB', _adbController),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            _clearAllFields();
                          },
                          child: const Text(
                            'CLEAR',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _exportData();
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
          ),
        ],
      )
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
class TabData {
  String title;
  TabData(this.title);
}*/