import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to handle login
  Future<void> _login(String role) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    try {
      // Attempt to sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Retrieve user role from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user?.uid).get();

      if (userDoc.exists) {
        String status = userDoc['status'];

        // Check if the user role matches the selected role
        if (status == role) {
          // Navigate to the appropriate dashboard based on user role
          if (role == 'user') {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (role == 'driver') {
            Navigator.pushReplacementNamed(context, '/driverdashboard');
          } else if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admindashboard');
          }
        } else {
          // Role mismatch
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You are signed up as a different role.")),
          );
          await _auth.signOut(); // Sign out if role doesn't match
        }
      } else {
        // User not found in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found.")),
        );
      }
    } catch (e) {
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // Driver and User Login Buttons in a Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _login('driver'), // Login as Driver
                    child: const Text("Login as Driver"),
                  ),
                  ElevatedButton(
                    onPressed: () => _login('user'), // Login as User
                    child: const Text("Login as User"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Admin Login Button Below
              ElevatedButton(
                onPressed: () => _login('admin'), // Login as Admin
                child: const Text("Login as Admin"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Don't have an account? Signup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
