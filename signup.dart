import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userType = 'user'; // Default user type

  // Method to handle signup
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Add user data to Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'createdAt': FieldValue.serverTimestamp(),
          'email': emailController.text,
          'fullName': fullNameController.text,
          'phone': phoneController.text,
          'status': userType, // Add status field (user, driver, admin)
        });

        // Clear input fields
        emailController.clear();
        passwordController.clear();
        fullNameController.clear();
        phoneController.clear();

        // Navigate back to the login page
        Navigator.pop(context);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your full name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Password must be at least 6 characters long";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // User and Driver Signup Buttons in a Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        userType = 'user';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userType == 'user' ? Colors.deepPurple : Colors.grey,
                    ),
                    child: const Text("Signup as User"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        userType = 'driver';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userType == 'driver' ? Colors.deepPurple : Colors.grey,
                    ),
                    child: const Text("Signup as Driver"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Admin Signup Button Below
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    userType = 'admin';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: userType == 'admin' ? Colors.deepPurple : Colors.grey,
                ),
                child: const Text("Signup as Admin"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
