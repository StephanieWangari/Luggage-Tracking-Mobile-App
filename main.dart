import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:luggagetracker_app/driverdashboard.dart';
import 'package:luggagetracker_app/signup.dart';
import 'dashboard.dart';
import 'login.dart';
import 'admindashboard.dart'; // Import AdminDashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: "AIzaSyAx2KKs9SMOkc5Jtu1o2eGdoFFk3CEgX_E",
        authDomain: "luggagetracker-2c2b9.firebaseapp.com",
        projectId: "luggagetracker-2c2b9",
        storageBucket: "luggagetracker-2c2b9.firebasestorage.app",
        messagingSenderId: "501409198424",
        appId: "1:501409198424:web:04a9fb8679ccde5603f52d"
    ));
  } else {
    await Firebase.initializeApp();
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
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/signup': (context) => SignupPage(),
        '/dashboard': (context) => const Dashboard(),
        '/driverdashboard': (context) => const DriverDashboard(),
        '/admindashboard': (context) => const AdminDashboard(), // Admin route
      },
    );
  }
}
