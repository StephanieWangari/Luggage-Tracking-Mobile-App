import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.deepPurple, // Customizing AppBar color
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0), // Increased padding for a spacious look
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About The App",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent, // Custom color
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Welcome to the Luggage Tracking App, your trusted companion for seamless luggage management. Our app is designed to help travelers keep track of their luggage, ensuring peace of mind during your journeys.",
              style: TextStyle(
                fontSize: 18,
                height: 1.5, // Increased line height for readability
                color: Colors.black87, // Subtle text color for readability
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Mission Statement",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Our mission is to simplify luggage tracking for travelers worldwide. We aim to reduce the anxiety of losing your belongings while traveling, providing a user-friendly solution to manage and monitor your luggage.",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Key Features",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "- Luggage Registration: Easily register your luggage with a unique ID.\n"
                  "- Real-time Tracking: Monitor your luggage status at all times.\n"
                  "- Notifications: Receive updates and alerts about your luggage.\n"
                  "- User-friendly Interface: Navigate effortlessly through the app.",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "For support or inquiries, please contact us at: support@luggagetracker.com",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Acknowledgments",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "We would like to thank our users for their feedback and our partners for their continuous support.",
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
