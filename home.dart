import 'package:flutter/material.dart';
import 'package:luggagetracker_app/about.dart';
import 'package:luggagetracker_app/notifications.dart'; // Import the notifications page
import 'registration.dart'; // Import the luggage registration page
import 'recipient.dart'; // Import the recipient page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.deepPurple, // Custom AppBar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Padding for the whole page
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome text
            const Text(
              "Welcome to the Home Page",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Luggage Registration Button
            buildNavigationButton(
              context,
              "Luggage Registration",
              Colors.pinkAccent,
              Colors.purpleAccent,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LuggageRegistrationPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // About Us Button
            buildNavigationButton(
              context,
              "About Us",
              Colors.redAccent,
              Colors.yellowAccent,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),


            // Notifications Button
            buildNavigationButton(
              context,
              "Notifications",
              Colors.blueAccent,
              Colors.orangeAccent,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(), // Make sure NotificationsPage is defined
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Recipient Button
            buildNavigationButton(
              context,
              "Recipient",
              Colors.greenAccent,
              Colors.blueAccent,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipientPage(), // RecipientPage
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create the navigation buttons
  Widget buildNavigationButton(
      BuildContext context,
      String title,
      Color startColor,
      Color endColor,
      VoidCallback onPressed,
      ) {
    return Container(
      width: double.infinity,
      height: 60, // Slightly large button
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor], // Multi-colored gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0), // Rounded button edges
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // No background since we use a gradient
          shadowColor: Colors.transparent, // Remove button shadow
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
