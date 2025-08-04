import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ins_application/Admin.dart';
import 'package:ins_application/HomePage.dart';
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

  void _login() {
    final username = usernameCtrl.text.trim();
    final password = _hashPassword(passwordCtrl.text.trim());
    print("Trying to login with: $username / $password");
    userBox.values.forEach((u) {
      print("username: ${u.username}, hash: ${u.passwordHash}, role: ${u.role}");
    });

    final matches = userBox.values.where(
      (u) => u.username == username && u.passwordHash == password,
    ).toList();

    final user = matches.isNotEmpty ? matches.first : null;


    if (user != null) {
    if (user.role == 'admin') {
      _show('Login success: ${user.username} (admin)');
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AdminPage()),
      );
    } else {
      _show('Login success: ${user.username}');
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
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
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header คล้ายโค้งบน (ใช้เป็น placeholder)
              Container(
                height: 100,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomRight: Radius.circular(150),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Log in",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Email
              TextField(
                controller: usernameCtrl,
                decoration: InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text(
                    "Log in",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Create account
              TextButton(
                onPressed: () {},
                child: const Text.rich(
                  TextSpan(
                    text: 'New user ? ',
                    children: [
                      TextSpan(
                        text: 'Create account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /*@override
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
  }*/
}