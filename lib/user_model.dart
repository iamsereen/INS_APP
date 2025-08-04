import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)

class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String passwordHash; // เก็บเป็น hash แล้ว

  @HiveField(2)
  String role;

  @HiveField(3)
  String? PlainPassword;

  User({required this.username, required this.passwordHash, required this.role, required this.PlainPassword,});
}