import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for formatting the timestamp
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'login.dart'; // Import your login page

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController luggageSearchController = TextEditingController();
  String searchQuery = ""; // To store the user's search input

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Update searchQuery whenever the user types in the search bar
    luggageSearchController.addListener(() {
      setState(() {
        searchQuery = luggageSearchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    luggageSearchController.dispose();
    super.dispose();
  }

  // Format the timestamp into a readable format
  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
  }

  // Method to log out the user
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  // Stream for filtering data based on the search query
  Stream<QuerySnapshot> _getFilteredData(String collection) {
    if (searchQuery.isEmpty) {
      return FirebaseFirestore.instance.collection(collection).snapshots();
    }
    return FirebaseFirestore.instance
        .collection(collection)
        .where('luggageId', isGreaterThanOrEqualTo: searchQuery)
        .where('luggageId', isLessThanOrEqualTo: '$searchQuery\uf8ff') // For partial matching
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Accepted Luggage"),
            Tab(text: "Notifications"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Accepted Luggage Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: luggageSearchController,
                  decoration: const InputDecoration(
                    labelText: "Search by Luggage ID",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getFilteredData('accepted_requests'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No accepted luggage found"));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final timestamp = data['timestamp'] as Timestamp?;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text("Luggage ID: ${data['luggageId']}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Description: ${data['description']}"),
                                Text("Fragile: ${data['isFragile'] ?? false ? 'Yes' : 'No'}"),
                                Text("Drop-Off Point: ${data['dropOffCounty']}, ${data['dropOffSubCounty']}"),
                                Text("Recipient Name: ${data['recipientName']}"),
                                Text("Recipient Phone: ${data['recipientPhone']}"),
                                if (timestamp != null)
                                  Text("Accepted On: ${_formatTimestamp(timestamp)}"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Notifications Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: luggageSearchController,
                  decoration: const InputDecoration(
                    labelText: "Search by Luggage ID",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Refresh search results when typing
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('notifications')
                      .orderBy('timestamp', descending: true) // Sort by timestamp
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No notifications found"));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final timestamp = data['timestamp'] as Timestamp?;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(data['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['message']),
                                if (timestamp != null)
                                  Text("Sent On: ${_formatTimestamp(timestamp)}"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}