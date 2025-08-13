import 'package:flutter/material.dart';
import 'AddData.dart';
import 'FixedForm.dart';
import 'Login.dart';

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
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
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
