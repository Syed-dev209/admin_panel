import 'package:admin_panel/HomePage.dart';
import 'package:admin_panel/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const API_KEY = "AIzaSyA6xnZjLYL_rWt6HS8RQMg3WG0wL8p6xik";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAdYbJzXtwhJvdJFNohAH1mjtduQydYHxA",
            authDomain: "ambulancesystem-9191f.firebaseapp.com",
            databaseURL:
                "https://ambulancesystem-9191f-default-rtdb.firebaseio.com",
            projectId: "ambulancesystem-9191f",
            storageBucket: "ambulancesystem-9191f.appspot.com",
            messagingSenderId: "954396563673",
            appId: "1:954396563673:web:923d55ea385efed9b8c6c8",
            measurementId: "G-K8FDHW4TMC"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}
