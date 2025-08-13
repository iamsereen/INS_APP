import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'HomePage.dart';
import 'user_model.dart';
import 'Login.dart'; // กลับไปหน้า login

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final userBox = Hive.box<User>('users');
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String selectedRole = 'user';

  void _addUser() async {
    final userBox = Hive.box<User>('users');
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      return;
    }

    if (userBox.values.any((u) => u.username == username)) {
      return;
    }

    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    final user = User(username: username, passwordHash: passwordHash, role: selectedRole, PlainPassword: password,);
    
    await userBox.add(user);
    Navigator.pop(context);

    usernameCtrl.clear();
    passwordCtrl.clear();

  }

  Future<void> _deleteUser(int index) async {
    final userBox = Hive.box<User>('users');
    userBox.deleteAt(index);
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          )
        ],
      ),
    );
  }

  void _changePassword(User user, int index) {
  final newPasswordCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('เปลี่ยนรหัสผ่าน'),
      content: TextField(
        controller: newPasswordCtrl,
        decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่'),
        obscureText: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () {
            final newPassword = newPasswordCtrl.text.trim();
            if (newPassword.isEmpty) return;

            final newHash = sha256.convert(utf8.encode(newPassword)).toString();

            final updatedUser = User(
              username: user.username,
              passwordHash: newHash,
              PlainPassword: newPassword,
              role: user.role,
            );

            userBox.putAt(index, updatedUser);
            Navigator.pop(context);
            _showDialog('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว');
            setState(() {});
          },
          child: const Text('ยืนยัน'),
        ),
      ],
    ),
  );
}

void _showAddUserDialog() {

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('เพิ่มผู้ใช้ใหม่'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  DropdownButton<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedRole = val);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: _addUser,
                child: const Text('เพิ่มผู้ใช้'),
              ),
            ],
          );
        },
        ); 
},
  );
}


  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<User>('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 0, 0, 0), // สีข้อความ
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // ขอบมน
                side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'หน้าหลัก',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
          SizedBox(width: 10,),
          IconButton(
            icon: const Icon(Icons.add_box),
            tooltip: 'เพิ่มผู้ใช้ใหม่',
            onPressed: _showAddUserDialog,
          ),
          SizedBox(width: 10,),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: userBox.listenable(),
              builder: (context, Box<User> box, _) {
                final count = box.length;
                return Text(
                  'จำนวนบัญชีผู้ใช้ $count',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                );
              },
            ),

            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: userBox.listenable(),
                builder: (context, Box<User> box, _) {
                  final users = box.values.toList();

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (_, index) {
                      final user = users[index];
                      return Card(
                        child: ListTile(
                          title: Text('Username: ${user.username}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Password: ${user.PlainPassword ?? "(ไม่พบรหัสผ่าน)"}'),
                              Text('Role: ${user.role}'),
                            ],
                          ),
                          trailing: user.role == 'admin'
                          ? PopupMenuButton<String> (
                            onSelected: (value) {
                              if (value == 'change') {
                                _changePassword(user, index);
                              } else if (value == 'delete') {
                                _deleteUser(index);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'change',
                                child: Text('เปลี่ยนรหัสผ่าน'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('ลบบัญชี'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          )
                          : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(index),
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}


