import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ins_application/user_model.dart';
import 'HomePage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart'; // ใช้แค่ Mobile
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // สำหรับ Web ใช้ HiveFlutter ซึ่งไม่ต้องระบุ path
    await Hive.initFlutter();

    // สร้าง key สำหรับ web (อาจเก็บใน localStorage หรือ generate ใหม่ทุกครั้งก็ได้)
    final encryptionKey = Uint8List.fromList(Hive.generateSecureKey());

    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(
      'users',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  } else {
    // สำหรับ Android / iOS
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    Hive.registerAdapter(UserAdapter());

    final keyFile = File('${appDocDir.path}/encryption.key');
    Uint8List encryptionKey;

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
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
