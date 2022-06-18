import 'dart:developer';

import 'package:admin_panel/Model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<bool> loginAdmin(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      final _userData = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'admin')
          .get();
      for (var i in _userData.docs) {
        UserModel.userModel = UserModel.fromJson(i.data(), i.id);
      }
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> logout() async{
    try{
      await _firebaseAuth.signOut();
      return true;
    }catch(e){
      log(e.toString());
      return false;
    }
  }
}
