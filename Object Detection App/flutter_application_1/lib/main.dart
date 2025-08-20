
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'view/loginScreen.dart';
import 'view/detectionScreen.dart';
import 'view/registerScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDZWGFrTbe_MXgpqN5hEQpItW4qnn9gpeQ",
      appId: "1:38581665431:android:3d50603ea85aaeb87033d2",
      messagingSenderId: "38581665431",
      projectId: "object-detection-app-2ded4",
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const Register(),
        '/detection': (context) => const DetectionScreen(),
      },
    );
  }
}




