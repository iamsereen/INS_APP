import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ins_application/INS_CAL.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'Admin.dart';
import 'user_model.dart';
import 'Login.dart';
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Uint8List encryptionKey;

  // ลงทะเบียน Adapter
  Hive.registerAdapter(UserAdapter());

  if (kIsWeb) {
    await Hive.initFlutter();

    final savedKey = html.window.localStorage['encryptionKey'];
    if (savedKey != null) {
      encryptionKey = base64Decode(savedKey);
    } else {
      encryptionKey = Uint8List.fromList(Hive.generateSecureKey());
      html.window.localStorage['encryptionKey'] = base64Encode(encryptionKey);
    }

    // เปิดกล่องสำหรับ Web
    await Hive.openBox<User>(
      'users',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    debugPrint('Web: เปิดกล่อง users แล้ว (${Hive.box<User>('users').length} users)');

  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);

    final keyFile = File('${appDocDir.path}/encryption.key');

    if (await keyFile.exists()) {
      encryptionKey = await keyFile.readAsBytes();
    } else {
      encryptionKey = Uint8List.fromList(Hive.generateSecureKey());
      await keyFile.writeAsBytes(encryptionKey);
    }

    await Hive.openBox<User>(
      'users',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    debugPrint('Mobile: เปิดกล่อง users แล้ว (${Hive.box<User>('users').length} users)');
  }

  // เพิ่มแอดมินถ้ายังไม่มี
  final userBox = Hive.box<User>('users');
  const defaultUsername = 'admin';
  const defaultPassword = 'admin123';

  final exists = userBox.values.any((u) => u.username == defaultUsername);

  if (!exists) {
    final admin = User(
      username: defaultUsername,
      passwordHash: sha256.convert(utf8.encode(defaultPassword)).toString(),
      role: 'admin',
      PlainPassword: defaultPassword,
    );
    await userBox.add(admin);
    debugPrint('✅ สร้างแอดมิน admin / admin123 แล้ว');
  } else {
    debugPrint('ℹ️ พบแอดมินแล้วในระบบ');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INS App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AdminPage(),
    );
  }
}
