import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  static UserModel userModel = UserModel._internal();

  factory UserModel() {
    return userModel;
  }

  UserModel._internal();

  String? name, id, email;

  UserModel.fromJson(Map<String, dynamic> data, String id) {
    name = data['name'];
    email = data['email'];
    id = id;
  }
}
