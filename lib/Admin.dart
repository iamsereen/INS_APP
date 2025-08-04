import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
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
      _showDialog('กรุณากรอกข้อมูลให้ครบ');
      return;
    }

    if (userBox.values.any((u) => u.username == username)) {
      _showDialog('มีผู้ใช้นี้อยู่แล้ว');
      return;
    }

    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    final user = User(username: username, passwordHash: passwordHash, role: selectedRole, PlainPassword: password,);
    
    await userBox.add(user);

    usernameCtrl.clear();
    passwordCtrl.clear();

    _showDialog('เพิ่มผู้ใช้สำเร็จ');
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

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<User>('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('เพิ่มผู้ใช้ใหม่', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('เพิ่มผู้ใช้'),
            ),
            const SizedBox(height: 20),
            const Text('รายการผู้ใช้', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          title: Text(user.username),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Role: ${user.role}'),
                              Text('Password: ${user.PlainPassword ?? "(ไม่พบรหัสผ่าน)"}'),
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


