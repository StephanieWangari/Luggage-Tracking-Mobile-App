import 'package:flutter/material.dart';
import 'package:luggagetracker_app/about.dart';
import 'package:luggagetracker_app/home.dart';
import 'package:luggagetracker_app/registration.dart';
import 'package:luggagetracker_app/notifications.dart'; // Import the notifications page
import 'package:luggagetracker_app/login.dart'; // Import the login page
import 'package:luggagetracker_app/recipient.dart'; // Import the RecipientPage

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const LuggageRegistrationPage(),
    const AboutUsPage(),
    const NotificationsPage(), // Add the NotificationsPage here
    const RecipientPage(), // Add the RecipientPage here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.black45,
        actions: [
          // Logout button with enhanced visibility
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8), // Spacing on sides
            decoration: const BoxDecoration(
              color: Colors.redAccent, // Background color for visibility
              shape: BoxShape.circle, // Circular button shape
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white), // White logout icon
              tooltip: 'Logout',
              onPressed: _logout, // Calls the logout function when pressed
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Register Luggage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Recipient', // Add the "Recipient" tab
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.purpleAccent,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.black,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to the login page
    );
  }
}
