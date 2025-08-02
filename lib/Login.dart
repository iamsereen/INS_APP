import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ins_application/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userBox = Hive.box<User>('users');
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  void _signup() {
    final username = usernameCtrl.text.trim();
    final password = _hashPassword(passwordCtrl.text.trim());

    if (userBox.values.any((u) => u.username == username)) {
      _show('Username already exists');
      return;
    }

    userBox.add(User(username: username, passwordHash: password));
    _show('Signup successful');
  }

  void _login() {
    final username = usernameCtrl.text.trim();
    final password = _hashPassword(passwordCtrl.text.trim());

    final matches = userBox.values.where(
      (u) => u.username == username && u.passwordHash == password,
    ).toList();

    final user = matches.isNotEmpty ? matches.first : null;


    if (user != null) {
      _show('Login success: ${user.username}');
    } else {
      _show('Login failed');
    }
  }

  void _show(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            OutlinedButton(onPressed: _signup, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
