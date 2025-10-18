import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'googlelogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Initialize Firebase asynchronously
  Future<FirebaseApp> _initializeFirebase() async {
    return await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alumni Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const GoogleLogin(); // ✅ Firebase initialized
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error initializing Firebase: ${snapshot.error}'),
              ),
            );
          }
          // 🔄 While waiting for Firebase
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
